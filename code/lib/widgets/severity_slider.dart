// lib/widgets/severity_slider.dart
import 'package:flutter/material.dart';
class SeveritySlider extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const SeveritySlider({
    required this.value,
    required this.onChanged,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children:[
        const Text('Severity'),
        Expanded(
          child: Slider(
            value: value.toDouble(),
            min:0,
            max:10,
            divisions:10,
            label:'$value',
            onChanged:(v)=>onChanged(v.toInt()),
          ),
        ),
      ],
    );
  }
}
