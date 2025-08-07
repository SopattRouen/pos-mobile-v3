// =======================>> Flutter Core
import 'package:calendar/shared/entity/helper/colors.dart';
import 'package:flutter/material.dart';

// ::: Class > OrderSkeleton (StatelessWidget)
class OrderSkeleton extends StatelessWidget {
  const OrderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton for category tabs
          SizedBox(height: 10),
          SizedBox(
            height: 35,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(
                left: 8.0,
                right: 4.0,
              ), // Adjusted padding
              children: List.generate(
                5, // Display 4 category tabs
                (index) => Padding(
                  padding: const EdgeInsets.only(
                    right: 8.0,
                  ), // Only right padding for spacing
                  child: Container(
                    width: 90, // Smaller width for tabs (reduced from 100)
                    height: 36,
                    decoration: BoxDecoration(
                      color: HColors.darkgrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: HColors.darkgrey.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Skeleton for product grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 0.5,
              mainAxisSpacing: 0.5,
            ),
            itemCount: 6, // Simulate 6 product items
            itemBuilder: (context, index) => _SkeletonProductItem(),
          ),
        ],
      ),
    );
  }
}

// ::: Class > _SkeletonProductItem (StatelessWidget)
class _SkeletonProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: HColors.darkgrey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Skeleton for product image
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: HColors.darkgrey.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
            ),
            // Skeleton for product details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Skeleton for product name
                  Container(
                    width: 120,
                    height: 16,
                    color: HColors.darkgrey.withOpacity(0.1),
                  ),
                  const SizedBox(height: 8),
                  // Skeleton for product price
                  Container(
                    width: 80,
                    height: 12,
                    color: HColors.darkgrey.withOpacity(0.1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
