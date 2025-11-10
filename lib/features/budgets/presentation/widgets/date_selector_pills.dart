import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_typography_extended.dart';

/// A horizontal scrollable date selector with pill-style buttons.
/// Shows dates with day numbers and abbreviated day names.
class DateSelectorPills extends StatefulWidget {
  const DateSelectorPills({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.selectedDate,
    required this.onDateSelected,
    this.numberOfDays = 7,
  });

  /// Start date of the range
  final DateTime startDate;

  /// End date of the range
  final DateTime endDate;

  /// Currently selected date
  final DateTime selectedDate;

  /// Callback when a date is selected
  final ValueChanged<DateTime> onDateSelected;

  /// Number of days to display (for demo purposes)
  final int numberOfDays;

  @override
  State<DateSelectorPills> createState() => _DateSelectorPillsState();
}

class _DateSelectorPillsState extends State<DateSelectorPills> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Scroll to selected date after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDate();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDate() {
    final selectedIndex = _getSelectedDateIndex();
    if (selectedIndex != -1) {
      final scrollOffset = (selectedIndex * 70.0) - (MediaQuery.of(context).size.width / 2) + 35;
      _scrollController.animateTo(
        scrollOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  int _getSelectedDateIndex() {
    final dates = _getDateRange();
    return dates.indexWhere((date) => _isSameDay(date, widget.selectedDate));
  }

  List<DateTime> _getDateRange() {
    final dates = <DateTime>[];
    var currentDate = widget.startDate;

    while (currentDate.isBefore(widget.endDate) || _isSameDay(currentDate, widget.endDate)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return _isSameDay(date, now);
  }

  @override
  Widget build(BuildContext context) {
    final dates = _getDateRange();

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _isSameDay(date, widget.selectedDate);
          final isToday = _isToday(date);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _DatePill(
              date: date,
              isSelected: isSelected,
              isToday: isToday,
              onTap: () {
                HapticFeedback.selectionClick();
                widget.onDateSelected(date);
              },
            ),
          );
        },
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 62,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColorsExtended.pillBgSelected
              : AppColorsExtended.pillBgUnselected,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('dd').format(date),
              style: AppTypographyExtended.datePillDay.copyWith(
                color: isSelected ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('EEE').format(date),
              style: AppTypographyExtended.datePillLabel.copyWith(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.7)
                    : const Color(0xFF6B7280),
              ),
            ),
            if (isToday) ...[
              const SizedBox(height: 2),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : AppColorsExtended.budgetPrimary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}