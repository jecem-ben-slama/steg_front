import 'package:flutter/material.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap; // Added onTap callback
  final bool isSelected; // Added isSelected for visual feedback

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.isSelected = false, // Default to false
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Use GestureDetector for better tap control
      onTap: onTap,
      child: Container(
        // Wrap with Container to apply background color based on selection
        color: isSelected
            ? Colors.blue.withOpacity(0.2)
            : Colors.transparent, // Highlight selected item
        child: ListTile(
          leading: Icon(
            icon,
            color: Colors.white,
            size: MediaQuery.of(context).size.width * 0.02,
          ),
          title: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width * 0.01,
              fontWeight: isSelected
                  ? FontWeight.bold
                  : FontWeight.normal, // Make text bold if selected
            ),
          ),
        ),
      ),
    );
  }
}
