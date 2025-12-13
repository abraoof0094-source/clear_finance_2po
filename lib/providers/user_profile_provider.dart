import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class UserProfileProvider extends ChangeNotifier {
  static const String _profileKey = 'user_profile';

  UserProfile _profile = const UserProfile();
  UserProfile get profile => _profile;

  UserProfileProvider() {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_profileKey);
    if (jsonString == null) return;

    try {
      final map = json.decode(jsonString) as Map<String, dynamic>;
      _profile = UserProfile.fromJson(map);
      notifyListeners();
    } catch (_) {
      // ignore corrupt data for now
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    String? syncedEmail,
    bool? isCloudSyncEnabled,
    StorageLocation? storageLocation,
  }) async {
    _profile = _profile.copyWith(
      name: name,
      email: email,
      phone: phone,
      syncedEmail: syncedEmail ?? _profile.syncedEmail,
      isCloudSyncEnabled: isCloudSyncEnabled ?? _profile.isCloudSyncEnabled,
      storageLocation: storageLocation ?? _profile.storageLocation,
    );
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, json.encode(_profile.toJson()));
  }

  Future<void> updateSyncSettings({
    String? syncedEmail,
    bool? isCloudSyncEnabled,
    StorageLocation? storageLocation,
  }) async {
    _profile = _profile.copyWith(
      syncedEmail: syncedEmail ?? _profile.syncedEmail,
      isCloudSyncEnabled: isCloudSyncEnabled ?? _profile.isCloudSyncEnabled,
      storageLocation: storageLocation ?? _profile.storageLocation,
    );
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, json.encode(_profile.toJson()));
  }
}
