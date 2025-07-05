// lib/widgets/body_map.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BodyMap extends StatefulWidget {
  final Set<String> selected;
  final ValueChanged<Set<String>> onChanged;
  const BodyMap({
    required this.selected,
    required this.onChanged,
    super.key,
  });
  @override
  State<BodyMap> createState() => _BodyMapState();
}

class _BodyMapState extends State<BodyMap> {
  late Set<String> sel;
  @override
  void initState() {
    super.initState();
    sel = widget.selected;
  }
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: kBodyParts.map((part){
        final active = sel.contains(part);
        return FilterChip(
          label: Text(part),
          selected: active,
          onSelected: (v){
            setState((){
              v ? sel.add(part) : sel.remove(part);
              widget.onChanged(sel);
            });
          },
        );
      }).toList(),
    );
  }
}
