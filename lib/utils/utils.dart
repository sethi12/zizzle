import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import '/services/alert_service.dart';
import '/services/auth_message_service.dart';
import '/services/database_service.dart';
import '/services/media_service.dart';
import '/services/storage_service.dart';

import '../services/navigation_service.dart';

PickImage(ImageSource source) async {
  final ImagePicker _imagepicker = ImagePicker();

  XFile? _file = await _imagepicker.pickImage(source: source);
  if (_file != null) {
    return _file.readAsBytes();
  }
  print("no image Selected");
}

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}

Future<void> registerservices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<AuthService>(AuthService());
  getIt.registerSingleton<Navigationservice>(Navigationservice());
  getIt.registerSingleton<AlertService>(AlertService());
  getIt.registerSingleton<MediaService>(MediaService());
  getIt.registerSingleton<StorageService>(StorageService());
  getIt.registerSingleton<DatabaseService>(DatabaseService());
}

String generatechatid({required String uid1, required String uid2}) {
  List uids = [uid1, uid2];
  uids.sort();
  String chatid = uids.fold("", (id, uid) => "$id$uid");
  return chatid;
}
