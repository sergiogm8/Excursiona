import 'dart:io';

import 'package:excursiona/controllers/excursion_controller.dart';
import 'package:excursiona/enums/marker_type.dart';
import 'package:excursiona/shared/constants.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:excursiona/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AddMarkerDialog extends StatefulWidget {
  const AddMarkerDialog(
      {super.key,
      required this.markerType,
      required this.currentPosition,
      required this.excursionId});

  final Position currentPosition;
  final String excursionId;
  final MarkerType markerType;

  @override
  State<AddMarkerDialog> createState() => _AddMarkerDialogState();
}

class _AddMarkerDialogState extends State<AddMarkerDialog> {
  Color color = Constants.indigoDye;
  TextEditingController titleController = TextEditingController();

  bool _canEditCoords = false;
  final _formKey = GlobalKey<FormState>();
  IconData? _icon;
  File? _image;
  final _latKey = GlobalKey<FormFieldState>();
  final _lngKey = GlobalKey<FormFieldState>();
  String _markerTitle = "";
  String? _title;
  bool _uploadedSuccessfully = true;
  bool _uploadingMarker = false;
  bool _useDefaultCoords = true;

  @override
  void initState() {
    super.initState();
    switch (widget.markerType) {
      case MarkerType.info:
        _icon = Constants.interestMarkerIcon;
        _title = Constants.interestMarkerText.toLowerCase();
        break;

      case MarkerType.warning:
        _icon = Constants.warningMarkerIcon;
        _title = Constants.warningMarkerText.toLowerCase();
        break;

      case MarkerType.rest:
        _icon = Constants.restMarkerIcon;
        _title = Constants.restMarkerText.toLowerCase();
        break;

      case MarkerType.custom:
        _icon = Constants.customMarkerIcon;
        _title = Constants.customMarkerText.toLowerCase();
        break;
      default:
        break;
    }
  }

