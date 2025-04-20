import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

// gestion des données
import '../provider/observation_provider.dart';
import 'package:provider/provider.dart';

class Search_Bar extends StatefulWidget {
  const Search_Bar({super.key});

  @override
  _Search_BarState createState() => _Search_BarState();
}

class _Search_BarState extends State<Search_Bar> {
  final TextEditingController _typeAheadController = TextEditingController();
  final Map<String, int> score = {'playe1': 1, 'player2': 2};
  final List<String> dep = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "971", "972", "973", "974", "976"];

  List<Widget> builder() {
    List<Widget> l = [];
    score.forEach((k, v) => l.add(ListTile(
      contentPadding: const EdgeInsets.all(16.0),
      title: Text(k),
      trailing: Text(v.toString()),
    )));
    return l;
  }

  void _handleDepartmentSelection(String val) {
    _typeAheadController.text = val;
    Provider.of<ObservationProvider>(context, listen: false).selectDepartment(val);
    print("Département sélectionné dans la barre de recherche : $val");
  }

  @override
  Widget build(BuildContext context) {
    //final provider = Provider.of<ObservationProvider>(context);
    return Scaffold(
      //appBar: AppBar(title: Text("Recherche")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TypeAheadField<String>(
          controller: _typeAheadController,
          suggestionsCallback: (pattern) {
            return dep.where((d) => d.contains(pattern)).toList();
          },
          //suggestionsCallback: (pattern) async {
          //  return await HubEauAPI().getStationListByDepartment("94");
          //},
          //suggestionsCallback: List<Station> stations = await HubEauAPI().getStationListByDepartment("94"),
          builder: (context, controller, focusNode) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: false, // evite que le clavier apparaisse automatiquement
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Choisissez un département',
              ),
              onSubmitted: (val) {
                if (dep.contains(val)) {
                  _handleDepartmentSelection(val);
                } else {
                  print("Département non reconnu : $val");
                }
              },
            );
          },

          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion),
              );
          },

          onSelected: (String val) {
            //Provider.of<ObservationProvider>(context, listen: false).selectStation(provider.stationId);
            //globals.value = val;
            _handleDepartmentSelection(val);
          },
        ),
      ),
    );
  }
}


