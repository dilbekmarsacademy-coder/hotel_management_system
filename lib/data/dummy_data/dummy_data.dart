import '../models/enums.dart';
import '../models/user_model.dart';
import '../models/room_model.dart';
import '../models/booking_model.dart';
import '../models/staff_model.dart';
import '../models/menu_item_model.dart';
import '../models/service_model.dart';
import '../models/notification_model.dart';
import '../models/payment_model.dart';
import '../models/review_model.dart';

class DummyData {
  static final DateTime _now = DateTime.now();

  // ==================== USERS / GUESTS ====================
  static final List<UserModel> guests = List.generate(30, (i) {
    final firstNames = [
      'James', 'Emily', 'Michael', 'Sophia', 'William', 'Olivia', 'Benjamin',
      'Ava', 'Lucas', 'Isabella', 'Henry', 'Mia', 'Alexander', 'Charlotte',
      'Daniel', 'Amelia', 'Matthew', 'Harper', 'Samuel', 'Evelyn',
      'David', 'Abigail', 'Joseph', 'Emily', 'Thomas', 'Elizabeth',
      'Charles', 'Sofia', 'Christopher', 'Avery'
    ];
    final lastNames = [
      'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller',
      'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez',
      'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin',
      'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark',
      'Ramirez', 'Lewis', 'Robinson'
    ];
    final countries = [
      'United States', 'United Kingdom', 'Canada', 'Australia', 'Germany',
      'France', 'Japan', 'South Korea', 'UAE', 'Singapore', 'Italy', 'Spain'
    ];
    return UserModel(
      id: 'guest_${i + 1}',
      email: '${firstNames[i].toLowerCase()}.${lastNames[i].toLowerCase()}@email.com',
      firstName: firstNames[i],
      lastName: lastNames[i],
      phone: '+1${5550000000 + i}',
      photoUrl: 'https://ui-avatars.com/api/?background=1a365d&color=d4af37&name=${firstNames[i]}+${lastNames[i]}',
      role: UserRole.guest,
      country: countries[i % countries.length],
      createdAt: _now.subtract(Duration(days: 100 - i)),
      updatedAt: _now.subtract(Duration(days: 10)),
      isEmailVerified: true,
      isActive: true,
    );
  });

