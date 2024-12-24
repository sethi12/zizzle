import 'package:shared_preferences/shared_preferences.dart';

class UserData {
  final String? username;
  final String? email;
  // final List<String> followers;
  UserData({required this.username,
    required this.email});
}

Future<UserData?> getUser() async {
  final prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? email = prefs.getString('email');
   // String? followers = prefs.getStringList('followers') ;
   // print(followers);
  return UserData(username: username, email: email);
}
