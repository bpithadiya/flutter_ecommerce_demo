import 'package:flutter/material.dart';

class BadgeIcon extends StatelessWidget {
  final IconData icon;
  final Color badgeColor;
  final Color iconColor;
  final int count;
  final VoidCallback onPressed;
  final String heroTag;

  const BadgeIcon({
    super.key,
    required this.icon,
    required this.badgeColor,
    required this.iconColor,
    required this.count,
    required this.onPressed,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        FloatingActionButton(
          heroTag: heroTag,
          backgroundColor: Colors.white,
          elevation: 4,
          onPressed: onPressed,
          child: Icon(icon, color: iconColor),
        ),
        if (count > 0)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
