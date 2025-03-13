import 'package:flutter/material.dart';
import 'package:mobile_cashpath/core/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  // ✅ Fetch User Profile
  Future<void> loadUserProfile() async {
    final data = await AuthService.getUserProfile();
    if (data != null) {
      _user = data['user'];
      notifyListeners();
    }
  }

  // ✅ Logout User
  Future<void> logout() async {
    await AuthService.logoutUser();
    _user = null;
    notifyListeners();
  }
}
