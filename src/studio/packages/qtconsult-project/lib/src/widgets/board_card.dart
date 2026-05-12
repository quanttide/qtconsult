import 'package:flutter/material.dart';

class BoardCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final void Function()? onTap;

  const BoardCard({
    super.key,
    required this.child,
    this.accentColor,
    this.borderColor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderSide = BorderSide(color: borderColor ?? const Color(0xFFE6E6E6));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.fromBorderSide(borderSide),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (accentColor != null)
                Container(width: 4, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