  // ==================== STAFF ====================
  static final List<StaffModel> staff = [
    StaffModel(
      id: 'staff_1',
      userId: 'user_admin',
      firstName: 'Robert',
      lastName: 'Chen',
      email: 'robert.chen@grandluxe.com',
      phone: '+12125550101',
      position: UserRole.admin,
      department: 'Administration',
      hireDate: DateTime(2020, 3, 15),
      salary: 95000,
      status: StaffStatus.active,
      createdAt: DateTime(2020, 3, 15),
      updatedAt: _now,
    ),
    StaffModel(
      id: 'staff_2',
      userId: 'user_manager',
      firstName: 'Sarah',
      lastName: 'Mitchell',
      email: 'sarah.mitchell@grandluxe.com',
      phone: '+12125550102',
      position: UserRole.manager,
      department: 'Operations',
      hireDate: DateTime(2021, 6, 1),
      salary: 78000,
      status: StaffStatus.active,
      createdAt: DateTime(2021, 6, 1),
      updatedAt: _now,
    ),
    StaffModel(
      id: 'staff_3',
      userId: 'user_reception1',
      firstName: 'Lisa',
      lastName: 'Anderson',
      email: 'lisa.anderson@grandluxe.com',
      phone: '+12125550103',
      position: UserRole.receptionist,
      department: 'Front Desk',
      hireDate: DateTime(2022, 1, 10),
      salary: 48000,
      status: StaffStatus.active,
      createdAt: DateTime(2022, 1, 10),
      updatedAt: _now,
    ),
    StaffModel(
      id: 'staff_4',
      userId: 'user_reception2',
      firstName: 'Mark',
      lastName: 'Thompson',
      email: 'mark.thompson@grandluxe.com',
      phone: '+12125550104',
      position: UserRole.receptionist,
      department: 'Front Desk',
      hireDate: DateTime(2022, 4, 20),
      salary: 46000,
      status: StaffStatus.active,
      createdAt: DateTime(2022, 4, 20),
      updatedAt: _now,
    ),
    StaffModel(
      id: 'staff_5',
      userId: 'user_hk1',
      firstName: 'Maria',
      lastName: 'Santos',
      email: 'maria.santos@grandluxe.com',
      phone: '+12125550105',
      position: UserRole.housekeeping,
      department: 'Housekeeping',
      hireDate: DateTime(2021, 9, 5),
      salary: 42000,
      status: StaffStatus.active,
      createdAt: DateTime(2021, 9, 5),
      updatedAt: _now,
    ),
    StaffModel(
      id: 'staff_6',
      userId: 'user_hk2',
      firstName: 'Carlos',
      lastName: 'Rivera',
      email: 'carlos.rivera@grandluxe.com',
      phone: '+12125550106',
      position: UserRole.housekeeping,
      department: 'Housekeeping',
      hireDate: DateTime(2022, 2, 14),
      salary: 40000,
      status: StaffStatus.active,
      createdAt: DateTime(2022, 2, 14),
      updatedAt: _now,
    ),
    StaffModel(
      id: 'staff_7',
      userId: 'user_rest1',
      firstName: 'Chef Antonio',
      lastName: 'Romano',
      email: 'antonio.romano@grandluxe.com',
      phone: '+12125550107',
      position: UserRole.restaurantStaff,
      department: 'Restaurant',
      hireDate: DateTime(2020, 11, 1),
      salary: 62000,
      status: StaffStatus.active,
      createdAt: DateTime(2020, 11, 1),
      updatedAt: _now,
    ),
    StaffModel(
      id: 'staff_8',
      userId: 'user_rest2',
      firstName: 'Jessica',
      lastName: 'Park',
      email: 'jessica.park@grandluxe.com',
      phone: '+12125550108',
      position: UserRole.restaurantStaff,
      department: 'Restaurant',
      hireDate: DateTime(2023, 1, 15),
      salary: 38000,
      status: StaffStatus.active,
      createdAt: DateTime(2023, 1, 15),
      updatedAt: _now,
    ),
    StaffModel(
      id: 'staff_9',
      userId: 'user_maint1',
      firstName: 'James',
      lastName: 'Wilson',
      email: 'james.wilson@grandluxe.com',
      phone: '+12125550109',
      position: UserRole.maintenance,
      department: 'Maintenance',
      hireDate: DateTime(2021, 5, 20),
      salary: 52000,
      status: StaffStatus.active,
      createdAt: DateTime(2021, 5, 20),
      updatedAt: _now,
    ),
    StaffModel(
      id: 'staff_10',
      userId: 'user_maint2',
      firstName: 'Kevin',
      lastName: 'Brooks',
      email: 'kevin.brooks@grandluxe.com',
      phone: '+12125550110',
      position: UserRole.maintenance,
      department: 'Maintenance',
      hireDate: DateTime(2022, 8, 8),
      salary: 48000,
      status: StaffStatus.onLeave,
      createdAt: DateTime(2022, 8, 8),
      updatedAt: _now,
    ),
  ];

  // ==================== ROOMS (50+) ====================
  static final List<String> _amenitiesList = [
    'Wi-Fi', 'TV', 'Air Conditioning', 'Private Bathroom', 'Minibar',
    'Balcony', 'Jacuzzi', 'Room Service', 'Hair Dryer', 'Safe',
    'Coffee Machine', 'Work Desk', 'Iron', 'Bathrobe', 'Slippers'
  ];

