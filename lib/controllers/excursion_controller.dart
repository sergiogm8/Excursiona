import 'dart:async';
import 'dart:io';

import 'package:battery_plus/battery_plus.dart';
import 'package:excursiona/controllers/user_controller.dart';
import 'package:excursiona/enums/marker_type.dart';
import 'package:excursiona/enums/message_type.dart';
import 'package:excursiona/helper/helper_functions.dart';
import 'package:excursiona/model/emergency_alert.dart';
import 'package:excursiona/model/excursion.dart';
import 'package:excursiona/model/excursion_participant.dart';
import 'package:excursiona/model/image_model.dart';
import 'package:excursiona/model/route.dart';
import 'package:excursiona/model/marker_model.dart';
import 'package:excursiona/model/message.dart';
import 'package:excursiona/model/recap_models.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/chat_service.dart';
import 'package:excursiona/services/excursion_service.dart';
import 'package:excursiona/services/storage_service.dart';
import 'package:excursiona/services/user_service.dart';
import 'package:excursiona/shared/utils.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ExcursionController {
  ExcursionController({this.excursionId});

  final String? excursionId;
  final ExcursionService _excursionService = ExcursionService();
  final ChatService _chatService = ChatService();

  int batteryLevel = 0;
  Timer? batteryTimer;
  Battery battery = Battery();
  RouteModel _route = RouteModel();

  var _lastDocumentFetched = null;

  Future createExcursion(
      Excursion excursion, Set<UserModel> participants) async {
    bool result = false;
    var currentUser = await UserController().getUserBasicInfo();
    result = await _excursionService.createExcursion(
        excursion, ExcursionParticipant.fromUserModel(currentUser));
    if (!result) return 'Hubo un error al crear la excursión';

    result =
        await _excursionService.inviteUsersToExcursion(excursion, participants);
    if (!result) return 'Hubo un error al enviar las invitaciones';

    return result;
  }

  Future leaveExcursion({String? excursionId}) async {
    excursionId ??= this.excursionId;
    await _excursionService.leaveExcursion(excursionId!);
    await HelperFunctions.deleteExcursionSession();
  }

  Future<bool> joinExcursion(String excursionID) async {
    var currentUser = await UserController().getUserBasicInfo();
    return await _excursionService.joinExcursion(
        excursionID, ExcursionParticipant.fromUserModel(currentUser));
  }

  Future<bool> inviteUserToExcursion(Excursion excursion, String userId) async {
    return await _excursionService.inviteUserToExcursion(excursion, userId);
  }

  Future<bool> inviteUsersToExcursion(
      Excursion excursion, Set<UserModel> users) async {
    return await _excursionService.inviteUsersToExcursion(
      excursion,
      users,
    );
  }

  Future<bool> rejectExcursionInvitation(String excursionId) async {
    return await _excursionService.rejectExcursionInvitation(excursionId);
  }

  Future<bool> deleteUserFromExcursion(
      String excursionId, String userId) async {
    return await _excursionService.deleteUserFromExcursion(excursionId, userId);
  }

  Future<List<UserModel>> getParticipantsData({String? excursionId}) async {
    excursionId ??= this.excursionId;
    List<UserModel> participants = [];
    await _excursionService.getParticipantsData(excursionId!).then((query) {
      for (var participant in query) {
        participants
            .add(UserModel.fromMap(participant.data() as Map<String, dynamic>));
      }
    });
    return participants;
  }

  Future getParticipantData(String userId) async {
    return await _excursionService.getParticipantData(excursionId!,
        userId: userId);
  }

  shareCurrentLocation(Position coords, double speed, double distance) async {
    var userId = await HelperFunctions.getUserUID();
    var userPic = await HelperFunctions.getUserProfilePic();
    var userName = await HelperFunctions.getUserName();
    var batteryLevel =
        this.batteryLevel == 0 ? await battery.batteryLevel : this.batteryLevel;
    var marker = MarkerModel(
        id: userId!,
        position: LatLng(coords.latitude, coords.longitude),
        markerType: MarkerType.participant,
        userId: userId,
        ownerPic: userPic!,
        ownerName: userName!,
        timestamp: DateTime.now(),
        altitude: coords.altitude,
        speed: speed,
        distance: distance,
        batteryLevel: batteryLevel);
    _excursionService.shareCurrentLocation(marker, excursionId!);
    _route.addLocation(
        coords.latitude, coords.longitude, speed, coords.altitude, distance);
  }

  Stream<List<MarkerModel>> getMarkers({String? excursionId}) {
    excursionId ??= this.excursionId;
    return _excursionService.getMarkers(excursionId!);
  }

  Future<List<MarkerModel>> getUserMarkers({String? excursionId}) async {
    excursionId ??= this.excursionId;
    return await _excursionService.getUserMarkers(excursionId!);
  }

  uploadMarker(
      {required String excursionId,
      required String title,
      required MarkerType markerType,
      required Position position,
      File? image}) async {
    try {
      String imageDownloadURL = "";
      var userId = await HelperFunctions.getUserUID();
      var userName = await HelperFunctions.getUserName();
      var userPic = await HelperFunctions.getUserProfilePic();
      if (image != null) {
        imageDownloadURL = await StorageService().uploadMarkerImage(
            image: image, excursionId: excursionId, title: title);
        ImageModel imageModel = ImageModel(
          ownerId: userId!,
          ownerName: userName!,
          ownerPic: userPic!,
          imageUrl: imageDownloadURL,
          timestamp: DateTime.now(),
        );
        await UserController().saveImage(imageModel);
      }

      var marker = MarkerModel(
        id: Uuid().v1(),
        userId: userId!,
        ownerName: userName!,
        ownerPic: userPic!,
        title: title,
        position: LatLng(position.latitude, position.longitude),
        markerType: markerType,
        imageUrl: imageDownloadURL,
        timestamp: DateTime.now(),
      );
      await _excursionService.addMarkerToExcursion(
          marker: marker, excursionId: excursionId);
      UserController().updateUserMarkers(1);
    } catch (e) {
      throw Exception("Hubo un error al compartir el marcador: $e");
    }
  }

  Future<bool> uploadImages(List<XFile> images) async {
    int nImagesUploaded = 0;
    var userId = await HelperFunctions.getUserUID();
    var userName = await HelperFunctions.getUserName();
    var userPic = await HelperFunctions.getUserProfilePic();
    List<ImageModel> uploadedImages = [];

    for (var image in images) {
      String imageDownloadURL = await StorageService().uploadExcursionImage(
          image: File(image.path), excursionId: excursionId!);
      if (imageDownloadURL.isEmpty) {
        continue;
      }
      ImageModel imageModel = ImageModel(
          ownerId: userId!,
          ownerName: userName!,
          ownerPic: userPic!,
          imageUrl: imageDownloadURL,
          timestamp: DateTime.now());

      uploadedImages.add(imageModel);

      var uploaded = await _excursionService.addImageToExcursion(
          excursionId: excursionId!, imageModel: imageModel);
      if (uploaded) {
        nImagesUploaded++;
      }
    }

    try {
      UserController().updateUserPhotos(nImagesUploaded, uploadedImages);
    } catch (e) {
      rethrow;
    }
    return true;
  }

  Stream<List<ImageModel>> getImagesFromExcursion({String? excursionId}) {
    excursionId ??= this.excursionId;
    return _excursionService.getImagesFromExcursion(excursionId!);
  }

  initializeBatteryTimer() {
    batteryTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      battery.batteryLevel.then((value) => batteryLevel = value);
    });
  }

  sendTextMessage(String text) async {
    var userId = await HelperFunctions.getUserUID();
    var userName = await HelperFunctions.getUserName();
    var userPic = await HelperFunctions.getUserProfilePic();

    Message message = Message(
        senderID: userId!,
        senderName: userName!,
        senderPic: userPic!,
        text: text,
        timeSent: DateTime.now(),
        type: MessageType.text);
    await _chatService.sendGroupMessage(
        excursionId: excursionId!, message: message);
  }

  Stream<List<Message>> getMessages() {
    return _chatService.getGroupMessages(excursionId!);
  }

  sendAudioMessage(String path) async {
    var userId = await HelperFunctions.getUserUID();
    var userName = await HelperFunctions.getUserName();
    var userPic = await HelperFunctions.getUserProfilePic();

    var audioUrl = await StorageService()
        .uploadAudioFile(audio: File(path), excursionId: excursionId!);
    if (audioUrl.isEmpty) {
      return false;
    }

    Message message = Message(
      senderID: userId!,
      senderName: userName!,
      senderPic: userPic!,
      text: audioUrl,
      timeSent: DateTime.now(),
      type: MessageType.audio,
    );

    return await _chatService.sendGroupMessage(
        excursionId: excursionId!, message: message);
  }

  saveUserRoute() async {
    _excursionService.saveUserRoute(_route, excursionId!);
  }

  Future<RouteModel> getUserRoute(String? userId) async {
    var route =
        await _excursionService.getUserRoute(excursionId!, userId: userId);
    _route = route;
    return route;
  }

  Future<StatisticRecap> getExcursionData(String? userId,
      {String? excursionId}) async {
    excursionId ??= this.excursionId;
    try {
      var participant = await _excursionService.getParticipantData(excursionId!,
          userId: userId);
      var participants = await getParticipantsData();
      var nParticipants = participants.length;
      var nPhotos = await StorageService().getNumberOfImages(excursionId);
      var nMarkers = await _excursionService.getNumberOfMarkers(excursionId);
      var statistics = StatisticRecap(
          startTime: participant.joinedAt!,
          endTime: participant.leftAt!,
          nParticipants: nParticipants,
          nPhotos: nPhotos,
          nMarkers: nMarkers,
          avgAltitude: _route.avgAltitude,
          avgSpeed: _route.avgSpeed,
          distance: _route.distance);

      return statistics;
    } catch (e) {
      throw Exception(
          "Hubo algún error al obtener los datos de la excursión: $e");
    }
  }

  sendEmergencyAlert({required Position myPosition}) async {
    var userInfo = await UserController().getUserBasicInfo();
    var emergencyAlert = EmergencyAlert(
      id: userInfo.uid,
      requesterName: userInfo.name,
      requesterPic: userInfo.profilePic,
      position: LatLng(myPosition.latitude, myPosition.longitude),
    );
    return await _excursionService.sendEmergencyAlert(
        excursionId!, emergencyAlert);
  }

  Stream<List<EmergencyAlert>> getEmergencyAlert() {
    return _excursionService.getEmergencyAlert(excursionId!);
  }

  Future<bool> cancelEmergencyAlert() async {
    return await _excursionService.cancelEmergencyAlert(excursionId!);
  }

  saveExcursionSession(String excursionId) async {
    await HelperFunctions.saveExcursionSession(excursionId);
  }

  Future<Excursion?> getActiveExcursion() async {
    var excursionId = await HelperFunctions.getExcursionSession();
    if (excursionId == null) return null;
    return await _excursionService.getExcursion(excursionId);
  }

  Future<Excursion> getExcursionById(String excursionId) async {
    try {
      var excursion = await _excursionService.getExcursion(excursionId);
      return excursion;
    } catch (e) {
      throw Exception("Hubo un error al obtener la excursión: $e");
    }
  }

  Future<List<ExcursionRecap>> getTLExcursions(int docsLimit) async {
    try {
      var docs = await _excursionService.getTLExcursions(
          docsLimit, _lastDocumentFetched);
      List<ExcursionRecap> excursions = [];
      docs.forEach((doc) {
        excursions
            .add(ExcursionRecap.fromMap(doc.data()! as Map<String, dynamic>));
      });
      excursions.sort((a, b) => b.date.compareTo(a.date));
      _lastDocumentFetched = docs.last;
      return excursions;
    } catch (e) {
      if (e.toString().contains("Bad state: No element")) {
        return [];
      }
      throw Exception("Hubo un error al obtener las excursiones: $e");
    }
  }

  updateUserStatistics(StatisticRecap statistics) async {
    UserService().updateUserStatistics(statistics);
  }
}
