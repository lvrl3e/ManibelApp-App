/// Very simple in-memory session store.
///
/// There's no backend yet, so this is standing in for what would normally
/// be an AuthService / user provider backed by an API. It only lives for
/// as long as the app process does — nothing is persisted to disk, so a
/// full app restart will lose it. When a real backend exists, replace the
/// body of these methods with actual API calls (and consider a proper
/// state-management solution — Provider/Riverpod/Bloc — instead of a raw
/// singleton) and swap plaintext `password` for a token-based session.
class UserSession {
  UserSession._internal();

  static final UserSession instance = UserSession._internal();

  String? fullName;
  String? mobileNumber;
  DateTime? dateOfBirth;
  String? commuterId;

  // TODO: NEVER keep plaintext passwords once a backend exists. This only
  // exists so ChangePasswordScreen has something to validate the "current
  // password" field against while everything is still mocked locally.
  String? password;

  bool get isSignedIn => fullName != null;

  /// Called after a successful sign-up.
  void signUp({
    required String fullName,
    required String mobileNumber,
    required String password,
  }) {
    this.fullName = fullName;
    this.mobileNumber = mobileNumber;
    this.password = password;
    commuterId ??= _generateCommuterId();
  }

  /// Called after a successful login, once a real backend can return the
  /// user's stored profile. For now, pass whatever the login screen has
  /// (e.g. the mobile number that was typed in).
  void logIn({
    required String mobileNumber,
    String? fullName,
    String? password,
  }) {
    this.mobileNumber = mobileNumber;
    if (fullName != null) this.fullName = fullName;
    if (password != null) this.password = password;
    commuterId ??= _generateCommuterId();
  }

  /// Called from SettingsScreen when the user saves profile changes.
  void updateProfile({
    String? fullName,
    String? mobileNumber,
    DateTime? dateOfBirth,
  }) {
    if (fullName != null && fullName.isNotEmpty) this.fullName = fullName;
    if (mobileNumber != null) this.mobileNumber = mobileNumber;
    this.dateOfBirth = dateOfBirth;
  }

  /// Returns false if [currentPassword] doesn't match what's on file, so
  /// the caller can show an error instead of silently "succeeding".
  bool updatePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    if (password != null && currentPassword != password) {
      return false;
    }
    password = newPassword;
    return true;
  }

  void signOut() {
    fullName = null;
    mobileNumber = null;
    dateOfBirth = null;
    password = null;
    commuterId = null;
  }

  String _generateCommuterId() {
    final suffix = (DateTime.now().millisecondsSinceEpoch % 100000)
        .toString()
        .padLeft(5, '0');
    return 'CM-$suffix';
  }
}