  static final List<RoomModel> rooms = List.generate(50, (i) {
    final types = RoomType.values;
    final beds = BedType.values;
    final type = types[i % types.length];
    final basePrice = switch (type) {
      RoomType.standard => 189.0,
      RoomType.deluxe => 289.0,
      RoomType.suite => 499.0,
      RoomType.presidential => 1299.0,
      RoomType.family => 359.0,
      RoomType.executive => 389.0,
    };
    final floor = (i ~/ 10) + 1;
    final roomNum = '${floor}${100 + (i % 10)}';
    final statuses = RoomStatus.values;
    final status = i < 30
        ? RoomStatus.available
        : statuses[i % statuses.length];

    return RoomModel(
      id: 'room_${i + 1}',
      roomNumber: roomNum,
      name: '${type.displayName} ${roomNum}',
      type: type,
      description:
          'Elegant ${type.displayName.toLowerCase()} featuring premium furnishings, '
          'floor-to-ceiling windows with city views, and luxurious amenities. '
          'Perfect for both business and leisure travelers seeking comfort and sophistication.',
      pricePerNight: basePrice + (i % 5) * 20,
      capacity: type == RoomType.family
          ? 4
          : type == RoomType.presidential
              ? 6
              : type == RoomType.suite
                  ? 3
                  : 2,
      rating: 4.0 + (i % 10) / 10,
      reviewCount: 12 + i * 3,
      imageUrls: [
        'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800&q=80',
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800&q=80',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800&q=80',
        'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800&q=80',
      ],
      amenities: _amenitiesList.take(8 + (i % 5)).toList(),
      floor: floor,
      bedType: beds[i % beds.length],
      isAvailable: status == RoomStatus.available,
      status: status,
      sizeSqm: 28 + (type.index * 15) + (i % 10),
      isFeatured: i < 8,
      isPopular: i % 7 == 0,
      createdAt: _now.subtract(Duration(days: 365 - i)),
      updatedAt: _now.subtract(Duration(days: i % 30)),
    );
  });

  // ==================== BOOKINGS (50+) ====================
  static final List<BookingModel> bookings = List.generate(50, (i) {
    final guest = guests[i % guests.length];
    final room = rooms[i % rooms.length];
    final nights = 1 + (i % 5);
    final checkIn = _now.add(Duration(days: -20 + i));
    final checkOut = checkIn.add(Duration(days: nights));
    final roomTotal = room.pricePerNight * nights;
    final taxes = roomTotal * 0.12;
    final serviceFee = roomTotal * 0.05;
    final discount = i % 4 == 0 ? roomTotal * 0.1 : 0.0;
    final total = roomTotal + taxes + serviceFee - discount;

    final status = i < 15
        ? BookingStatus.confirmed
        : i < 25
            ? BookingStatus.checkedIn
            : i < 35
                ? BookingStatus.checkedOut
                : i < 42
                    ? BookingStatus.pending
                    : BookingStatus.cancelled;

    return BookingModel(
      id: 'booking_${i + 1}',
      bookingCode: 'GL${10000 + i}',
      guestId: guest.id,
      guestName: guest.fullName,
      guestEmail: guest.email,
      guestPhone: guest.phone,
      roomId: room.id,
      roomNumber: room.roomNumber,
      roomName: room.name,
      checkIn: checkIn,
      checkOut: checkOut,
      numberOfGuests: 1 + (i % room.capacity),
      numberOfNights: nights,
      roomPrice: room.pricePerNight,
      taxes: taxes,
      serviceFee: serviceFee,
      discount: discount,
      totalPrice: total,
      paymentStatus: status == BookingStatus.cancelled
          ? PaymentStatus.refunded
          : status == BookingStatus.pending
              ? PaymentStatus.pending
              : PaymentStatus.completed,
      status: status,
      specialRequests: i % 3 == 0 ? 'Late check-in requested. Extra pillows please.' : null,
      promoCode: i % 4 == 0 ? 'WELCOME10' : null,
      createdAt: checkIn.subtract(Duration(days: 7 + (i % 10))),
      updatedAt: _now.subtract(Duration(hours: i)),
    );
  });

