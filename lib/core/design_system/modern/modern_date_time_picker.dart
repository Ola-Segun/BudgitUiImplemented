import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'modern_design_constants.dart';

/// ModernDateTimePicker Widget
/// Date and time selection with icon indicators
/// Two side-by-side buttons, Light gray background (#F5F5F5)
/// Rounded corners (12px), Icon + text layout, Height: 48px
class ModernDateTimePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? selectedTime;
  final ValueChanged<DateTime?>? onDateChanged;
  final ValueChanged<TimeOfDay?>? onTimeChanged;
  final bool showDate;
  final bool showTime;

  const ModernDateTimePicker({
    super.key,
    this.selectedDate,
    this.selectedTime,
    this.onDateChanged,
    this.onTimeChanged,
    this.showDate = true,
    this.showTime = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showDate) ...[
          Expanded(
            child: Semantics(
              label: 'Select date',
              button: true,
              value: selectedDate != null
                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                  : 'No date selected',
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    onDateChanged?.call(picked);
                  }
                },
                child: Container(
                  height: 48.0,
                  padding: const EdgeInsets.symmetric(horizontal: spacing_md),
                  decoration: BoxDecoration(
                    color: ModernColors.primaryGray,
                    borderRadius: BorderRadius.circular(radius_md),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: ModernColors.textSecondary,
                      ),
                      const SizedBox(width: spacing_sm),
                      Expanded(
                        child: Text(
                          selectedDate != null
                              ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                              : 'Today',
                          style: ModernTypography.bodyLarge.copyWith(
                            color: selectedDate != null
                                ? ModernColors.textPrimary
                                : ModernColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (showTime) const SizedBox(width: spacing_md),
        ],
        if (showTime) ...[
          Expanded(
            child: Semantics(
              label: 'Select time',
              button: true,
              value: selectedTime != null
                  ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')} ${selectedTime!.period.name}'
                  : 'No time selected',
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    onTimeChanged?.call(picked);
                  }
                },
                child: Container(
                  height: 48.0,
                  padding: const EdgeInsets.symmetric(horizontal: spacing_md),
                  decoration: BoxDecoration(
                    color: ModernColors.primaryGray,
                    borderRadius: BorderRadius.circular(radius_md),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20,
                        color: ModernColors.textSecondary,
                      ),
                      const SizedBox(width: spacing_sm),
                      Expanded(
                        child: Text(
                          selectedTime != null
                              ? '${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')} ${selectedTime!.period.name.toUpperCase()}'
                              : '12:36 PM',
                          style: ModernTypography.bodyLarge.copyWith(
                            color: selectedTime != null
                                ? ModernColors.textPrimary
                                : ModernColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}