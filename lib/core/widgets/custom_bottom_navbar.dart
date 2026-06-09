import 'package:flutter/material.dart';

class CustomBottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const CustomBottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xFF5A008A),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [ // Tambahkan bayangan agar terlihat 'floating' & modern
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home_rounded, 0),
            _buildNavItem(Icons.history_rounded, 1),
            _buildNavItem(Icons.vpn_key_rounded, 2),
            _buildNavItem(Icons.grid_view_rounded, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400), // Durasi lebih lama agar terasa premium
        curve: Curves.easeOutCubic, // Kurva animasi modern
        width: isSelected ? 58 : 44,
        height: isSelected ? 58 : 44,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          shape: BoxShape.circle,
          // Tambahkan sedikit transisi shadow saat item terpilih
          boxShadow: isSelected 
            ? [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 8)]
            : [],
        ),
        child: AnimatedSwitcher( // Menambahkan animasi transisi antar ikon
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            icon,
            key: ValueKey(isSelected), // Kunci agar AnimatedSwitcher tahu ada perubahan
            size: 24,
            color: isSelected ? const Color(0xFF5A008A) : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}