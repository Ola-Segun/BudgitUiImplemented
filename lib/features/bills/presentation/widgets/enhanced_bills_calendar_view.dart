import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/bill.dart';
import '../theme/bills_theme_extended.dart';

/// Enhanced calendar view for bills with dots on due dates
class EnhancedBillsCalendarView extends StatefulWidget {
  const EnhancedBillsCalendarView({
    super.key,
    required this.bills,
    required this.selectedDate,
    required this.onDateSelected,
    required this.onBillTap,
  });

  final List<Bill> bills;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<Bill> onBillTap;

  @override
  State<EnhancedBillsCalendarView> createState() => _EnhancedBillsCalendarViewState();
}

class _EnhancedBillsCalendarViewState extends State<EnhancedBillsCalendarView> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDate;
    _selectedDay = widget.selectedDate;
  }

  @override
  void didUpdateWidget(EnhancedBillsCalendarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      _selectedDay = widget.selectedDate;
      _focusedDay = widget.selectedDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Calendar Header
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
            vertical: AppDimensions.screenPaddingV,
          ),
          child: Row(
            children: [
              Text(
                'Bill Calendar',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BillsThemeExtended.billChipRadius,
                  border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Paid',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.circle,
                      size: 12,
                      color: BillsThemeExtended.billStatusOverdue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Unpaid',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BillsThemeExtended.billStatusOverdue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Calendar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              widget.onDateSelected(selectedDay);
              HapticFeedback.lightImpact();
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: BillsThemeExtended.billStatsPrimary,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: BillsThemeExtended.billStatsPrimary,
                fontWeight: FontWeight.bold,
              ),
              selectedTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              weekendTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              outsideTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              formatButtonDecoration: BoxDecoration(
                color: BillsThemeExtended.billStatsPrimary.withValues(alpha: 0.1),
                borderRadius: BillsThemeExtended.billChipRadius,
              ),
              formatButtonTextStyle: TextStyle(
                color: BillsThemeExtended.billStatsPrimary,
                fontWeight: FontWeight.w600,
              ),
              titleCentered: true,
              titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final billsForDate = _getBillsForDate(date);
                if (billsForDate.isEmpty) return null;

                return Positioned(
                  bottom: 1,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: billsForDate.map((bill) {
                      return Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: _getBillColor(bill),
                          shape: BoxShape.circle,
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Bills for selected date
        Expanded(
          child: _buildBillsForSelectedDate(),
        ),
      ],
    );
  }

  List<Bill> _getBillsForDate(DateTime date) {
    return widget.bills.where((bill) {
      return isSameDay(bill.dueDate, date);
    }).toList();
  }

  Color _getBillColor(Bill bill) {
    // Check if bill is paid for the current month
    // This is a simplified check - in a real app you'd check payment history
    final now = DateTime.now();
    final billDate = bill.dueDate ?? now;

    // For demo purposes, assume bills with even IDs are paid
    final isPaid = bill.id.hashCode % 2 == 0;

    return isPaid
        ? AppColors.success
        : BillsThemeExtended.billStatusOverdue;
  }

  Widget _buildBillsForSelectedDate() {
    final billsForDate = _getBillsForDate(_selectedDay);

    if (billsForDate.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
          child: Text(
            'Bills for ${DateFormat('MMM d, yyyy').format(_selectedDay)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.screenPaddingH),
            itemCount: billsForDate.length,
            itemBuilder: (context, index) {
              final bill = billsForDate[index];
              return _buildBillCard(bill, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No bills due on this date',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Select another date to see bills',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBillCard(Bill bill, int index) {
    final isPaid = bill.id.hashCode % 2 == 0; // Demo logic

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getBillColor(bill).withValues(alpha: 0.1),
          child: Icon(
            Icons.receipt,
            color: _getBillColor(bill),
          ),
        ),
        title: Text(bill.name),
        subtitle: Text(
          '\$${bill.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isPaid
                ? AppColors.success.withValues(alpha: 0.1)
                : BillsThemeExtended.billStatusOverdue.withValues(alpha: 0.1),
            borderRadius: BillsThemeExtended.billChipRadius,
          ),
          child: Text(
            isPaid ? 'Paid' : 'Unpaid',
            style: TextStyle(
              color: isPaid
                  ? AppColors.success
                  : BillsThemeExtended.billStatusOverdue,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () => widget.onBillTap(bill),
      ),
    ).animate(delay: (50 * index).ms)
      .fadeIn(duration: BillsThemeExtended.billAnimationNormal)
      .slideY(begin: 0.1, duration: BillsThemeExtended.billAnimationNormal);
  }
}