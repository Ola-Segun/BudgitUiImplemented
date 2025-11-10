// lib/features/transactions/presentation/widgets/enhanced_shimmer_loading.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_colors_extended.dart';
import '../../../../core/theme/app_dimensions.dart';

class EnhancedShimmerLoading extends StatelessWidget {
  const EnhancedShimmerLoading({
    super.key,
    this.itemCount = 6,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColorsExtended.pillBgUnselected,
      highlightColor: Colors.white.withValues(alpha: 0.5),
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.screenPaddingH,
          vertical: AppDimensions.screenPaddingV,
        ),
        children: [
          // Stats Card Skeleton
          _buildStatsCardSkeleton(),
          SizedBox(height: AppDimensions.sectionGap),

          // Transaction List Skeleton
          ...List.generate(itemCount, (index) => _buildTransactionSkeleton(index)),
        ],
      ),
    );
  }

  Widget _buildStatsCardSkeleton() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(AppDimensions.cardPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: AppDimensions.spacing2),
              Container(
                width: 120,
                height: 20,
                color: Colors.white,
              ),
            ],
          ),
          SizedBox(height: AppDimensions.spacing4),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 16,
                      color: Colors.white,
                    ),
                    SizedBox(height: AppDimensions.spacing2),
                    Container(
                      width: 80,
                      height: 24,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white,
              ),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 16,
                      color: Colors.white,
                    ),
                    SizedBox(height: AppDimensions.spacing2),
                    Container(
                      width: 80,
                      height: 24,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppDimensions.spacing4),

          // Savings Rate
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: AppDimensions.spacing2),
                    Container(
                      width: 80,
                      height: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
                Container(
                  width: 40,
                  height: 18,
                  color: Colors.white,
                ),
              ],
            ),
          ),

          SizedBox(height: AppDimensions.spacing3),

          // Transaction Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 100,
                height: 12,
                color: Colors.white,
              ),
              Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSkeleton(int index) {
    return Container(
      height: 80,
      margin: EdgeInsets.only(bottom: AppDimensions.spacing2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Category Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(width: AppDimensions.spacing3),

          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Container(
                  width: double.infinity,
                  height: 16,
                  color: Colors.white,
                ),
                SizedBox(height: AppDimensions.spacing1),

                // Category and Time
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 12,
                      color: Colors.white,
                    ),
                    SizedBox(width: AppDimensions.spacing2),
                    Container(
                      width: 40,
                      height: 10,
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Amount
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 70,
                height: 16,
                color: Colors.white,
              ),
              SizedBox(height: AppDimensions.spacing1),
              Container(
                width: 30,
                height: 12,
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}