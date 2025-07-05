// lib/widgets/med_list_item.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication.dart';
import '../providers/med_provider.dart';

class MedListItem extends StatelessWidget {
  final Medication med;
  final VoidCallback onTap;
  const MedListItem({
    required this.med,
    required this.onTap,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(med.name),
      subtitle: Text('${med.dosage}, ${med.timesPerDay}×/day'),
      trailing: Checkbox(
        value: med.takenToday,
        onChanged: (_) =>
            context.read<MedProvider>().toggleTaken(med),
      ),
      onTap: onTap,
    );
  }
}
