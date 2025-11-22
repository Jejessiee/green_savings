import 'package:flutter/material.dart';
import '../app_colors.dart';

class LeafyBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const LeafyBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.brokenWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: const Offset(0, -3), // backshadow ke arah atas
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          //Baris item navigasi (Home & Stats)
          Positioned.fill(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(1, Icons.home_outlined, Icons.home, 'Home'),
                const SizedBox(width: 40), // Space untuk tombol tengah
                _buildNavItem(2, Icons.bar_chart_outlined, Icons.bar_chart, 'Stats')
              ],
            ),
          ),

          // Tombol Add Transaction
          Positioned(
            bottom: 40,
            child: GestureDetector(
              onTap: () => onTap(0), // index 0 untuk tombol add transaction
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.blushpink, AppColors.peach],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData inactiveIcon, IconData activeIcon, String label) {
    final bool isActive = currentIndex == index; // cek apakah item aktif

    return GestureDetector(
      onTap: () => onTap(index), //memanggil fungsi saat ditekan
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : inactiveIcon, // mengubah icon yang aktif
            color: isActive ? AppColors.darkGreen :  Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? AppColors.darkGreen : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