  // ==================== MENU ITEMS (40+) ====================
  static final List<MenuItemModel> menuItems = [
    // Breakfast
    ...List.generate(8, (i) {
      final items = [
        ('Eggs Benedict', 'Poached eggs, hollandaise, English muffin, smoked salmon'),
        ('Belgian Waffles', 'Crispy waffles with fresh berries and maple syrup'),
        ('Avocado Toast', 'Sourdough, smashed avocado, poached egg, chili flakes'),
        ('Continental Breakfast', 'Pastries, juice, coffee, fresh fruit, yogurt'),
        ('Full English Breakfast', 'Eggs, bacon, sausage, beans, toast, mushrooms'),
        ('Greek Yogurt Parfait', 'Honey, granola, mixed berries'),
        ('Smoked Salmon Bagel', 'Cream cheese, capers, red onion'),
        ('Omelette of the Day', 'Chef\'s choice with fresh herbs and cheese'),
      ];
      return MenuItemModel(
        id: 'menu_bf_${i + 1}',
        name: items[i].$1,
        description: items[i].$2,
        category: 'Breakfast',
        price: 14.0 + i * 2.5,
        imageUrl: 'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=600',
        ingredients: ['Eggs', 'Bread', 'Butter'],
        rating: 4.3 + (i % 5) / 10,
        reviewCount: 20 + i * 5,
        isVegetarian: i == 2 || i == 5,
        preparationTimeMinutes: 15 + i,
        createdAt: _now.subtract(Duration(days: 100)),
        updatedAt: _now,
      );
    }),
    // Lunch
    ...List.generate(8, (i) {
      final items = [
        ('Caesar Salad', 'Romaine, parmesan, croutons, classic dressing'),
        ('Club Sandwich', 'Turkey, bacon, lettuce, tomato, mayo'),
        ('Grilled Salmon', 'Lemon butter, seasonal vegetables, quinoa'),
        ('Beef Burger', 'Angus beef, cheddar, caramelized onion, fries'),
        ('Pasta Primavera', 'Fresh vegetables, olive oil, parmesan'),
        ('Chicken Wrap', 'Grilled chicken, avocado, mixed greens'),
        ('Seafood Chowder', 'Creamy soup with fresh seafood and herbs'),
        ('Quinoa Bowl', 'Roasted vegetables, feta, tahini dressing'),
      ];
      return MenuItemModel(
        id: 'menu_ln_${i + 1}',
        name: items[i].$1,
        description: items[i].$2,
        category: 'Lunch',
        price: 18.0 + i * 3,
        imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600',
        rating: 4.4 + (i % 4) / 10,
        reviewCount: 30 + i * 4,
        isVegetarian: i == 0 || i == 4 || i == 7,
        preparationTimeMinutes: 20 + i,
        createdAt: _now.subtract(Duration(days: 100)),
        updatedAt: _now,
      );
    }),
    // Dinner
    ...List.generate(8, (i) {
      final items = [
        ('Filet Mignon', '8oz prime cut, red wine reduction, truffle mash'),
        ('Lobster Thermidor', 'Classic preparation with cognac cream sauce'),
        ('Duck Confit', 'Crispy skin, cherry gastrique, potato gratin'),
        ('Vegetarian Risotto', 'Wild mushrooms, aged parmesan, white truffle'),
        ('Sea Bass', 'Mediterranean style with olive, tomato, herbs'),
        ('Lamb Chops', 'Herb crusted, mint jelly, roasted vegetables'),
        ('Wagyu Steak', 'A5 grade, wasabi butter, seasonal sides'),
        ('Truffle Pasta', 'Handmade tagliatelle, black truffle, pecorino'),
      ];
      return MenuItemModel(
        id: 'menu_dn_${i + 1}',
        name: items[i].$1,
        description: items[i].$2,
        category: 'Dinner',
        price: 42.0 + i * 8,
        imageUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=600',
        rating: 4.6 + (i % 3) / 10,
        reviewCount: 45 + i * 6,
        isVegetarian: i == 3 || i == 7,
        preparationTimeMinutes: 30 + i * 2,
        createdAt: _now.subtract(Duration(days: 100)),
        updatedAt: _now,
      );
    }),
    // Drinks
    ...List.generate(8, (i) {
      final items = [
        ('Signature Cocktail', 'House special with premium spirits'),
        ('Vintage Wine Selection', 'Curated red or white by the glass'),
        ('Fresh Juice', 'Orange, apple, or mixed berry'),
        ('Espresso Martini', 'Vodka, coffee liqueur, fresh espresso'),
        ('Mocktail', 'Non-alcoholic seasonal creation'),
        ('Craft Beer', 'Local brewery selection'),
        ('Champagne', 'Glass of premium champagne'),
        ('Herbal Tea Selection', 'Calming evening blend'),
      ];
      return MenuItemModel(
        id: 'menu_dr_${i + 1}',
        name: items[i].$1,
        description: items[i].$2,
        category: 'Drinks',
        price: 8.0 + i * 3,
        imageUrl: 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d0b?w=600',
        rating: 4.5,
        reviewCount: 25 + i * 3,
        isVegetarian: true,
        preparationTimeMinutes: 5,
        createdAt: _now.subtract(Duration(days: 100)),
        updatedAt: _now,
      );
    }),
    // Desserts
    ...List.generate(8, (i) {
      final items = [
        ('Chocolate Fondant', 'Warm center, vanilla ice cream'),
        ('Crème Brûlée', 'Classic vanilla with caramelized sugar'),
        ('New York Cheesecake', 'Berry compote'),
        ('Tiramisu', 'Espresso-soaked ladyfingers, mascarpone'),
        ('Fruit Tart', 'Seasonal fruits, pastry cream'),
        ('Ice Cream Selection', 'Three scoops of artisan flavors'),
        ('Panna Cotta', 'Berry coulis'),
        ('Macarons', 'Assorted French macarons (6 pcs)'),
      ];
      return MenuItemModel(
        id: 'menu_ds_${i + 1}',
        name: items[i].$1,
        description: items[i].$2,
        category: 'Desserts',
        price: 12.0 + i * 1.5,
        imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600',
        rating: 4.7,
        reviewCount: 40 + i * 5,
        isVegetarian: true,
        preparationTimeMinutes: 10,
        createdAt: _now.subtract(Duration(days: 100)),
        updatedAt: _now,
      );
    }),
  ];

