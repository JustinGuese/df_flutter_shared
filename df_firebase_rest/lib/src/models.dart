abstract class FirebaseRestUser {
  String get uid;
  String? get email;
  Future<String?> getIdToken({bool forceRefresh = false});
}
