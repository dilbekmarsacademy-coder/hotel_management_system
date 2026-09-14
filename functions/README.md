# Cloud Functions (recommended for production booking)

Deploy a `createBooking` callable function that:

1. Verifies Auth
2. Runs a Firestore **transaction**:
   - Reads room doc
   - Queries overlapping active bookings for roomId
   - Rejects if maintenance or overlap
   - Writes booking
   - Updates room status
3. Increments coupon usageCount if applicable

Flutter client should call the callable when `AppConfig.kUseFirebaseData` is true.
Client-side `BookingTransactionService` remains as a safety net / Demo path.

```bash
cd functions
npm install
firebase deploy --only functions
```
