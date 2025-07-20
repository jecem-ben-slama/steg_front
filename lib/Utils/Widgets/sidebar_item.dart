import 'package:flutter/material.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isSelected; 

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isSelected
            ? Colors.blue.withOpacity(0.2)
            : Colors.transparent, 
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
                  : FontWeight.normal, 
            ),
          ),
        ),
      ),
    );
  }
}
