enum StorageLocation {
  local,
  cloud,
}

class UserProfile {
  final String name;
  final String email;
  final String phone;

  /// Optional: the account you’re syncing with (e.g. Google).
  final String? syncedEmail;

  /// Whether cloud sync is currently enabled.
  final bool isCloudSyncEnabled;

  /// Where data is primarily stored.
  final StorageLocation storageLocation;

  const UserProfile({
    this.name = '',
    this.email = '',
    this.phone = '',
    this.syncedEmail,
    this.isCloudSyncEnabled = false,
    this.storageLocation = StorageLocation.local,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? syncedEmail,
    bool? isCloudSyncEnabled,
    StorageLocation? storageLocation,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      syncedEmail: syncedEmail ?? this.syncedEmail,
      isCloudSyncEnabled: isCloudSyncEnabled ?? this.isCloudSyncEnabled,
      storageLocation: storageLocation ?? this.storageLocation,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'syncedEmail': syncedEmail,
    'isCloudSyncEnabled': isCloudSyncEnabled,
    'storageLocation': storageLocation.name,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      syncedEmail: json['syncedEmail'] as String?,
      isCloudSyncEnabled: json['isCloudSyncEnabled'] as bool? ?? false,
      storageLocation: _storageLocationFromString(
        json['storageLocation'] as String?,
      ),
    );
  }

  static StorageLocation _storageLocationFromString(String? value) {
    switch (value) {
      case 'cloud':
        return StorageLocation.cloud;
      case 'local':
      default:
        return StorageLocation.local;
    }
  }
}
