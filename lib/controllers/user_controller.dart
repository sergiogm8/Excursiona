import 'package:excursiona/helper/helper_functions.dart';
import 'package:excursiona/model/user_model.dart';
import 'package:excursiona/services/user_service.dart';

class UserController {
  final UserService _userService = UserService();

  Future<UserModel> getUserBasicInfo() async {
    var name = await HelperFunctions.getUserName();
    var profilePic = await HelperFunctions.getUserProfilePic();
    var uid = await HelperFunctions.getUserUID();
    return UserModel(name: name!, profilePic: profilePic!, uid: uid!);
  }

  Stream<List<UserModel>> getAllUsersBasicInfo() {
    return _userService.getAllUsersBasicInfo();
  }
}
