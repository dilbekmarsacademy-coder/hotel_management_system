/**
 * LuxeStay Cloud Functions
 *
 * TRUST BOUNDARY: Sensitive booking creation, pricing, and coupon
 * application happen here — never trust client totals or roles.
 *
 * Deploy: firebase deploy --only functions
 * Emulator: npm run serve
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();
const db = admin.firestore();

// ── Types ────────────────────────────────────────────────────

interface CreateBookingRequest {
  roomId: string;
  checkIn: string; // ISO date
  checkOut: string;
  guestCount: number;
  guestName?: string;
  guestEmail?: string;
  guestPhone?: string;
  specialRequests?: string;
  promoCode?: string;
  serviceIds?: string[];
}

interface PriceBreakdown {
  roomCharges: number;
  servicesTotal: number;
  subtotal: number;
  discount: number;
  tax: number;
  serviceFee: number;
  grandTotal: number;
  nights: number;
}

const TAX_RATE = 0.12;
const SERVICE_FEE_RATE = 0.05;
const BLOCKING_STATUSES = ["pending", "confirmed", "checkedIn"];

// ── Helpers ──────────────────────────────────────────────────

function assertAuth(context: functions.https.CallableContext): string {
  if (!context.auth?.uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "You must be signed in to create a booking."
    );
  }
  return context.auth.uid;
}

function parseDate(iso: string): Date {
  const d = new Date(iso);
  if (Number.isNaN(d.getTime())) {
    throw new functions.https.HttpsError("invalid-argument", "Invalid date");
  }
  return d;
}

function nightCount(checkIn: Date, checkOut: Date): number {
  const a = Date.UTC(checkIn.getFullYear(), checkIn.getMonth(), checkIn.getDate());
  const b = Date.UTC(checkOut.getFullYear(), checkOut.getMonth(), checkOut.getDate());
  const nights = Math.round((b - a) / 86400000);
  return nights < 1 ? 1 : nights;
}

function datesOverlap(
  aStart: Date,
  aEnd: Date,
  bStart: Date,
  bEnd: Date
): boolean {
  // Checkout day is free for next check-in (half-open interval)
  return aStart < bEnd && bStart < aEnd;
}

function dayOnly(d: Date): Date {
  return new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()));
}

function calcPrice(
  pricePerNight: number,
  nights: number,
  servicesTotal: number,
  discountPercent: number,
  discountFixed: number
): PriceBreakdown {
  const roomCharges = pricePerNight * nights;
  const subtotal = roomCharges + servicesTotal;
  const percentDisc = subtotal * (discountPercent / 100);
  const discount = percentDisc + discountFixed;
  const taxable = Math.max(0, subtotal - discount);
  const tax = taxable * TAX_RATE;
  const serviceFee = taxable * SERVICE_FEE_RATE;
  return {
    roomCharges,
    servicesTotal,
    subtotal,
    discount,
    tax,
    serviceFee,
    grandTotal: taxable + tax + serviceFee,
    nights,
  };
}

async function writeAudit(params: {
  actorId: string;
  action: string;
  entityType: string;
  entityId: string;
  metadata?: Record<string, unknown>;
}): Promise<void> {
  await db.collection("auditLogs").add({
    actorId: params.actorId,
    action: params.action,
    entityType: params.entityType,
    entityId: params.entityId,
    metadata: params.metadata ?? {},
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

// ── createBooking ────────────────────────────────────────────

export const createBooking = functions.https.onCall(
  async (data: CreateBookingRequest, context) => {
    const uid = assertAuth(context);

    if (!data.roomId || !data.checkIn || !data.checkOut) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "roomId, checkIn, and checkOut are required"
      );
    }

    const checkIn = dayOnly(parseDate(data.checkIn));
    const checkOut = dayOnly(parseDate(data.checkOut));
    if (checkOut <= checkIn) {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "checkOut must be after checkIn"
      );
    }

    const guestCount = Math.max(1, Number(data.guestCount) || 1);

    // Load user profile (role is informational; guests book for themselves)
    const userSnap = await db.collection("users").doc(uid).get();
    const userData = userSnap.data() ?? {};
    const guestName =
      data.guestName ||
      `${userData.firstName ?? ""} ${userData.lastName ?? ""}`.trim() ||
      "Guest";
    const guestEmail = data.guestEmail || userData.email || context.auth!.token.email || "";

    // Transaction: room + availability + coupon + booking write
    const result = await db.runTransaction(async (tx) => {
      const roomRef = db.collection("rooms").doc(data.roomId);
      const roomSnap = await tx.get(roomRef);
      if (!roomSnap.exists) {
        throw new functions.https.HttpsError("not-found", "Room not found");
      }
      const room = roomSnap.data()!;
      const roomStatus = (room.status as string) || "available";

      if (roomStatus === "maintenance") {
        throw new functions.https.HttpsError(
          "failed-precondition",
          "Room is under maintenance"
        );
      }
      if (roomStatus !== "available" && roomStatus !== "reserved") {
        // Occupied/cleaning cannot take a new booking starting overlapping stay
        // Further checked via booking overlaps below
      }

      // Query overlapping bookings for this room
      // Note: Firestore inequality filters are limited; filter in memory after roomId match
      const bookingsQuery = await db
        .collection("bookings")
        .where("roomId", "==", data.roomId)
        .get();

      for (const doc of bookingsQuery.docs) {
        const b = doc.data();
        const status = b.status as string;
        if (!BLOCKING_STATUSES.includes(status)) continue;
        const bIn = dayOnly((b.checkIn as admin.firestore.Timestamp).toDate());
        const bOut = dayOnly((b.checkOut as admin.firestore.Timestamp).toDate());
        if (datesOverlap(checkIn, checkOut, bIn, bOut)) {
          throw new functions.https.HttpsError(
            "already-exists",
            "Room is not available for these dates"
          );
        }
      }

      // Services total (server-derived from catalog prices)
      let servicesTotal = 0;
      if (data.serviceIds && data.serviceIds.length > 0) {
        for (const sid of data.serviceIds.slice(0, 20)) {
          const sSnap = await tx.get(db.collection("services").doc(sid));
          if (sSnap.exists) {
            const s = sSnap.data()!;
            if (s.isAvailable !== false) {
              servicesTotal += Number(s.price) || 0;
            }
          }
        }
      }

      // Coupon validation (server-trusted)
      let discountPercent = 0;
      let discountFixed = 0;
      let couponId: string | null = null;
      if (data.promoCode) {
        const code = data.promoCode.trim().toUpperCase();
        const couponQuery = await db
          .collection("coupons")
          .where("code", "==", code)
          .limit(1)
          .get();
        if (couponQuery.empty) {
          throw new functions.https.HttpsError(
            "invalid-argument",
            "Invalid coupon code"
          );
        }
        const cDoc = couponQuery.docs[0];
        const c = cDoc.data();
        if (c.active === false) {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "Coupon is inactive"
          );
        }
        const now = new Date();
        if (c.startDate && c.startDate.toDate() > now) {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "Coupon not active yet"
          );
        }
        const end = c.expiryDate || c.endDate;
        if (end && end.toDate() < now) {
          throw new functions.https.HttpsError(
            "failed-precondition",
            "Coupon has expired"
          );
        }
        const usageLimit = c.usageLimit as number | undefined;
        const usageCount = (c.usageCount as number) || 0;
        if (usageLimit != null && usageCount >= usageLimit) {
          throw new functions.https.HttpsError(
            "resource-exhausted",
            "Coupon usage limit reached"
          );
        }

        const nights = nightCount(checkIn, checkOut);
        const pricePerNight = Number(room.pricePerNight) || 0;
        const previewSub =
          pricePerNight * nights + servicesTotal;
        const minSpend = Number(c.minimumSpend) || 0;
        if (previewSub < minSpend) {
          throw new functions.https.HttpsError(
            "failed-precondition",
            `Minimum spend of ${minSpend} required`
          );
        }

        couponId = cDoc.id;
        if (c.discountType === "fixed") {
          discountFixed = Number(c.discountValue) || 0;
        } else {
          discountPercent = Number(c.discountValue) || 0;
        }

        // Atomic usage increment inside transaction
        tx.update(cDoc.ref, {
          usageCount: admin.firestore.FieldValue.increment(1),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      const nights = nightCount(checkIn, checkOut);
      const pricePerNight = Number(room.pricePerNight) || 0;
      const pricing = calcPrice(
        pricePerNight,
        nights,
        servicesTotal,
        discountPercent,
        discountFixed
      );

      const bookingRef = db.collection("bookings").doc();
      const bookingCode = `BK${Date.now().toString().slice(-8)}`;

      const bookingData = {
        bookingCode,
        guestId: uid,
        guestName,
        guestEmail,
        guestPhone: data.guestPhone || userData.phone || null,
        roomId: data.roomId,
        roomNumber: room.roomNumber || "",
        roomName: room.name || "",
        checkIn: admin.firestore.Timestamp.fromDate(checkIn),
        checkOut: admin.firestore.Timestamp.fromDate(checkOut),
        numberOfGuests: guestCount,
        numberOfNights: pricing.nights,
        roomPrice: pricing.roomCharges,
        taxes: pricing.tax,
        serviceFee: pricing.serviceFee,
        discount: pricing.discount,
        totalPrice: pricing.grandTotal,
        status: "pending",
        paymentStatus: "pending",
        specialRequests: data.specialRequests || null,
        promoCode: data.promoCode ? data.promoCode.toUpperCase() : null,
        couponId,
        serviceIds: data.serviceIds || [],
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      tx.set(bookingRef, bookingData);

      // Room → reserved if currently available
      if (roomStatus === "available") {
        tx.update(roomRef, {
          status: "reserved",
          isAvailable: false,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      return {
        bookingId: bookingRef.id,
        bookingCode,
        pricing,
      };
    });

    // Notification (outside transaction)
    await db.collection("notifications").add({
      userId: uid,
      title: "Booking Created",
      body: `Your booking ${result.bookingCode} is pending confirmation.`,
      type: "bookingConfirmed",
      isRead: false,
      data: { bookingId: result.bookingId, bookingCode: result.bookingCode },
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await writeAudit({
      actorId: uid,
      action: "booking.create",
      entityType: "booking",
      entityId: result.bookingId,
      metadata: {
        bookingCode: result.bookingCode,
        roomId: data.roomId,
        total: result.pricing.grandTotal,
      },
    });

    return {
      success: true,
      bookingId: result.bookingId,
      bookingCode: result.bookingCode,
      pricing: result.pricing,
    };
  }
);

// ── Health ───────────────────────────────────────────────────

export const health = functions.https.onRequest((_req, res) => {
  res.json({ ok: true, service: "luxestay-functions" });
});
