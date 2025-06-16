import 'package:flutter/material.dart';
// import 'package:calendar/entity/helper/colors.dart';
// import 'package:calendar/shared/component/bottom_appbar.dart';

class SaleSkeleton extends StatelessWidget {
  const SaleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Container(
      //     width: 100,
      //     height: 20,
      //     color: Colors.grey[300],
      //   ),
      //   actions: [
      //     Padding(
      //       padding: const EdgeInsets.all(8),
      //       child: Icon(Icons.more_horiz, color: HColors.darkgrey),
      //     ),
      //   ],
      //   centerTitle: true,
      //   bottom: CustomHeader(),
      // ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SafeArea(
          child: Column(
            children: [
              // Header with balance
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1),
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 16, color: Colors.grey[300]),
                    const SizedBox(height: 8),
                    Container(width: 150, height: 20, color: Colors.grey[300]),
                  ],
                ),
              ),

              // Transaction list skeleton
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3, // Show 3 date sections for skeleton
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      // Date section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        color: const Color(0xFFF0F2F5),
                        child: Container(
                          width: 80,
                          height: 14,
                          color: Colors.grey[300],
                        ),
                      ),
                      // Transaction items
                      ...List.generate(
                        3,
                        (i) => _buildTransactionItemSkeleton(),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItemSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Row(
        children: [
          // Transaction icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[300],
            ),
          ),
          SizedBox(width: 12),
          // Transaction ID
          Container(width: 60, height: 14, color: Colors.grey[300]),

          const Spacer(),

          // Amount
          Container(width: 80, height: 14, color: Colors.grey[300]),

          const SizedBox(width: 8),

          // User avatar
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}
