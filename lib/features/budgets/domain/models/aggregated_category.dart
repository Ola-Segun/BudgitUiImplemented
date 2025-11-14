/// Shared model for aggregated category data used across budget components
class AggregatedCategory {
  const AggregatedCategory({
    required this.categoryId,
    required this.totalSpent,
    required this.totalBudget,
    required this.status,
  });

  final String categoryId;
  final double totalSpent;
  final double totalBudget;
  final int status;

  double get percentage => totalBudget > 0 ? (totalSpent / totalBudget) : 0.0;
  bool get isOverBudget => totalSpent > totalBudget;
}