  // ==================== SERVICES (15+) ====================
  static final List<ServiceModel> services = [
    ServiceModel(
      id: 'svc_1',
      name: 'Airport Transfer',
      description: 'Private luxury car transfer to/from airport. Meet & greet service included.',
      category: 'Transport',
      price: 85.0,
      iconName: 'local_taxi',
      durationMinutes: 60,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_2',
      name: 'Spa Treatment',
      description: 'Full body massage and facial treatment in our award-winning spa.',
      category: 'Wellness',
      price: 180.0,
      iconName: 'spa',
      durationMinutes: 90,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_3',
      name: 'Gym Access',
      description: '24/7 access to state-of-the-art fitness center with personal trainer option.',
      category: 'Fitness',
      price: 0.0,
      iconName: 'fitness_center',
      durationMinutes: 120,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_4',
      name: 'Swimming Pool',
      description: 'Infinity pool with panoramic city views. Towels and lounge chairs provided.',
      category: 'Recreation',
      price: 0.0,
      iconName: 'pool',
      durationMinutes: 180,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_5',
      name: 'Laundry Service',
      description: 'Same-day laundry and dry cleaning. Express service available.',
      category: 'Housekeeping',
      price: 35.0,
      iconName: 'local_laundry_service',
      durationMinutes: 240,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_6',
      name: 'Room Service',
      description: '24-hour in-room dining from our full restaurant menu.',
      category: 'Dining',
      price: 15.0,
      iconName: 'room_service',
      durationMinutes: 45,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_7',
      name: 'Breakfast Buffet',
      description: 'Extensive international breakfast buffet at The Grand Restaurant.',
      category: 'Dining',
      price: 45.0,
      iconName: 'free_breakfast',
      durationMinutes: 90,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_8',
      name: 'Conference Room',
      description: 'Fully equipped meeting room with AV, Wi-Fi, and catering options.',
      category: 'Business',
      price: 250.0,
      iconName: 'meeting_room',
      durationMinutes: 240,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_9',
      name: 'Wake-up Call',
      description: 'Personalized wake-up call service.',
      category: 'Concierge',
      price: 0.0,
      iconName: 'alarm',
      durationMinutes: 5,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_10',
      name: 'Extra Bed',
      description: 'Additional rollaway bed for your room.',
      category: 'Room',
      price: 50.0,
      iconName: 'hotel',
      durationMinutes: 30,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_11',
      name: 'Valet Parking',
      description: 'Secure valet parking for the duration of your stay.',
      category: 'Transport',
      price: 45.0,
      iconName: 'local_parking',
      durationMinutes: 0,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_12',
      name: 'Babysitting',
      description: 'Professional babysitting service. Advance booking required.',
      category: 'Family',
      price: 40.0,
      iconName: 'child_care',
      durationMinutes: 240,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_13',
      name: 'City Tour',
      description: 'Private guided city tour with luxury vehicle.',
      category: 'Experience',
      price: 220.0,
      iconName: 'tour',
      durationMinutes: 240,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_14',
      name: 'Wine Tasting',
      description: 'Curated wine tasting experience with sommelier.',
      category: 'Experience',
      price: 95.0,
      iconName: 'wine_bar',
      durationMinutes: 90,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
    ServiceModel(
      id: 'svc_15',
      name: 'Late Checkout',
      description: 'Extend your checkout time until 4:00 PM (subject to availability).',
      category: 'Room',
      price: 75.0,
      iconName: 'schedule',
      durationMinutes: 0,
      createdAt: _now.subtract(Duration(days: 200)),
      updatedAt: _now,
    ),
  ];

  // ==================== NOTIFICATIONS (30+) ====================
  static final List<NotificationModel> notifications = List.generate(30, (i) {
    final types = NotificationType.values;
    final type = types[i % types.length];
    final titles = {
      NotificationType.bookingConfirmed: 'Booking Confirmed',
      NotificationType.bookingCancelled: 'Booking Cancelled',
      NotificationType.paymentReceived: 'Payment Received',
      NotificationType.checkInReminder: 'Check-in Reminder',
      NotificationType.checkOutReminder: 'Check-out Reminder',
      NotificationType.roomReady: 'Your Room is Ready',
      NotificationType.serviceCompleted: 'Service Completed',
      NotificationType.orderUpdate: 'Order Update',
      NotificationType.specialOffer: 'Special Offer Just for You',
      NotificationType.system: 'System Notification',
    };
    return NotificationModel(
      id: 'notif_${i + 1}',
      userId: guests[i % guests.length].id,
      title: titles[type] ?? 'Notification',
      body: 'This is a detailed notification message regarding your recent activity at The Grand Luxe Hotel. Reference #${1000 + i}.',
      type: type,
      isRead: i % 3 == 0,
      relatedId: i % 2 == 0 ? bookings[i % bookings.length].id : null,
      createdAt: _now.subtract(Duration(hours: i * 3)),
    );
  });

  // ==================== PAYMENTS (25+) ====================
  static final List<PaymentModel> payments = List.generate(25, (i) {
    final booking = bookings[i % bookings.length];
    final methods = PaymentMethod.values;
    return PaymentModel(
      id: 'pay_${i + 1}',
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}$i',
      bookingId: booking.id,
      guestId: booking.guestId,
      guestName: booking.guestName,
      amount: booking.totalPrice,
      method: methods[i % methods.length],
      status: i < 18 ? PaymentStatus.completed : PaymentStatus.values[i % PaymentStatus.values.length],
      createdAt: booking.createdAt.add(Duration(minutes: 5)),
      completedAt: i < 18 ? booking.createdAt.add(Duration(minutes: 10)) : null,
    );
  });

