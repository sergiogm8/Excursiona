import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/helper/helper_functions.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
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
  late final String currentId;

  @override
  void initState() {
    super.initState();
    _isLoading = true;
    setState(() {
      _participants.addAll(widget.alreadyParticipants);
    });
    _fetchUsers();
  }

  _fetchUsers() async {
    var results = await _userController
        .getAllUsersBasicInfo(_textController.text.toLowerCase());
    results = results
        .where((element) => !_participants
            .where(
                (alreadyParticipant) => alreadyParticipant.uid == element.uid)
            .isNotEmpty)
        .toList();
    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  _addParticipant(UserModel user) {
    setState(() {
      _participants.add(user);
      _searchResults.remove(user);
    });
    showSnackBar(context, Colors.green,
        "Se agregó a ${user.name} a la lista de participantes", 2);
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
                          ? CircleAvatar(
                              foregroundColor: Colors.grey,
                              backgroundColor: Colors.transparent,
                              radius: 30,
                              child: AccountAvatar(
                                  radius: 30, name: _searchResults[index].name))
                          : CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.transparent,
                              // backgroundImage: CachedNetworkImageProvider(
                              //     _searchResults[index].profilePic),
                              child: CachedNetworkImage(
                                imageUrl: _searchResults[index].profilePic,
                                placeholder: (context, url) => const Loader(),
                                placeholderFadeInDuration:
                                    const Duration(milliseconds: 300),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: imageProvider,
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              )),
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
