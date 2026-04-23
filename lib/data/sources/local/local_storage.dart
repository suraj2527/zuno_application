import 'package:get_storage/get_storage.dart';

class LocalStorage {
  static final _box = GetStorage();

  static void saveUser({
    required String firebaseUid,
    required String? name,
    required String? email,
    required String? photo,
    required String backendUserId,
  }) {
    _box.write('firebaseUid', firebaseUid);
    _box.write('name', name);
    _box.write('email', email);
    _box.write('photo', photo);
    _box.write('backendUserId', backendUserId);
  }

  static String? get backendUserId => _box.read('backendUserId');
  static String? get name => _box.read('name');
  static String? get email => _box.read('email');
  static String? get photo => _box.read('photo');
}
