import 'package:flutter/material.dart';

class CategoryItem extends StatelessWidget {
  final String label;
  final Color color;
  final String? imageAsset;
  final IconData? icon;
  final VoidCallback? onTap;

  final double imageWidth;
  final double imageHeight;
  final double circleRadius;

  const CategoryItem({
    Key? key,
    required this.label,
    required this.color,
    this.imageAsset,
    this.icon,
    this.onTap,
    this.imageWidth = 45,
    this.imageHeight = 45,
    this.circleRadius = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget childWidget;
    if (imageAsset != null) {
      childWidget = Image.asset(imageAsset!, width: imageWidth, height: imageHeight);
    } else if (icon != null) {
      childWidget = Icon(icon, size: 30, color: color);
    } else {
      childWidget = const SizedBox();
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: circleRadius,
            backgroundColor: color.withOpacity(0.1),
            child: childWidget,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}