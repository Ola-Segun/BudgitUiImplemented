import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../color_tokens.dart';
import '../typography_tokens.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/error_view.dart';

/// Base template for all screens
///
/// Features:
/// - Consistent structure
/// - Automatic state handling (loading/error/empty)
/// - Pull-to-refresh support
/// - Floating action button support
/// - Safe area handling
///
/// Usage:
/// ```dart
/// BaseScreenTemplate<List<Transaction>>(
///   title: 'Transactions',
///   asyncValue: ref.watch(transactionsProvider),
///   onRefresh: () async => ref.refresh(transactionsProvider),
///   builder: (transactions) => TransactionList(transactions),
///   emptyStateBuilder: () => EmptyStatePattern(...),
///   floatingActionButton: FAB(...),
/// )
/// ```
class BaseScreenTemplate<T> extends StatelessWidget {
  const BaseScreenTemplate({
    super.key,
    required this.title,
    this.subtitle,
    this.headerActions = const [],
    required this.asyncValue,
    this.onRefresh,
    required this.builder,
    this.emptyStateBuilder,
    this.floatingActionButton,
    this.showAppBar = true,
    this.centerTitle = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> headerActions;
  final AsyncValue<T> asyncValue;
  final Future<void> Function()? onRefresh;
  final Widget Function(T data) builder;
  final Widget Function()? emptyStateBuilder;
  final Widget? floatingActionButton;
  final bool showAppBar;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorTokens.surfaceBackground,
      appBar: showAppBar ? _buildAppBar(context) : null,
      body: SafeArea(
        child: asyncValue.when(
          loading: () => const LoadingView(),
          error: (error, stack) => ErrorView(
            message: error.toString(),
            onRetry: onRefresh,
          ),
          data: (data) {
            if (_isEmpty(data) && emptyStateBuilder != null) {
              return emptyStateBuilder!();
            }

            Widget content = builder(data);

            if (onRefresh != null) {
              content = RefreshIndicator(
                onRefresh: onRefresh!,
                color: ColorTokens.teal500,
                backgroundColor: ColorTokens.surfacePrimary,
                child: content,
              );
            }

            return content;
          },
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: ColorTokens.surfacePrimary,
      elevation: 0,
      centerTitle: centerTitle,
      title: Column(
        crossAxisAlignment: centerTitle
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TypographyTokens.heading4,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TypographyTokens.captionMd,
            ),
          ],
        ],
      ),
      actions: headerActions,
    );
  }

  bool _isEmpty(T data) {
    if (data is List) return data.isEmpty;
    if (data is Map) return data.isEmpty;
    if (data is Set) return data.isEmpty;
    return data == null;
  }
}