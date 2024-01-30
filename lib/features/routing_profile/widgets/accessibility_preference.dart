import 'package:flutter/material.dart';


class AccessibilityPreference extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final ValueChanged<double>? onChanged;

  const AccessibilityPreference({
    required this.label,
    required this.icon,
    required this.value,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: const SliderThemeData(
        trackHeight: 20,
        thumbShape: RoundSliderThumbShape(
          enabledThumbRadius: 14.0,
        ),
        tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 20),
      ),
      child: ListTile(
        title: Text(label),
        leading: Icon(icon),
        subtitle:  Slider(
          value: value,
          onChanged: onChanged,
          divisions: 4,
        ),
      ),
    );
  }
}
