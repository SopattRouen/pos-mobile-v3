// =======================>> Flutter Core
import 'package:flutter/material.dart';


class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Header Skeleton
              _buildUserProfileHeaderSkeleton(),
              // Category Grid Skeleton
              _buildCategoryGridSkeleton(),
              // Cashier List Skeleton
              _buildCashierListSkeleton(),
              // Product Type Chart Skeleton
              _buildProductTypeChartSkeleton(),
              // Statistic Chart Skeleton
              _buildStatisticChartSkeleton(),
            ],
          ),
        ),
      ),
    );
  }

  // User Profile Header Skeleton
  Widget _buildUserProfileHeaderSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.white,
      child: Row(
        children: [
          // Avatar Placeholder
          Container(
            width: 40.0,
            height: 40.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(width: 12),
          // User Info Placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100.0,
                  height: 16.0,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 4),
                Container(
                  width: 60.0,
                  height: 12.0,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
          // Action Buttons Placeholder
          Row(
            children: [
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 36.0,
                height: 36.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Category Grid Skeleton
  Widget _buildCategoryGridSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemCount: 4, // Mimic 4 grid items
        itemBuilder: (context, index) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20.0,
                        height: 20.0,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60.0,
                        height: 12.0,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                  Container(
                    width: 40.0,
                    height: 14.0,
                    color: Colors.grey[300],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Cashier List Skeleton
  Widget _buildCashierListSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120.0,
            height: 16.0,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 15),
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3, // Mimic 3 cashier items
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                decoration: BoxDecoration(
                  color: index % 2 == 0 ? Colors.grey[100] : Colors.white,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  leading: Container(
                    width: 40.0,
                    height: 40.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[300],
                    ),
                  ),
                  title: Container(
                    width: 100.0,
                    height: 14.0,
                    color: Colors.grey[300],
                  ),
                  subtitle: Container(
                    width: 60.0,
                    height: 12.0,
                    color: Colors.grey[300],
                  ),
                  trailing: Container(
                    width: 80.0,
                    height: 14.0,
                    color: Colors.grey[300],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Product Type Chart Skeleton
  Widget _buildProductTypeChartSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120.0,
            height: 16.0,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200.0,
                width: 200.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Statistic Chart Skeleton
  Widget _buildStatisticChartSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120.0,
            height: 16.0,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Container(
            height: 200.0,
            color: Colors.grey[300],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                5,
                (index) => Container(
                  height: 20.0,
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  color: Colors.grey[200],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}