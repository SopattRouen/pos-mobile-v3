import 'package:flutter/material.dart';
import 'package:calendar/shared/entity/helper/colors.dart';

class CSaleSkeleton extends StatelessWidget {
  const CSaleSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Transaction list skeleton
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: 10,
            itemBuilder: (context, index) {
              return _buildTransactionItemSkeleton();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItemSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E5E5), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: HColors.grey.withOpacity(0.1),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  color: HColors.grey.withOpacity(0.1),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 100,
                  height: 14,
                  color: HColors.grey.withOpacity(0.1),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 16,
            color: HColors.grey.withOpacity(0.1),
          ),
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: HColors.grey.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
