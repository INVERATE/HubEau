import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_flutter_api/models/observation_model.dart';
import '../provider/observation_provider.dart';

class StationDetails extends StatelessWidget {
  const StationDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedStation = Provider.of<ObservationProvider>(context).stationId;

    Widget content;
    if (selectedStation == null) {
      content = Text("Aucun point sélectionné");
    }
    else {
      content = Text("Station : $selectedStation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            content,
            SizedBox(height: 8),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
