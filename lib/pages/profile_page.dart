import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/helper/helper_functions.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/pages/auth_page.dart';
import 'package:excursiona/services/auth_service.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserController _userController = UserController();
  UserModel? _userModel;
  var _profilePic = "";
  bool _isLoading = true;
  var data = {
    'Excursiones realizadas': '0',
    'Kilómetros recorridos': '0',
    'Tiempo dedicado': '105'
  };

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    var user = await _userController.getUserBasicInfo();
    setState(() {
      _userModel = user;
      _profilePic = user.profilePic;
      _isLoading = false;
    });
  }

  _updateProfilePic(XFile image) async {
    try {
      showDialog(
          barrierColor: Colors.white.withOpacity(0.8),
          barrierDismissible: false,
          context: context,
          builder: (_) => const Loader());
      var newPic = await _userController.updateProfilePic(image.path);
      setState(() {
        _profilePic = newPic;
      });
      Navigator.pop(context);
      showSnackBar(context, Colors.green, "Foto de perfil actualizada");
    } catch (e) {
      showSnackBar(context, Colors.red, e.toString());
    }
  }

  Widget _imagePickerBottomSheet() {
    ImagePicker imagePicker = ImagePicker();
    return IntrinsicHeight(
      child: Container(
        // height: MediaQuery.of(context).size.height * 0.23,
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
        child: Column(
          children: [
            Text(
              "Elegir foto de perfil",
              style:
                  GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Icon(Icons.camera, color: Constants.indigoDye),
              title: const Text(
                "Cámara",
              ),
              onTap: () async {
                Navigator.pop(context);
                var result =
                    await imagePicker.pickImage(source: ImageSource.camera);
                if (result != null) {
                  _updateProfilePic(result);
                }
              },
            ),
            ListTile(
              minLeadingWidth: 10,
              leading: const Icon(
                Icons.photo_library,
                color: Constants.indigoDye,
              ),
              title: const Text("Galería"),
              onTap: () async {
                Navigator.pop(context);
                var result =
                    await imagePicker.pickImage(source: ImageSource.gallery);
                if (result != null) {
                  _updateProfilePic(result);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Loader()
        : Scaffold(
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  elevation: 5,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(15),
                  )),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(15),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SafeArea(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () {
                                _logout();
                              },
                              icon: const Icon(
                                Icons.exit_to_app_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Stack(
                                children: [
                                  _userModel!.profilePic.isEmpty
                                      ? AccountAvatar(
                                          radius: 45, name: _userModel!.name)
                                      : CircleAvatar(
                                          radius: 45,
                                          backgroundImage:
                                              CachedNetworkImageProvider(
                                                  _profilePic),
                                        ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Constants.lapisLazuli),
                                      height: 35,
                                      width: 35,
                                      child: Center(
                                        child: IconButton(
                                          icon: Icon(Icons.edit_outlined),
                                          onPressed: () {
                                            showModalBottomSheet(
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                    top: Radius.circular(15),
                                                  ),
                                                ),
                                                context: context,
                                                builder: (builder) =>
                                                    _imagePickerBottomSheet());
                                          },
                                          color: Colors.white,
                                          iconSize: 20,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(_userModel!.name,
                                        style: GoogleFonts.inter(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
                                    const SizedBox(height: 5),
                                    Text(_userModel!.email,
                                        style: GoogleFonts.inter(
                                            color: Colors.white, fontSize: 16)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Resumen de actividad",
                          style: GoogleFonts.inter(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                        ListView.separated(
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              var entry = data.entries.elementAt(index);
                              return Row(
                                children: [
                                  Text(
                                    entry.key,
                                    style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const Spacer(),
                                  Text(entry.value.toString(),
                                      style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w300)),
                                ],
                              );
                            },
                            separatorBuilder: (context, index) => Divider(),
                            itemCount: data.length),
                        ElevatedButton(
                            onPressed: () => _logout(),
                            child: const Text("Cerrar sesión")),
                      ]),
                )
              ],
            ),
          );
  }

  void _logout() async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: const Text("Cerrar sesión"),
              content: const Text("¿Seguro que quieres cerrar la sesión?"),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cancel)),
                IconButton(
                  onPressed: () async {
                    _signout();
                  },
                  icon: const Icon(Icons.check),
                ),
              ]);
        });
  }

  void _signout() async {
    var couldExit = await AuthController().signOut();
    if (couldExit != true) {
      Navigator.pop(context);
      showSnackBar(context, Colors.red, couldExit);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthPage()),
        (route) => false);
  }
}
