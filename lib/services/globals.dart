library globals;

Map<String, dynamic>? _userData;

Map<String, dynamic>? get userData => _userData;

set userData(Map<String, dynamic>? data) {
  _userData = data;
}

Future<void> signOut() async {
  // Clear user data
  _userData = null;
}
