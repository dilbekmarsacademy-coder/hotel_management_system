import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/booking_providers.dart';

class BookingDateScreen extends ConsumerStatefulWidget {
  const BookingDateScreen({super.key});

  @override
  ConsumerState<BookingDateScreen> createState() => _BookingDateScreenState();
}

class _BookingDateScreenState extends ConsumerState<BookingDateScreen> {
  DateTime _focusedDay = DateTime.now().add(const Duration(days: 1));
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  int _adults = 1;
  int _children = 0;

  @override
  void initState() {
    super.initState();
    final flow = ref.read(bookingFlowProvider);
    _rangeStart = flow.checkIn;
    _rangeEnd = flow.checkOut;
    _adults = flow.adults;
    _children = flow.children;
  }

  @override
  Widget build(BuildContext context) {
    final flow = ref.watch(bookingFlowProvider);
    final nights = _rangeStart != null && _rangeEnd != null
        ? _rangeEnd!.difference(_rangeStart!).inDays
        : 0;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Select Dates'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (flow.selectedRoom != null) ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.lightGrey),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.hotel, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              flow.selectedRoom!.name,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Text(
                            '\$${flow.selectedRoom!.pricePerNight.toStringAsFixed(0)}/night',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    'Check-in & Check-out',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      rangeStartDay: _rangeStart,
                      rangeEndDay: _rangeEnd,
                      rangeSelectionMode: RangeSelectionMode.enforced,
                      calendarFormat: CalendarFormat.month,
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                      ),
                      calendarStyle: CalendarStyle(
                        rangeHighlightColor:
                            AppColors.secondary.withOpacity(0.2),
                        rangeStartDecoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        rangeEndDecoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      onRangeSelected: (start, end, focused) {
                        setState(() {
                          _rangeStart = start;
                          _rangeEnd = end;
                          _focusedDay = focused;
                        });
                      },
                      onPageChanged: (focused) {
                        _focusedDay = focused;
                      },
                    ),
                  ),
                  if (nights > 0) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        '$nights night${nights > 1 ? 's' : ''} selected',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.secondary,
                            ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Text(
                    'Guests',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _GuestCounter(
                    label: 'Adults',
                    value: _adults,
                    min: 1,
                    max: 6,
                    onChanged: (v) => setState(() => _adults = v),
                  ),
                  const SizedBox(height: 12),
                  _GuestCounter(
                    label: 'Children',
                    value: _children,
                    min: 0,
                    max: 4,
                    onChanged: (v) => setState(() => _children = v),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _rangeStart != null &&
                        _rangeEnd != null &&
                        nights > 0
                    ? () {
                        ref.read(bookingFlowProvider.notifier).setDates(
                              _rangeStart!,
                              _rangeEnd!,
                            );
                        ref.read(bookingFlowProvider.notifier).setGuests(
                              adults: _adults,
                              children: _children,
                            );
                        context.push('/guest/booking/guest-info');
                      }
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestCounter extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _GuestCounter({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          const Spacer(),
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.primary,
          ),
          Text(
            '$value',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
