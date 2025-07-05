// lib/screens/med_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/med_provider.dart';
import '../widgets/med_list_item.dart';
import 'med_edit_screen.dart';

class MedListScreen extends StatelessWidget {
  const MedListScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final meds = context.watch<MedProvider>().meds;
    return Scaffold(
      body: ListView.builder(
        itemCount: meds.length,
        itemBuilder:(_,i)=>MedListItem(
          med:meds[i],
          onTap:(){
            Navigator.push(context, MaterialPageRoute(
              builder:(_)=>MedEditScreen(med:meds[i]),
            ));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed:()=>
          Navigator.pushNamed(context,'/med_edit'),
      ),
    );
  }
}
