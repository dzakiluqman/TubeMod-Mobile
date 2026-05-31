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
        margin: const EdgeInsets.fromLTRB(
          18,
          0,
          18,
          18,
        ),
        height: 82,
        decoration: BoxDecoration(
          color: const Color(0xFF5A008A),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildNavItem(
                Icons.home_outlined,
                0,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                Icons.history_toggle_off,
                1,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                Icons.vpn_key_outlined,
                2,
              ),
            ),
            Expanded(
              child: _buildNavItem(
                Icons.apps_outlined,
                3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    int index,
  ) {
    final isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isSelected ? 60 : 44,
          height: isSelected ? 60 : 44,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.white
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: isSelected ? 28 : 30,
            color: isSelected
                ? const Color(0xFF5A008A)
                : Colors.white,
          ),
        ),
      ),
    );
  }
}