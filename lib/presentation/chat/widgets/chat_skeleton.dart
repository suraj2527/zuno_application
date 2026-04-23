import 'package:flutter/material.dart';
import 'package:nearly/shared/widgets/shimmers/shimmer_box.dart';

class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: const [
                ShimmerBox(height: 30, width: 150, radius: 12),
                Spacer(),
                ShimmerBox(height: 42, width: 42, radius: 21),
              ],
            ),

            const SizedBox(height: 28),

            // ACTIVE NOW label
            const ShimmerBox(height: 12, width: 85, radius: 6),
            const SizedBox(height: 16),

            // Active avatars
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (_, __) => const Column(
                  children: [
                    ShimmerBox(height: 56, width: 56, radius: 28),
                    SizedBox(height: 8),
                    ShimmerBox(height: 10, width: 48, radius: 6),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // MESSAGES label
            const ShimmerBox(height: 12, width: 90, radius: 6),
            const SizedBox(height: 14),

            // Chat list skeleton
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        const ShimmerBox(height: 48, width: 48, radius: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            children: const [
                              Row(
                                children: [
                                  Expanded(
                                    child: ShimmerBox(
                                      height: 14,
                                      width: double.infinity,
                                      radius: 8,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  ShimmerBox(height: 10, width: 30, radius: 6),
                                ],
                              ),
                              SizedBox(height: 10),
                              ShimmerBox(
                                height: 12,
                                width: double.infinity,
                                radius: 8,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}