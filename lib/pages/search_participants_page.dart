import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/helper/helper_functions.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class SearchParticipantsPage extends StatefulWidget {
  final Set<UserModel> alreadyParticipants;
  const SearchParticipantsPage({super.key, required this.alreadyParticipants});
  @override
  State<SearchParticipantsPage> createState() => _SearchParticipantsPageState();
}

class _SearchParticipantsPageState extends State<SearchParticipantsPage> {
  bool _isLoading = false;
  final Set<UserModel> _participants = {};
  List<UserModel> _searchResults = [];
  final TextEditingController _textController = TextEditingController();
  final UserController _userController = UserController();

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    _fetchUsers();
  }

  _fetchUsers() async {
    var results = await _userController
        .getAllUsersBasicInfo(_textController.text.toLowerCase());
    var uid = await HelperFunctions.getUserUID();
    setState(() {
      _searchResults = results.where((element) => element.uid != uid).toList();
      _isLoading = false;
    });
  }

  _addParticipant(UserModel user) {
    bool isParticipant = _participants.contains(user) ||
        widget.alreadyParticipants
            .where((element) => element.uid == user.uid)
            .isNotEmpty;
    if (!isParticipant) {
      setState(() {
        _participants.add(user);
      });
      showSnackBar(context, Colors.green,
          "Se agregó a ${user.name} a la lista de participantes");
    } else {
      showSnackBar(context, Constants.indigoDye,
          "El usuario ${user.name} ya está en la lista de participantes");
    }
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
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFFFAFAFA),
        // automaticallyImplyLeading: false,
        leadingWidth: 30,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Constants.indigoDye,
          onPressed: () {
            Navigator.pop(context, _participants);
          },
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: _isLoading
            ? const Loader()
            : ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                      title: Text(_searchResults[index].name),
                      leading: _searchResults[index].profilePic.isEmpty
                          ? const CircleAvatar(
                              foregroundColor: Colors.grey,
                              backgroundColor: Colors.transparent,
                              radius: 30,
                              child: Icon(
                                Icons.account_circle,
                                size: 60,
                              ))
                          : CircleAvatar(
                              radius: 30,
                              backgroundImage: CachedNetworkImageProvider(
                                  _searchResults[index].profilePic),
                            ),
                      trailing: TextButton(
                          onPressed: () =>
                              _addParticipant(_searchResults[index]),
                          child: const Text("Añadir",
                              style: TextStyle(color: Constants.indigoDye))));
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
                itemCount: _searchResults.length),
      ),
    );
  }
}
