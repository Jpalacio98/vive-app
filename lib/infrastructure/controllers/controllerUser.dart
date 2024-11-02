import 'package:get/get.dart';
import 'package:vive_app/domain/models/user.dart';

class ControllerUser extends GetxController {
  final Rxn<Usuario> _user = Rxn<Usuario>();
  Usuario? get user => _user.value;

  Future<void> DataUser(Usuario user) async {
    _user.value = user;
  }

}