import 'package:flutter/material.dart';

class CategoryCardSkeleton extends StatefulWidget {
  const CategoryCardSkeleton({super.key});

  @override
  State<CategoryCardSkeleton> createState() => _CategoryCardSkeletonState();
}

class _CategoryCardSkeletonState extends State<CategoryCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Skeleton image
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[300]!.withOpacity(_animation.value),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Skeleton content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title skeleton
                        Container(
                          height: 20,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[300]!.withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Subtitle skeleton
                        Container(
                          height: 16,
                          width: MediaQuery.of(context).size.width * 0.6,
                          decoration: BoxDecoration(
                            color: Colors.grey[300]!.withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Items count skeleton
                        Container(
                          height: 14,
                          width: MediaQuery.of(context).size.width * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.grey[300]!.withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action skeleton
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey[300]!.withOpacity(_animation.value),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CategoriesSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const CategoriesSkeletonLoader({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const CategoryCardSkeleton();
      },
    );
  }
}

class MenuItemCardSkeleton extends StatefulWidget {
  const MenuItemCardSkeleton({super.key});

  @override
  State<MenuItemCardSkeleton> createState() => _MenuItemCardSkeletonState();
}

class _MenuItemCardSkeletonState extends State<MenuItemCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skeleton image
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300]!.withOpacity(_animation.value),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                // Skeleton content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header skeleton
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300]!.withOpacity(_animation.value),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(_animation.value),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Description skeleton
                        Container(
                          height: 14,
                          width: MediaQuery.of(context).size.width * 0.7,
                          decoration: BoxDecoration(
                            color: Colors.grey[300]!.withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 14,
                          width: MediaQuery.of(context).size.width * 0.5,
                          decoration: BoxDecoration(
                            color: Colors.grey[300]!.withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Price and time skeleton
                        Row(
                          children: [
                            Container(
                              width: 80,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(_animation.value),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 70,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(_animation.value),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Status skeleton
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(_animation.value),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 50,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(_animation.value),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 60,
                              height: 14,
                              decoration: BoxDecoration(
                                color: Colors.grey[300]!.withOpacity(_animation.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MenuItemsSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const MenuItemsSkeletonLoader({
    super.key,
    this.itemCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const MenuItemCardSkeleton();
      },
    );
  }
}

class VendorProfileSkeleton extends StatefulWidget {
  const VendorProfileSkeleton({super.key});

  @override
  State<VendorProfileSkeleton> createState() => _VendorProfileSkeletonState();
}

class _VendorProfileSkeletonState extends State<VendorProfileSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const NeverScrollableScrollPhysics(), // Prevent scrolling during loading
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vendor Image Card Skeleton (matching exact dimensions)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  height: 200, // Exact height from actual card
                  decoration: BoxDecoration(
                    color: Colors.grey[300]!.withOpacity(_animation.value),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      // Camera icon placeholder
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[400]!.withOpacity(_animation.value),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                      // Name and description skeleton
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 24,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100]!.withOpacity(_animation.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 14,
                              width: MediaQuery.of(context).size.width * 0.6,
                              decoration: BoxDecoration(
                                color: Colors.grey[100]!.withOpacity(_animation.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16), // Exact spacing
              
              // Vendor Details Card Skeleton
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title "تفاصيل المطعم"
                      Container(
                        height: 18,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300]!.withOpacity(_animation.value),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Working Hours Row
                      _buildSkeletonInfoRow(_animation.value, context),
                      const SizedBox(height: 12),
                      
                      // Working Days Row
                      _buildSkeletonInfoRow(_animation.value, context),
                      const SizedBox(height: 12),
                      
                      // Status Row
                      _buildSkeletonInfoRow(_animation.value, context),
                      const SizedBox(height: 12),
                      
                      // Rating Row
                      _buildSkeletonInfoRow(_animation.value, context),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24), // Exact spacing before button
              
              // Management Button Skeleton
              Container(
                height: 56, // Exact button height
                decoration: BoxDecoration(
                  color: Colors.grey[300]!.withOpacity(_animation.value),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonInfoRow(double animationValue, BuildContext context) {
    return Row(
      children: [
        // Icon skeleton
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey[300]!.withOpacity(animationValue),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        // Content skeleton
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300]!.withOpacity(animationValue),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 14,
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  color: Colors.grey[300]!.withOpacity(animationValue),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}