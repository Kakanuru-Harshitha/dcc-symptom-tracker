// lib/screens/med_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/medication.dart';
import '../providers/med_provider.dart';

class MedEditScreen extends StatefulWidget {
  final Medication? med;
  const MedEditScreen({this.med,super.key});
  @override
  State<MedEditScreen> createState() => _MedEditScreenState();
}

class _MedEditScreenState extends State<MedEditScreen> {
  final _nameC=TextEditingController();
  final _dosC=TextEditingController();
  int _times=1;

  @override
  void initState(){
    super.initState();
    if(widget.med!=null){
      _nameC.text = widget.med!.name;
      _dosC.text = widget.med!.dosage;
      _times = widget.med!.timesPerDay;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.med==null?'Add Medication':'Edit Medication')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children:[
            TextField(
              controller:_nameC,
              decoration: const InputDecoration(labelText:'Name'),
            ),
            const SizedBox(height:8),
            TextField(
              controller:_dosC,
              decoration: const InputDecoration(labelText:'Dosage'),
            ),
            Row(
              children:[
                const Text('Times/day'),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: _times>1 ? ()=>setState(()=>_times--) : null,
                ),
                Text('$_times'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: ()=>setState(()=>_times++),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              child: const Text('Save'),
              onPressed:(){
                final m = widget.med ?? Medication(
                  name:'',dosage:'',timesPerDay:1);
                m.name = _nameC.text;
                m.dosage= _dosC.text;
                m.timesPerDay = _times;
                context.read<MedProvider>().addOrUpdate(m);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
