import 'package:flutter/material.dart';

class SuccessBanner extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;
  final Color? color;
  final String? warningNote;
  final IconData warningIcon;
  final Color? warningIconColor;

  const SuccessBanner({
    super.key,
    required this.title,
    required this.body,
    this.icon = Icons.check_circle,
    this.color,
    this.warningNote,
    this.warningIcon = Icons.info_outline,
    this.warningIconColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Colors.green;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: themeColor.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: themeColor, size: 56),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: themeColor, // Re-using themeColor to fake a 'successDark' fallback 
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          if (warningNote != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(warningIcon, size: 18, color: warningIconColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      warningNote!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
