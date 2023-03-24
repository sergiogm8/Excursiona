import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SearchParticipantsPage extends StatefulWidget {
  const SearchParticipantsPage({super.key});

  @override
  State<SearchParticipantsPage> createState() => _SearchParticipantsPageState();
}

class _SearchParticipantsPageState extends State<SearchParticipantsPage> {
  List<UserModel> _participants = [];
  List<UserModel> _searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 38),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Buscar",
                          ),
                        ),
                      ),
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            "Cancelar",
                            style: TextStyle(color: Constants.indigoDye),
                          ))
                    ],
                  ),
                ),
                const Text(
                  "Buscar participantes",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Busca a tus amigos y añádelos a la excursión",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                const Text(
                  "Resultados",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "No se han encontrado resultados",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, _participants.length),
                    child: const Text("Añadir participante")),
                ElevatedButton(onPressed: () => {}, child: const Text("+")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
