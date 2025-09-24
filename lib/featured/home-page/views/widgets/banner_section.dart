import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerSection extends StatefulWidget {
  const BannerSection({super.key});

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection> {
  final PageController _pageController = PageController();
  final RxInt _currentPage = 0.obs;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage.value < 2) {
        _currentPage.value++;
      } else {
        _currentPage.value = 0;
      }
      _pageController.animateToPage(
        _currentPage.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              _currentPage.value = index;
            },
            itemCount: 3,
            itemBuilder: (context, index) {
              return _buildBannerItem(index);
            },
          ),
          // Page indicators
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => Obx(
                  () => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage.value == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _currentPage.value == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerItem(int index) {
    List<Map<String, dynamic>> banners = [
      {
        'title': 'Big Sale',
        'subtitle': 'Up to 50%',
        'description': 'Happening Now',
        'color': const Color(0xFFFFD700), // Gold
        'icon': Icons.shopping_bag,
        'gradient': const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'New Arrivals',
        'subtitle': 'Fresh Styles',
        'description': 'Shop Now',
        'color': const Color(0xFF6C63FF), // Purple
        'icon': Icons.star,
        'gradient': const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF9C88FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'Free Shipping',
        'subtitle': 'On All Orders',
        'description': 'Limited Time',
        'color': const Color(0xFF4CAF50), // Green
        'icon': Icons.local_shipping,
        'gradient': const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
    ];

    final banner = banners[index];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: banner['gradient'],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: banner['color'].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner['title'],
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        banner['subtitle'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1, 1),
                              blurRadius: 2,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        banner['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: .9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Icon container
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(banner['icon'], color: Colors.white, size: 40),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
