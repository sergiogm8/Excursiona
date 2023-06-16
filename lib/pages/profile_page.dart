import 'package:cached_network_image/cached_network_image.dart';
import 'package:excursiona/controllers/auth_controller.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/pages/auth_page.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/account_avatar.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() async {
    try {
      var user = await _userController.getUserData();
      setState(() {
        _userModel = user;
        _profilePic = user.profilePic;
        _isLoading = false;
      });
    } catch (e) {
      showSnackBar(context, Colors.red, e.toString());
    }
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
                PermissionStatus cameraPermissions =
                    await Permission.camera.request();

                if (cameraPermissions.isGranted) {
                  var result = await pickImageFromCamera();
                  if (result != null) {
                    _updateProfilePic(result);
                  }
                } else {
                  showSnackBar(context, Colors.red,
                      "Es necesario dar permisos de cámara para poder tomar una foto");
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
                PermissionStatus storagePermissions =
                    await Permission.storage.request();
                if (storagePermissions.isGranted) {
                  var result = await imagePicker.pickImage(
                      source: ImageSource.gallery, imageQuality: 65);
                  if (result != null) {
                    _updateProfilePic(result);
                  }
                } else {
                  showSnackBar(context, Colors.red,
                      "Es necesario dar permisos de almacenamiento para poder abrir la galería");
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
    return Scaffold(
      body: _isLoading
          ? const Loader()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IntrinsicHeight(
                    child: Container(
                      // height: MediaQuery.of(context).size.height * 0.25,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                      ),
                      padding: const EdgeInsets.only(top: 5, bottom: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 32.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Stack(
                                  children: [
                                    _profilePic.isEmpty
                                        ? AccountAvatar(
                                            radius: 50, name: _userModel!.name)
                                        : CircleAvatar(
                                            radius: 50,
                                            backgroundColor:
                                                Constants.darkWhite,
                                            child: CachedNetworkImage(
                                              imageUrl: _profilePic,
                                              placeholder: (context, url) =>
                                                  Container(
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Constants.darkWhite,
                                                      ),
                                                      child: const Loader()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                              placeholderFadeInDuration:
                                                  const Duration(
                                                      milliseconds: 300),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      Container(
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover),
                                                ),
                                              ),
                                            )),
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
                                  width: 24,
                                ),
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(_userModel!.name,
                                          style: GoogleFonts.inter(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white)),
                                      const SizedBox(height: 5),
                                      Text(_userModel!.email,
                                          style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 16)),
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
                        horizontal: 16.0, vertical: 24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Resumen de actividad",
                            style: GoogleFonts.inter(
                                fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    StatisticItem("Excursiones completadas",
                                        _userModel!.nExcursions.toString()),
                                    const SizedBox(width: 12),
                                    StatisticItem("Distancia total",
                                        "${_userModel!.totalDistance.toStringAsFixed(2)} km"),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    StatisticItem("Tiempo dedicado",
                                        "${_userModel!.totalTime.inHours.toString()}h ${(_userModel!.totalTime.inMinutes % 60).toString()}min"),
                                    const SizedBox(width: 12),
                                    StatisticItem("Velocidad media",
                                        "${_userModel!.avgSpeed.toStringAsFixed(2)} km/h"),
                                  ],
                                ),
                                const SizedBox(height: 40),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    StatisticItem("Imágenes compartidas",
                                        _userModel!.nPhotos.toString()),
                                    const SizedBox(width: 12),
                                    StatisticItem("Marcadores compartidos",
                                        _userModel!.nMarkers.toString()),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ]),
                  )
                ],
              ),
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

class StatisticItem extends StatelessWidget {
  final String title;
  final String value;
  const StatisticItem(this.title, this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