  _addMarker() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _uploadingMarker = true;
    });
    try {
      if (_image != null) {
        await ExcursionController().uploadMarker(
            excursionId: widget.excursionId,
            title: _markerTitle,
            markerType: widget.markerType,
            position: widget.currentPosition,
            image: _image!);
      } else {
        await ExcursionController().uploadMarker(
            excursionId: widget.excursionId,
            title: _markerTitle,
            markerType: widget.markerType,
            position: widget.currentPosition);
      }
      Navigator.pop(context);
      showSnackBar(context, Colors.green, "Marcador compartido correctamente.");
    } catch (e) {
      showSnackBar(context, Colors.red, e.toString());
    }
    setState(() {
      _uploadingMarker = false;
    });
  }

  _pickImage() async {
    PermissionStatus cameraPermissions = await Permission.camera.request();

    if (cameraPermissions.isGranted) {
      var image = await pickImageFromCamera();
      if (image != null) {
        setState(() {
          _image = File(image.path);
        });
      }
    } else {
      showSnackBar(context, Colors.red,
          "Es necesario dar permisos de cámara para poder tomar una foto");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Constants.darkWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            color: Constants.darkWhite,
          ),
          padding:
              const EdgeInsets.only(left: 20, right: 20, top: 25, bottom: 10),
          child: _uploadingMarker
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Loader(),
                    const SizedBox(height: 20),
                    Text(
                      "Compartiendo $_title... ",
                      style: GoogleFonts.inter(fontSize: 20),
                      textAlign: TextAlign.center,
                    )
                  ],
                )
              : Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(children: [
                          Icon(
                            _icon,
                            color: color,
                            size: 35,
                          ),
                          const SizedBox(width: 10),
                          Text("Compartir $_title",
                              style: GoogleFonts.inter(fontSize: 20)),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: titleController,
                        maxLength: 50,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isNotEmpty) {
                            return null;
                          } else {
                            return "Por favor ingrese un título";
                          }
                        },
                        onChanged: (value) => setState(() {
                          _markerTitle = value;
                        }),
                        decoration: blueTextInputDecoration.copyWith(
                          hintText: "Título*",
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(15)),
                          errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.red),
                              borderRadius: BorderRadius.circular(15)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(mainAxisSize: MainAxisSize.max, children: [
                        Flexible(
                          child: TextFormField(
                              key: _latKey,
                              keyboardType: TextInputType.number,
                              initialValue:
                                  widget.currentPosition.latitude.toString(),
                              enabled: _canEditCoords,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                if (value!.isNotEmpty) {
                                  return null;
                                } else {
                                  return "Campo obligatorio";
                                }
                              },
                              decoration: blueTextInputDecoration.copyWith(
                                  labelText: "Latitud*",
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 10),
                                  disabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Constants.indigoDye),
                                      borderRadius: BorderRadius.circular(15)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          color: Colors.red, width: 2),
                                      borderRadius: BorderRadius.circular(15)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.red),
                                      borderRadius: BorderRadius.circular(15)),
                                  filled: !_canEditCoords,
                                  fillColor: _canEditCoords
                                      ? Constants.darkWhite
                                      : Colors.grey[200]),
                              style: _canEditCoords
                                  ? TextStyle(color: Colors.black)
                                  : TextStyle(color: Constants.darkGrey)),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: TextFormField(
                            key: _lngKey,
                            keyboardType: TextInputType.number,
                            initialValue:
                                widget.currentPosition.longitude.toString(),
                            enabled: _canEditCoords,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value!.isNotEmpty) {
                                return null;
                              } else {
                                return "Campo obligatorio";
                              }
                            },
                            decoration: blueTextInputDecoration.copyWith(
                                labelText: "Longitud*",
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Colors.red, width: 2),
                                    borderRadius: BorderRadius.circular(15)),
                                errorBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.circular(15)),
                                disabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                        color: Constants.indigoDye),
                                    borderRadius: BorderRadius.circular(15)),
                                filled: !_canEditCoords,
                                fillColor: _canEditCoords
                                    ? Constants.darkWhite
                                    : Colors.grey[200]),
                            style: _canEditCoords
                                ? TextStyle(color: Colors.black)
                                : TextStyle(color: Constants.darkGrey),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 15),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            SizedBox(
                              height: 10,
                              width: 20,
                              child: Checkbox(
                                value: _useDefaultCoords,
                                onChanged: (value) {
                                  setState(() {
                                    _useDefaultCoords = value!;
                                    _canEditCoords = !value;
                                  });
                                  if (value == true) {
                                    _latKey.currentState!.reset();
                                    _lngKey.currentState!.reset();
                                  }
                                },
                                side: const BorderSide(
                                    color: Constants.indigoDye, width: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(2)),
                                fillColor: MaterialStateProperty.all(
                                    Constants.indigoDye),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text("Usar coordenadas automáticas",
                                style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.w400))
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: GestureDetector(
                            onTap: () => _pickImage(),
                            child: Container(
                              width: double.infinity,
                              padding: _image == null
                                  ? const EdgeInsets.all(10)
                                  : null,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  border:
                                      Border.all(color: Constants.indigoDye),
                                  image: _image != null
                                      ? DecorationImage(
                                          image: FileImage(_image!),
                                          fit: BoxFit.cover)
                                      : null),
                              child: _image == null
                                  ? Center(
                                      child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_rounded,
                                          color: Constants.lapisLazuli,
                                          size: 50,
                                        ),
                                        Text(
                                          "Pulsa aquí para añadir una imagen a tu marcador",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w300,
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ))
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              fixedSize: const Size(105, 30),
                              // side: const BorderSide(color: Colors.black, width: 1),
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            child: Text('Cancelar',
                                style: GoogleFonts.inter(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                          ElevatedButton(
                            onPressed: () => _addMarker(),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              fixedSize: const Size(105, 30),
                              backgroundColor: Constants.indigoDye,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Aceptar',
                                style: GoogleFonts.inter(
                                    fontSize: 16, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      if (!_uploadedSuccessfully)
                        const Text(
                          "Hubo un error al compartir el marcador. Inténtalo de nuevo.",
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
