import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_tokens.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/error_view.dart';

/// Template for list-based screens with grouping
///
/// Features:
/// - Grouped items with headers
/// - Search functionality
/// - Filter options
/// - Load more pagination
/// - Empty states
/// - Pull-to-refresh
///
/// Usage:
/// ```dart
/// ListScreenTemplate<Transaction>(
///   title: 'Transactions',
///   asyncValue: ref.watch(transactionsProvider),
///   groupBy: (t) => DateFormat('yyyy-MM-dd').format(t.date),
///   itemBuilder: (t) => TransactionTile(t),
///   headerBuilder: (date) => DateHeader(date),
///   onSearch: (query) => ref.read(searchProvider.notifier).state = query,
///   emptyStateBuilder: () => EmptyStatePattern(...),
/// )
/// ```
class ListScreenTemplate<T> extends StatefulWidget {
  const ListScreenTemplate({
    super.key,
    required this.title,
    required this.asyncValue,
    required this.groupBy,
    required this.itemBuilder,
    required this.headerBuilder,
    this.onSearch,
    this.onFilter,
    this.onLoadMore,
    this.hasMoreData = false,
    this.topWidget,
    this.emptyStateBuilder,
    this.showSearch = false,
  });

  final String title;
  final AsyncValue<List<T>> asyncValue;
  final dynamic Function(T item) groupBy;
  final Widget Function(T item) itemBuilder;
  final Widget Function(dynamic groupKey) headerBuilder;
  final ValueChanged<String>? onSearch;
  final VoidCallback? onFilter;
  final VoidCallback? onLoadMore;
  final bool hasMoreData;
  final Widget? topWidget;
  final Widget Function()? emptyStateBuilder;
  final bool showSearch;

  @override
  State<ListScreenTemplate<T>> createState() => _ListScreenTemplateState<T>();
}

class _ListScreenTemplateState<T> extends State<ListScreenTemplate<T>> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Content
            Expanded(
              child: widget.asyncValue.when(
                loading: () => const LoadingView(),
                error: (error, stack) => ErrorView(message: error.toString()),
                data: (items) => _buildList(context, items),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      decoration: BoxDecoration(
        color: ColorTokens.surfacePrimary,
        boxShadow: DesignTokens.elevationLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_isSearchActive && widget.showSearch) ...[
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isSearchActive = false;
                      _searchController.clear();
                    });
                    widget.onSearch?.call('');
                  },
                ),
              ],
              Expanded(
                child: _isSearchActive && widget.showSearch
                    ? _buildSearchField()
                    : Text(
                        widget.title,
                        style: TypographyTokens.heading3,
                      ),
              ),
              if (widget.showSearch && !_isSearchActive) ...[
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearchActive = true;
                    });
                  },
                ),
              ],
              if (widget.onFilter != null) ...[
                SizedBox(width: DesignTokens.spacing2),
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: widget.onFilter,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: ColorTokens.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: widget.onSearch,
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TypographyTokens.bodyMd.copyWith(
            color: ColorTokens.textTertiary,
          ),
          prefixIcon: const Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: DesignTokens.spacing4,
            vertical: DesignTokens.spacing3,
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, List<T> items) {
    if (items.isEmpty) {
      return widget.emptyStateBuilder?.call() ??
          const Center(child: Text('No items found'));
    }

    final groupedItems = _groupItems(items);

    return ListView.builder(
      padding: EdgeInsets.all(DesignTokens.screenPaddingH),
      itemCount: _calculateItemCount(groupedItems),
      itemBuilder: (context, index) => _buildListItem(context, index, groupedItems),
    );
  }

  Widget _buildListItem(
    BuildContext context,
    int index,
    Map<dynamic, List<T>> groupedItems,
  ) {
    int currentIndex = 0;

    // Top widget
    if (widget.topWidget != null && index == currentIndex++) {
      return Padding(
        padding: EdgeInsets.only(bottom: DesignTokens.sectionGapLg),
        child: widget.topWidget!,
      );
    }

    // Grouped items
    for (final entry in groupedItems.entries) {
      // Header
      if (index == currentIndex++) {
        return Padding(
          padding: EdgeInsets.only(bottom: DesignTokens.spacing3),
          child: widget.headerBuilder(entry.key),
        );
      }

      // Items
      for (final item in entry.value) {
        if (index == currentIndex++) {
          return Padding(
            padding: EdgeInsets.only(bottom: DesignTokens.listItemGap),
            child: widget.itemBuilder(item),
          );
        }
      }

      // Spacing between groups
      if (index == currentIndex++) {
        return SizedBox(height: DesignTokens.sectionGapMd);
      }
    }

    // Load more
    if (widget.hasMoreData && widget.onLoadMore != null) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: DesignTokens.spacing4),
        child: Center(
          child: TextButton.icon(
            onPressed: widget.onLoadMore,
            icon: const Icon(Icons.expand_more),
            label: const Text('Load More'),
            style: TextButton.styleFrom(
              foregroundColor: ColorTokens.teal500,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Map<dynamic, List<T>> _groupItems(List<T> items) {
    final Map<dynamic, List<T>> grouped = {};
    for (final item in items) {
      final key = widget.groupBy(item);
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  int _calculateItemCount(Map<dynamic, List<T>> groupedItems) {
    int count = widget.topWidget != null ? 1 : 0;
    for (final entry in groupedItems.entries) {
      count += 1 + entry.value.length + 1; // header + items + spacing
    }
    if (widget.hasMoreData && widget.onLoadMore != null) count++;
    return count;
  }
}