import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:kajani/core/constants/hive_table_constants.dart';
import 'package:kajani/features/auth/data/models/auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';


final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  //database init
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();

    final path = '${directory.path}/${HiveTableConstants.dbName}';
    Hive.init(path);

    _registerAdapter();
    await openBoxes();
  }

  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstants.authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

  }

  // open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<AuthHiveModel>(HiveTableConstants.authTable);

  }

  //close Boxes
  Future<void> close() async {
    await Hive.close();
  }

  //==============Auth Queries ================
  Box<AuthHiveModel> get _authBox =>
      Hive.box<AuthHiveModel>(HiveTableConstants.authTable);

  Future<AuthHiveModel> registerUser(AuthHiveModel model) async {
    await _authBox.put(model.authId, model);
    return model;
  }

  //login User
  Future<AuthHiveModel?> loginUser(String email, String password) async {
    final users = _authBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  // logout
  Future<void> logoutUser() async {}

  //get current user
  AuthHiveModel? getCurrentUser(String authId) {
    return _authBox.get(authId);
  }

  //is email exists
  bool isEmailExists(String email) {
    final users = _authBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }

  // Get user by ID
  AuthHiveModel? getUserById(String authId) {
    return _authBox.get(authId);
  }

  // Get user by email
  AuthHiveModel? getUserByEmail(String email) {
    try {
      return _authBox.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  // Update user
  Future<bool> updateUser(AuthHiveModel user) async {
    if (_authBox.containsKey(user.authId)) {
      await _authBox.put(user.authId, user);
      return true;
    }
    return false;
  }

  // Delete user
  Future<void> deleteUser(String authId) async {
    await _authBox.delete(authId);
  }

  
}
