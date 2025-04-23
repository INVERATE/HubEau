import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:test_flutter_api/layout/colors.dart';

// gestion des données
import '../provider/observation_provider.dart';
import 'package:provider/provider.dart';

class Search_Bar extends StatefulWidget {
  const Search_Bar({super.key});

  @override
  _Search_BarState createState() => _Search_BarState();
}

class _Search_BarState extends State<Search_Bar> {
  // les controllers permettent d'interagir avec des widget et de les controller en leur donnant des états à respecter par exemple
  final TextEditingController _typeAheadController = TextEditingController();   // ici le controller permet de mettre à jour le textfield quand l'utilisateur écrit
  // création de notre liste de départements
  final List<String> dep = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64", "65", "66", "67", "68", "69", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80", "81", "82", "83", "84", "85", "86", "87", "88", "89", "90", "91", "92", "93", "94", "95", "971", "972", "973", "974", "976"];

  // ne sert à rien ici
  final Map<String, int> score = {'playe1': 1, 'player2': 2};
  // méthode Map ecrit à la main si jamais
  List<Widget> builder() {
    List<Widget> l = [];
    score.forEach((k, v) => l.add(ListTile(
      contentPadding: const EdgeInsets.all(16.0),
      title: Text(k),
      trailing: Text(v.toString()),
    )));
    return l;
  }

  // méthode qui permet de récuperer un département dans l'api
  void _handleDepartmentSelection(String val) {
    _typeAheadController.text = val;
    Provider.of<ObservationProvider>(context, listen: false).selectDepartment(val);
    print("Département sélectionné dans la barre de recherche : $val");
  }

  // creation du widget pour la bar textahead
  @override
  Widget build(BuildContext context) {  // méthode build pour savoir à quoi va ressembler le widget en fonction de l'état et des configuration, buildcontext est utilisé pour récuperer des info sur widget tel que sa location dans l'arbre des widget mais aussi la configuration, l'état, le theme ...
    return Padding(  // sa taille
      padding: const EdgeInsets.all(10.0),
      child: TypeAheadField<String>(  // la barre de recherche qui prendra comme type de variable des String <String>
        controller: _typeAheadController,   // on appel le controller
        suggestionsCallback: (pattern) {  // le partern c'est l'élément qui est écrit dans la barre de recherche EX : patern : 5
          return dep.where((d) => d.contains(pattern)).toList();  // ici si le panten est reconnu alors on affuiche une liste des éléments qui le contiennent EX : la liste va etre : 15, 51,53, 25,.....
        },

        builder: (context, controller, focusNode) {   // créer un widget enfant
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(   // widget barre de recherche ici textfield comme ca on peut ecrire dedans
              controller: controller,
              focusNode: focusNode,
              autofocus: false, // evite que le clavier apparaisse automatiquement
              cursorColor: BluePalette.primary,
              decoration: InputDecoration(
                //border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                hintText: ' Choisissez un département', // petit mot qui sera en gris pour indiquer quoi ecrire à l'utilisateur

                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: BluePalette.background, width: 2.0), // bordure quand non focus
                  borderRadius: BorderRadius.circular(12.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: BluePalette.background, width: 2.0), // bordure quand focus
                  borderRadius: BorderRadius.circular(12.0),
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                  },
                ),
                contentPadding: const EdgeInsets.all(16.0),
              ),

              // on Submitted permet de choisir un department en appuyant que la touche entrer du clavier
              onSubmitted: (val) {  // une fois que l'utilisateur a fini d'écrire on recupère son texte (val)
                if (dep.contains(val)) {  // si le texte existe dans derpartement
                  _handleDepartmentSelection(val); // on va le chercher dans l'api
                } else {
                  print("Département non reconnu : $val"); // dans le terminal on afficha ca
                }
              },
            ),
          );
        },

        emptyBuilder: (context) {
          return const ListTile(
            title: Text('Aucun département trouvé'),
          );
        },

        itemBuilder: (context, suggestion) {  // créer une liste de item widget
          return ListTile(  // petit widget pour afficher la liste des sugestion
            title: Text(
              suggestion,
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
            ),
            tileColor: BluePalette.background,
          );
        },

        // on Selected permet de choisir un department en appuyant sur un élément de la liste
        onSelected: (String val) {
          _handleDepartmentSelection(val); // on fait appel à l'api avec la valeur selectionner
        },
      ),
    );
  }
}

// il y a d'un côté la création de liste ligne 49 et de l'autre coté l'appel à un widget liste ListTile
// ensuite, il y a d'un côté la création de la méthode de la barre de recherche TypeAHeadField avec ligne 48 et de l'autre coté l'appel à un widget bare de recherche TextField