  // ==================== REVIEWS (25+) ====================
  static final List<ReviewModel> reviews = List.generate(25, (i) {
    final guest = guests[i % guests.length];
    final room = rooms[i % rooms.length];
    final comments = [
      'Absolutely stunning room with incredible views. Staff went above and beyond.',
      'Best hotel experience in the city. Will definitely return.',
      'Clean, luxurious, and the spa was exceptional.',
      'Great location and service. Breakfast buffet was outstanding.',
      'The suite exceeded all expectations. Highly recommend.',
      'Professional staff and beautiful amenities throughout.',
      'Perfect for a romantic getaway. Attention to detail is remarkable.',
      'Business trip made comfortable by the excellent facilities.',
    ];
    return ReviewModel(
      id: 'review_${i + 1}',
      guestId: guest.id,
      guestName: guest.fullName,
      guestPhotoUrl: guest.photoUrl,
      roomId: room.id,
      roomName: room.name,
      rating: 3.5 + (i % 15) / 10,
      comment: comments[i % comments.length],
      isApproved: true,
      createdAt: _now.subtract(Duration(days: 60 - i)),
      updatedAt: _now.subtract(Duration(days: 60 - i)),
    );
  });

  // Admin user for testing
  static final UserModel adminUser = UserModel(
    id: 'admin_1',
    email: 'admin@grandluxe.com',
    firstName: 'Robert',
    lastName: 'Chen',
    phone: '+12125550101',
    role: UserRole.admin,
    createdAt: DateTime(2020, 3, 15),
    updatedAt: _now,
    isEmailVerified: true,
    isActive: true,
  );

