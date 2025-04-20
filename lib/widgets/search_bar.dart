import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

// gestion des données
import '../provider/observation_provider.dart';
import 'package:provider/provider.dart';
import 'globals.dart' as globals;

class Search_Bar extends StatefulWidget {
  const Search_Bar({super.key});

  @override
  _Search_BarState createState() => _Search_BarState();
}

class _Search_BarState extends State<Search_Bar> {
  final TextEditingController _typeAheadController = TextEditingController();
  final Map<String, int> score = {'playe1': 1, 'player2': 2};

  List<Widget> builder() {
    List<Widget> l = [];
    score.forEach((k, v) => l.add(ListTile(
      contentPadding: const EdgeInsets.all(16.0),
      title: Text(k),
      trailing: Text(v.toString()),
    )));
    return l;
  }



  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ObservationProvider>(context);

    final List<String> dep = ["95", "94", "93", "92", "91", "90", "89", "88", "87", "86", "85", "84", "83", "82", "81", "80", "79", "78", "77", "76", "75", "74", "73", "72", "71", "70", "69", "68", "67", "66", "65", "64", "63", "62", "61", "60", "59", "58", "57", "56", "55", "54", "53", "52", "51", "50", "49", "48", "47", "46", "45", "44", "43", "42", "41", "40", "39", "38", "37", "36", "35", "34", "33", "32", "31", "30", "29", "28", "27", "26", "25", "24", "23", "22", "21", "20", "19", "18", "17", "16", "15", "14", "13", "12", "11", "10", "09", "08", "07", "06", "05", "04", "03", "02", "01"
    ];
    //final List<String> dep = [for (int i = 1; i <= 95; i++) i.toString()];

    return Scaffold(
      //appBar: AppBar(title: Text("Recherche")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TypeAheadField<String>(
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
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Département',
                )
            );
          },

          itemBuilder: (context, suggestion) {
            return ListTile(
              title: Text(suggestion),
              );
          },
          onSelected: (String val) {
            //Provider.of<ObservationProvider>(context, listen: false).selectStation(provider.stationId);
            print("Département sélectionné : $val");
            //globals.value = val;
            Provider.of<ObservationProvider>(context, listen: false).selectDepartment(val);

          },
        ),
      ),
    );
  }
}


