import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/models/enums.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/onboarding_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/role_selection_screen.dart';
import '../features/guest/screens/guest_shell.dart';
import '../features/guest/screens/room_list_screen.dart';
import '../features/guest/screens/room_details_screen.dart';
import '../features/guest/screens/booking_date_screen.dart';
import '../features/guest/screens/booking/guest_info_screen.dart';
import '../features/guest/screens/booking/booking_summary_screen.dart';
import '../features/guest/screens/booking/payment_screen.dart';
import '../features/guest/screens/booking/booking_success_screen.dart';
import '../features/guest/screens/my_bookings_screen.dart';
import '../features/guest/screens/booking_details_screen.dart';
import '../features/guest/screens/services/services_screen.dart';
import '../features/guest/screens/restaurant/restaurant_home_screen.dart';
import '../features/guest/screens/restaurant/cart_screen.dart';
import '../features/guest/screens/restaurant/checkout_screen.dart';
import '../features/guest/screens/restaurant/order_confirmation_screen.dart';
import '../features/guest/screens/restaurant/order_tracking_screen.dart';
import '../features/guest/screens/restaurant/order_history_screen.dart';
import '../features/guest/screens/favorites/favorites_screen.dart';
import '../features/guest/screens/favorites/compare_rooms_screen.dart';
import '../features/guest/screens/reviews/reviews_screen.dart';
import '../features/guest/screens/notifications/notifications_screen.dart';
import '../features/guest/screens/profile/profile_screen.dart';
import '../features/guest/screens/profile/edit_profile_screen.dart';
import '../features/guest/screens/profile/change_password_screen.dart';
import '../features/guest/screens/hotel/hotel_info_screen.dart';
import '../features/guest/screens/hotel/hotel_facilities_screen.dart';
import '../features/guest/screens/hotel/hotel_gallery_screen.dart';
import '../features/guest/screens/help/help_center_screen.dart';
import '../features/guest/screens/help/faq_screen.dart';
import '../features/guest/screens/help/contact_support_screen.dart';
import '../features/guest/screens/help/terms_screen.dart';
import '../features/guest/screens/help/privacy_policy_screen.dart';
import '../features/guest/screens/help/cancellation_policy_screen.dart';
import '../features/guest/screens/promotions/guest_promotions_screen.dart';
import '../features/guest/screens/loyalty/loyalty_history_screen.dart';
import '../features/admin/screens/admin_shell.dart';
import '../features/admin/screens/rooms/add_edit_room_screen.dart';
import '../features/admin/screens/housekeeping/housekeeping_dashboard_screen.dart';
import '../features/admin/screens/maintenance/maintenance_dashboard_screen.dart';
import '../features/admin/screens/restaurant/admin_restaurant_dashboard.dart';
import '../features/admin/screens/payments/admin_payment_dashboard.dart';
import '../features/admin/screens/reports/admin_reports_dashboard.dart';
import '../features/admin/screens/analytics/analytics_dashboard_screen.dart';
import '../features/admin/screens/analytics/revenue_analytics_screen.dart';
import '../features/admin/screens/analytics/occupancy_analytics_screen.dart';
import '../features/admin/screens/analytics/booking_trends_screen.dart';
import '../features/admin/screens/analytics/guest_analytics_screen.dart';
import '../features/admin/screens/analytics/room_analytics_screen.dart';
import '../features/admin/screens/analytics/restaurant_analytics_screen.dart';
import '../features/admin/screens/analytics/payment_analytics_screen.dart';
import '../features/admin/screens/analytics/staff_analytics_screen.dart';
import '../features/admin/screens/analytics/housekeeping_analytics_screen.dart';
import '../features/admin/screens/reports/revenue_report_screen.dart';
import '../features/admin/screens/reports/occupancy_report_screen.dart';
import '../features/admin/screens/reports/booking_report_screen.dart';
import '../features/admin/screens/reports/guest_report_screen.dart';
import '../features/admin/screens/reports/cancellation_report_screen.dart';
import '../features/admin/screens/reception/reception_dashboard_screen.dart';
import '../features/admin/screens/reception/todays_arrivals_screen.dart';
import '../features/admin/screens/reception/todays_departures_screen.dart';
import '../features/admin/screens/reception/check_in_queue_screen.dart';
import '../features/admin/screens/reception/check_out_queue_screen.dart';
import '../features/admin/screens/reception/walk_in_booking_screen.dart';
import '../features/admin/screens/rooms/room_status_board_screen.dart';
import '../features/admin/screens/rooms/available_rooms_screen.dart';
import '../features/admin/screens/rooms/occupied_rooms_screen.dart';
import '../features/admin/screens/rooms/reserved_rooms_screen.dart';
import '../features/admin/screens/rooms/cleaning_rooms_screen.dart';
import '../features/admin/screens/rooms/maintenance_rooms_screen.dart';
import '../features/admin/screens/invoices/invoice_list_screen.dart';
import '../features/admin/screens/promotions/promotions_list_screen.dart';
import '../features/admin/screens/coupons/coupon_list_screen.dart';
import '../features/admin/screens/coupons/add_edit_coupon_screen.dart';
import '../features/admin/screens/loyalty/loyalty_dashboard_screen.dart';
import '../features/admin/screens/settings/hotel_settings_screen.dart';
import '../features/admin/screens/calendar/booking_calendar_screen.dart';
import '../features/admin/screens/staff/staff_schedule_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', builder: (c, s) => const ForgotPasswordScreen()),
      GoRoute(path: '/role-selection', builder: (c, s) => const RoleSelectionScreen()),

      GoRoute(
        path: '/guest',
        builder: (c, s) => const GuestShell(),
        routes: [
          GoRoute(path: 'rooms', builder: (c, s) => const RoomListScreen()),
          GoRoute(
            path: 'rooms/:id',
            builder: (c, s) => RoomDetailsScreen(roomId: s.pathParameters['id']!),
          ),
          GoRoute(path: 'booking/dates', builder: (c, s) => const BookingDateScreen()),
          GoRoute(path: 'booking/guest-info', builder: (c, s) => const GuestInfoScreen()),
          GoRoute(path: 'booking/summary', builder: (c, s) => const BookingSummaryScreen()),
          GoRoute(path: 'booking/payment', builder: (c, s) => const PaymentScreen()),
          GoRoute(
            path: 'booking/success',
            builder: (c, s) => BookingSuccessScreen(bookingId: s.uri.queryParameters['id']),
          ),
          GoRoute(path: 'bookings', builder: (c, s) => const MyBookingsScreen()),
          GoRoute(
            path: 'bookings/:id',
            builder: (c, s) => BookingDetailsScreen(bookingId: s.pathParameters['id']!),
          ),
          GoRoute(path: 'services', builder: (c, s) => const ServicesScreen()),
          GoRoute(path: 'restaurant', builder: (c, s) => const RestaurantHomeScreen()),
          GoRoute(path: 'restaurant/cart', builder: (c, s) => const CartScreen()),
          GoRoute(path: 'restaurant/checkout', builder: (c, s) => const CheckoutScreen()),
          GoRoute(
            path: 'restaurant/order-confirmation',
            builder: (c, s) => OrderConfirmationScreen(orderId: s.uri.queryParameters['id'] ?? 'local'),
          ),
          GoRoute(
            path: 'restaurant/order-tracking',
            builder: (c, s) => OrderTrackingScreen(orderId: s.uri.queryParameters['id'] ?? 'local'),
          ),
          GoRoute(path: 'restaurant/history', builder: (c, s) => const OrderHistoryScreen()),
          GoRoute(path: 'favorites', builder: (c, s) => const FavoritesScreen()),
          GoRoute(path: 'compare', builder: (c, s) => const CompareRoomsScreen()),
          GoRoute(path: 'reviews', builder: (c, s) => const ReviewsScreen()),
          GoRoute(path: 'notifications', builder: (c, s) => const NotificationsScreen()),
          GoRoute(path: 'profile', builder: (c, s) => const ProfileScreen()),
          GoRoute(path: 'profile/edit', builder: (c, s) => const EditProfileScreen()),
          GoRoute(path: 'profile/change-password', builder: (c, s) => const ChangePasswordScreen()),
          GoRoute(path: 'profile/help', builder: (c, s) => const HelpCenterScreen()),
          GoRoute(path: 'profile/faq', builder: (c, s) => const FaqScreen()),
          GoRoute(path: 'profile/contact', builder: (c, s) => const ContactSupportScreen()),
          GoRoute(path: 'profile/terms', builder: (c, s) => const TermsScreen()),
          GoRoute(path: 'profile/privacy', builder: (c, s) => const PrivacyPolicyScreen()),
          GoRoute(path: 'profile/about', builder: (c, s) => const HotelInfoScreen()),
          GoRoute(path: 'hotel/info', builder: (c, s) => const HotelInfoScreen()),
          GoRoute(path: 'hotel/facilities', builder: (c, s) => const HotelFacilitiesScreen()),
          GoRoute(path: 'hotel/gallery', builder: (c, s) => const HotelGalleryScreen()),
          GoRoute(path: 'hotel/cancellation', builder: (c, s) => const CancellationPolicyScreen()),
          GoRoute(path: 'promotions', builder: (c, s) => const GuestPromotionsScreen()),
          GoRoute(path: 'loyalty', builder: (c, s) => const LoyaltyHistoryScreen()),
          GoRoute(path: 'help/faq', builder: (c, s) => const FaqScreen()),
          GoRoute(path: 'help/contact', builder: (c, s) => const ContactSupportScreen()),
        ],
      ),

      GoRoute(
        path: '/admin',
        builder: (c, s) => const AdminShell(),
        routes: [
          GoRoute(path: 'rooms/add', builder: (c, s) => const AddEditRoomScreen()),
          GoRoute(
            path: 'rooms/:id',
            builder: (c, s) => AddEditRoomScreen(roomId: s.pathParameters['id']),
          ),
          GoRoute(path: 'housekeeping', builder: (c, s) => const HousekeepingDashboardScreen()),
          GoRoute(path: 'maintenance', builder: (c, s) => const MaintenanceDashboardScreen()),
          GoRoute(path: 'restaurant', builder: (c, s) => const AdminRestaurantDashboard()),
          GoRoute(path: 'payments', builder: (c, s) => const AdminPaymentDashboard()),
          GoRoute(path: 'reports', builder: (c, s) => const AdminReportsDashboard()),
          GoRoute(path: 'analytics', builder: (c, s) => const AnalyticsDashboardScreen()),
          GoRoute(path: 'analytics/revenue', builder: (c, s) => const RevenueAnalyticsScreen()),
          GoRoute(path: 'analytics/occupancy', builder: (c, s) => const OccupancyAnalyticsScreen()),
          GoRoute(path: 'analytics/bookings', builder: (c, s) => const BookingTrendsScreen()),
          GoRoute(path: 'analytics/guests', builder: (c, s) => const GuestAnalyticsScreen()),
          GoRoute(path: 'analytics/rooms', builder: (c, s) => const RoomAnalyticsScreen()),
          GoRoute(path: 'analytics/restaurant', builder: (c, s) => const RestaurantAnalyticsScreen()),
          GoRoute(path: 'analytics/payments', builder: (c, s) => const PaymentAnalyticsScreen()),
          GoRoute(path: 'analytics/staff', builder: (c, s) => const StaffAnalyticsScreen()),
          GoRoute(path: 'analytics/housekeeping', builder: (c, s) => const HousekeepingAnalyticsScreen()),
          GoRoute(path: 'reports/revenue', builder: (c, s) => const RevenueReportScreen()),
          GoRoute(path: 'reports/occupancy', builder: (c, s) => const OccupancyReportScreen()),
          GoRoute(path: 'reports/bookings', builder: (c, s) => const BookingReportScreen()),
          GoRoute(path: 'reports/guests', builder: (c, s) => const GuestReportScreen()),
          GoRoute(path: 'reports/cancellations', builder: (c, s) => const CancellationReportScreen()),
          GoRoute(path: 'reception', builder: (c, s) => const ReceptionDashboardScreen()),
          GoRoute(path: 'reception/arrivals', builder: (c, s) => const TodaysArrivalsScreen()),
          GoRoute(path: 'reception/departures', builder: (c, s) => const TodaysDeparturesScreen()),
          GoRoute(path: 'reception/check-in', builder: (c, s) => const CheckInQueueScreen()),
          GoRoute(path: 'reception/check-out', builder: (c, s) => const CheckOutQueueScreen()),
          GoRoute(path: 'reception/walk-in', builder: (c, s) => const WalkInBookingScreen()),
          GoRoute(path: 'rooms/status', builder: (c, s) => const RoomStatusBoardScreen()),
          GoRoute(path: 'rooms/available', builder: (c, s) => const AvailableRoomsScreen()),
          GoRoute(path: 'rooms/occupied', builder: (c, s) => const OccupiedRoomsScreen()),
          GoRoute(path: 'rooms/reserved', builder: (c, s) => const ReservedRoomsScreen()),
          GoRoute(path: 'rooms/cleaning', builder: (c, s) => const CleaningRoomsScreen()),
          GoRoute(path: 'rooms/maintenance', builder: (c, s) => const MaintenanceRoomsScreen()),
          GoRoute(path: 'invoices', builder: (c, s) => const InvoiceListScreen()),
          GoRoute(path: 'promotions', builder: (c, s) => const PromotionsListScreen()),
          GoRoute(path: 'coupons', builder: (c, s) => const CouponListScreen()),
          GoRoute(path: 'coupons/add', builder: (c, s) => const AddEditCouponScreen()),
          GoRoute(
            path: 'coupons/:id',
            builder: (c, s) => AddEditCouponScreen(couponId: s.pathParameters['id']),
          ),
          GoRoute(path: 'loyalty', builder: (c, s) => const LoyaltyDashboardScreen()),
          GoRoute(path: 'settings', builder: (c, s) => const HotelSettingsScreen()),
          GoRoute(path: 'calendar', builder: (c, s) => const BookingCalendarScreen()),
          GoRoute(path: 'staff/schedule', builder: (c, s) => const StaffScheduleScreen()),
        ],
      ),
    ],
  );
});

final authStateProvider = StateProvider<UserRole?>((ref) => null);