  static final UserModel testGuest = guests.first;
// Coupons for admin + booking validation demos
  static final List<CouponSeed> coupons = [
    CouponSeed(
      id: 'cpn_1',
      code: 'WELCOME10',
      description: 'Welcome discount for first booking',
      discountType: 'percentage',
      discountValue: 10,
      startDate: _now.subtract(const Duration(days: 30)),
      endDate: _now.add(const Duration(days: 180)),
      usageLimit: 500,
      usedCount: 42,
      isActive: true,
      minimumSpend: 100,
    ),
    CouponSeed(
      id: 'cpn_2',
      code: 'LUXE15',
      description: 'Luxury suite upgrade offer',
      discountType: 'percentage',
      discountValue: 15,
      startDate: _now.subtract(const Duration(days: 10)),
      endDate: _now.add(const Duration(days: 60)),
      usageLimit: 100,
      usedCount: 18,
      isActive: true,
      minimumSpend: 250,
    ),
    CouponSeed(
      id: 'cpn_3',
      code: 'SUMMER20',
      description: 'Summer special fixed discount',
      discountType: 'fixed',
      discountValue: 50,
      startDate: _now.subtract(const Duration(days: 5)),
      endDate: _now.add(const Duration(days: 90)),
      usageLimit: 200,
      usedCount: 55,
      isActive: true,
      minimumSpend: 200,
    ),
    CouponSeed(
      id: 'cpn_4',
      code: 'VIP25',
      description: 'VIP members exclusive',
      discountType: 'percentage',
      discountValue: 25,
      startDate: _now.subtract(const Duration(days: 90)),
      endDate: _now.add(const Duration(days: 30)),
      usageLimit: 50,
      usedCount: 50,
      isActive: false,
      minimumSpend: 300,
    ),
  ];

  static final List<PromoSeed> promotions = [
    PromoSeed(
      id: 'promo_1',
      title: 'Weekend Getaway',
      description: 'Enjoy 15% off weekend stays in Deluxe rooms.',
      discountType: 'percentage',
      discountValue: 15,
      startDate: _now.subtract(const Duration(days: 7)),
      endDate: _now.add(const Duration(days: 45)),
      isActive: true,
      promoCode: 'WEEKEND15',
    ),
    PromoSeed(
      id: 'promo_2',
      title: 'Spa & Stay Package',
      description: 'Book 2 nights and receive a complimentary spa treatment.',
      discountType: 'fixed',
      discountValue: 80,
      startDate: _now,
      endDate: _now.add(const Duration(days: 60)),
      isActive: true,
      promoCode: 'SPA80',
    ),
    PromoSeed(
      id: 'promo_3',
      title: 'Early Bird Special',
      description: 'Book 30 days in advance and save 20%.',
      discountType: 'percentage',
      discountValue: 20,
      startDate: _now.subtract(const Duration(days: 14)),
      endDate: _now.add(const Duration(days: 120)),
      isActive: true,
      promoCode: 'EARLY20',
    ),
  ];
}

class CouponSeed {
  final String id, code, description, discountType;
  final double discountValue, minimumSpend;
  final DateTime startDate, endDate;
  final int? usageLimit;
  final int usedCount;
  final bool isActive;

  const CouponSeed({
    required this.id,
    required this.code,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    this.usedCount = 0,
    this.isActive = true,
    this.minimumSpend = 0,
  });
}

class PromoSeed {
  final String id, title, description, discountType;
  final double discountValue;
  final DateTime startDate, endDate;
  final bool isActive;
  final String? promoCode;

  const PromoSeed({
    required this.id,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.promoCode,
  });
}

