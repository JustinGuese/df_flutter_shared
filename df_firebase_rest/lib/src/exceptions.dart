class FirebaseRestAuthException implements Exception {
  final String code;

  FirebaseRestAuthException(this.code);

  @override
  String toString() => 'FirebaseRestAuthException: $code';
}
