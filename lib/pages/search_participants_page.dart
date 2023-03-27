import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SearchParticipantsPage extends StatefulWidget {
  const SearchParticipantsPage({super.key});

  @override
  State<SearchParticipantsPage> createState() => _SearchParticipantsPageState();
}

class _SearchParticipantsPageState extends State<SearchParticipantsPage> {
  final TextEditingController _textController = TextEditingController();
  final UserController _userController = UserController();
  bool _isLoading = false;

  List<UserModel> _searchResults = [];
  List<UserModel> _participants = [];

  _fetchUsers() async {
    var results = await _userController
        .getAllUsersBasicInfo(_textController.text.toLowerCase());
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              // color: Colors.grey[200],
              color: Constants.aliceBlue,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.search,
                  color: Constants.indigoDye,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Buscar",
                    ),
                    cursorColor: Constants.indigoDye,
                    controller: _textController,
                    onChanged: (value) {
                      _fetchUsers();
                    },
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Constants.indigoDye),
                    )),
              ],
            ),
          ),
          backgroundColor: const Color(0xFFFAFAFA),
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: _isLoading
            ? const Loader()
            : ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(_searchResults[index].name),
                      leading: _searchResults[index].profilePic.isEmpty
                          ? const Icon(Icons.account_circle, size: 60)
                          : CircleAvatar(
                              radius: 30,
                              backgroundImage: NetworkImage(
                                  _searchResults[index].profilePic)),
                      trailing: TextButton(
                          onPressed: () {
                            setState(() {
                              _participants.add(_searchResults[index]);
                            });
                          },
                          child: const Text("Añadir")));
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: _searchResults.length));
  }
}
