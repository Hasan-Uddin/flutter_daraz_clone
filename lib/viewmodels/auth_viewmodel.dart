import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthViewModel extends ChangeNotifier {
  final ApiService _api;
  AuthViewModel(this._api);

  User? user;
  bool isLoading = false;
  String? errorMessage;

  bool get isLoggedIn => user != null;

  Future<void> login(String username, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      // FakeStore login gives a token but no user id inside it.
      // call login to verify credentials, then fetch user #1
      // because the demo account (johnd) is user id 1.
      await _api.login(username, password);
      user = await _api.fetchUser(1);
    } catch (e) {
      errorMessage = 'Invalid username or password';
    }

    isLoading = false;
    notifyListeners();
  }

  void logout() {
    user = null;
    notifyListeners();
  }
}
