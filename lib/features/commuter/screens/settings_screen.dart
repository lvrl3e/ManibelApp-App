import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/user_session.dart';
import '../../../core/utils/phone_utils.dart';
import '../../auth/screens/commuter_login_screen.dart';
import 'change_password_screen.dart';

/// Value returned by [SettingsScreen] via `Navigator.pop` when the user
/// successfully saves their changes, so the caller can update its own
/// state (e.g. the name shown on the dashboard) without a refetch.
class SettingsResult {
  const SettingsResult({
    required this.fullName,
    required this.mobileNumber,
    required this.dateOfBirth,
    required this.photoPath,
  });

  final String fullName;
  final String mobileNumber;
  final DateTime? dateOfBirth;
  final String? photoPath;
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.initialFullName,
    this.initialMobileNumber,
    this.initialDateOfBirth,
  });

  /// Seed values from the caller (e.g. the dashboard's currently-held
  /// commuter name) so this screen always reflects the latest saved state,
  /// not a hard-coded default.
  final String? initialFullName;
  final String? initialMobileNumber;
  final DateTime? initialDateOfBirth;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // TODO: seed these from the authenticated user's profile once available.
  late final TextEditingController _fullNameController;
  late final TextEditingController _mobileNumberController;

  DateTime? _dateOfBirth;
  String? _dateOfBirthError;

  /// Local filesystem path to the currently selected profile photo, or
  /// null if none has been set. Seeded from whatever was persisted in
  /// [UserSession], same as the name/mobile fields.
  String? _photoPath;

  // Matches 09XXXXXXXXX (11 digits) or +63XXXXXXXXXX (10 digits after +63).
  static final RegExp _phMobileRegex =
      RegExp(r'^(?:\+63\d{10}|09\d{9})$');

  // Only letters, spaces, and a few common name characters.
  static final RegExp _fullNameRegex = RegExp(r"^[A-Za-zÀ-ÿ.'\- ]+$");

  static const int _minAge = 13;

  @override
  void initState() {
    super.initState();
    // Prefer whatever the caller (e.g. the dashboard) explicitly passed in;
    // fall back to the session (in case this screen is opened directly),
    // and finally to a placeholder if neither is available yet.
    _fullNameController = TextEditingController(
      text: widget.initialFullName ??
          UserSession.instance.fullName ??
          'Juan Dela Cruz',
    );
    _mobileNumberController = TextEditingController(
      text: widget.initialMobileNumber ??
          UserSession.instance.mobileNumber ??
          '',
    );
    _dateOfBirth = widget.initialDateOfBirth ?? UserSession.instance.dateOfBirth;
    _photoPath = UserSession.instance.photoPath;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
        _dateOfBirthError = _validateDateOfBirth(picked);
      });
    }
  }

  String? _validateFullName(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Full name is required';
    }
    if (trimmed.length < 2) {
      return 'Full name is too short';
    }
    if (trimmed.length > 60) {
      return 'Full name is too long';
    }
    if (!_fullNameRegex.hasMatch(trimmed)) {
      return 'Full name can only contain letters, spaces, hyphens, and apostrophes';
    }
    if (!trimmed.contains(' ')) {
      return 'Please enter your first and last name';
    }
    return null;
  }

  String? _validateMobileNumber(String? value) {
    final trimmed = (value ?? '').trim();
    if (trimmed.isEmpty) {
      return 'Mobile number is required';
    }
    final normalized = trimmed.replaceAll(RegExp(r'[\s-]'), '');
    if (!_phMobileRegex.hasMatch(normalized)) {
      return 'Enter a valid PH mobile number (e.g. 09XXXXXXXXX or +63XXXXXXXXXX)';
    }
    return null;
  }

  String? _validateDateOfBirth(DateTime? value) {
    if (value == null) {
      return 'Date of birth is required';
    }
    final now = DateTime.now();
    if (value.isAfter(now)) {
      return 'Date of birth cannot be in the future';
    }
    final age = _calculateAge(value, now);
    if (age < _minAge) {
      return 'You must be at least $_minAge years old';
    }
    if (age > 120) {
      return 'Please enter a valid date of birth';
    }
    return null;
  }

  int _calculateAge(DateTime dob, DateTime now) {
    int age = now.year - dob.year;
    final hasHadBirthdayThisYear =
        (now.month > dob.month) ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hasHadBirthdayThisYear) age--;
    return age;
  }

  String get _dateOfBirthLabel {
    if (_dateOfBirth == null) return 'Month, Day, Year';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    final d = _dateOfBirth!;
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  Future<void> _handleChangePhoto() async {
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(sheetContext, _PhotoAction.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(sheetContext, _PhotoAction.gallery),
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFD32F2F),
                ),
                title: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Color(0xFFD32F2F)),
                ),
                onTap: () => Navigator.pop(sheetContext, _PhotoAction.remove),
              ),
          ],
        ),
      ),
    );

    if (!mounted) return;

    // Sheet was dismissed (tap outside / back button) without choosing
    // anything — leave the current photo untouched.
    if (action == null) return;

    if (action == _PhotoAction.remove) {
      // Staged only — not written to UserSession until Save Changes is
      // tapped, same as the name/mobile/DOB fields below.
      setState(() => _photoPath = null);
      return;
    }

    final source = action == _PhotoAction.camera
        ? ImageSource.camera
        : ImageSource.gallery;

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );

    if (picked == null || !mounted) return; // user cancelled the picker

    // Staged only — not written to UserSession until Save Changes is
    // tapped, so backing out of this screen leaves the stored photo
    // untouched.
    setState(() => _photoPath = picked.path);
  }

  void _handleChangePassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
    );
  }

  void _handleTwoFactorAuth() {
    // TODO: navigate to the two-factor authentication setup screen.
  }

  void _handleLogout() {
    // TODO: clear auth token / session / cached user data here first.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CommuterLoginScreen()),
      (route) => false,
    );
  }

  Future<void> _handleSave() async {
    final formValid = _formKey.currentState?.validate() ?? false;
    final dobError = _validateDateOfBirth(_dateOfBirth);

    setState(() => _dateOfBirthError = dobError);

    if (!formValid || dobError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fix the highlighted fields.')),
      );
      return;
    }

    // TODO: persist these to a real backend once one exists. For now, keep
    // the local session in sync so other screens see the update too.
    final updatedName = _fullNameController.text.trim();
    final updatedMobile = PhoneUtils.toE164(_mobileNumberController.text.trim());

    await UserSession.instance.updateProfile(
      fullName: updatedName,
      mobileNumber: updatedMobile,
      dateOfBirth: _dateOfBirth,
    );
    await UserSession.instance.updatePhoto(_photoPath);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved.')),
    );

    // Hand the updated profile back to whoever pushed this screen (e.g. the
    // dashboard) so it can update its own state — the name shown in the
    // drawer / welcome card, etc.
    Navigator.of(context).pop(
      SettingsResult(
        fullName: updatedName,
        mobileNumber: updatedMobile,
        dateOfBirth: _dateOfBirth,
        photoPath: _photoPath,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              _TopBar(onBack: () => Navigator.of(context).maybePop()),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Account Settings'),
              const SizedBox(height: 16),
              Center(
                child: _ProfilePhoto(
                  photoPath: _photoPath,
                  onEditTap: _handleChangePhoto,
                ),
              ),
              const SizedBox(height: 24),
              _SettingsField(
                label: 'Full Name',
                controller: _fullNameController,
                hintText: 'Enter your full name',
                validator: _validateFullName,
              ),
              const SizedBox(height: 12),
              _SettingsField(
                label: 'Mobile Number',
                controller: _mobileNumberController,
                hintText: '+63 XXX XXX XXXX',
                keyboardType: TextInputType.phone,
                validator: _validateMobileNumber,
              ),
              const SizedBox(height: 12),
              _SettingsDateField(
                label: 'Date of Birth',
                valueLabel: _dateOfBirthLabel,
                hasValue: _dateOfBirth != null,
                errorText: _dateOfBirthError,
                onTap: _pickDateOfBirth,
              ),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Security'),
              const SizedBox(height: 12),
              _SecurityItem(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                onTap: _handleChangePassword,
              ),
              const SizedBox(height: 12),
              _SecurityItem(
                icon: Icons.verified_user_outlined,
                label: 'Two Factor Authentication',
                onTap: _handleTwoFactorAuth,
              ),
              const SizedBox(height: 24),
              _SaveButton(onTap: _handleSave),
              const SizedBox(height: 12),
              _LogOutButton(onTap: _handleLogout),
            ],
          ),
        ),
      ),
    );
  }
}

/// Result of the change-photo bottom sheet. Kept separate from
/// [ImageSource] so "remove" has its own case instead of colliding with
/// a real camera/gallery choice, and so `null` unambiguously means "sheet
/// dismissed without picking anything."
enum _PhotoAction { camera, gallery, remove }

/// -----------------------------------------------------------------------
/// TOP BAR
/// -----------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 2,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.arrow_back, size: 20, color: Colors.black87),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.black.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage your account and preferences',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: Colors.black,
      ),
    );
  }
}

/// -----------------------------------------------------------------------
/// PROFILE PHOTO
/// -----------------------------------------------------------------------

class _ProfilePhoto extends StatelessWidget {
  const _ProfilePhoto({required this.onEditTap, this.photoPath});

  final VoidCallback onEditTap;
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 130,
            height: 130,
            decoration: BoxDecoration(
              color: const Color(0xFFE85D75),
              shape: BoxShape.circle,
              image: photoPath != null
                  ? DecorationImage(
                      image: FileImage(File(photoPath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photoPath == null
                ? const Icon(
                    Icons.person_rounded,
                    size: 70,
                    color: Colors.white,
                  )
                : null,
          ),
          Positioned(
            right: -6,
            bottom: 8,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black87, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 20,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// -----------------------------------------------------------------------
/// EDITABLE TEXT FIELD (Full Name / Mobile Number)
/// -----------------------------------------------------------------------

class _SettingsField extends StatelessWidget {
  const _SettingsField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E6E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.only(top: 6),
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              errorStyle: const TextStyle(
                fontSize: 11,
                color: Color(0xFFD32F2F),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// -----------------------------------------------------------------------
/// DATE OF BIRTH FIELD
/// -----------------------------------------------------------------------

class _SettingsDateField extends StatelessWidget {
  const _SettingsDateField({
    required this.label,
    required this.valueLabel,
    required this.hasValue,
    required this.onTap,
    this.errorText,
  });

  final String label;
  final String valueLabel;
  final bool hasValue;
  final VoidCallback onTap;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasError
                    ? const Color(0xFFD32F2F)
                    : const Color(0xFFE6E6E7),
                width: hasError ? 1.4 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        valueLabel,
                        style: TextStyle(
                          fontSize: 14,
                          color: hasValue
                              ? Colors.black87
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFD32F2F),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// -----------------------------------------------------------------------
/// SECURITY LIST ITEM
/// -----------------------------------------------------------------------

class _SecurityItem extends StatelessWidget {
  const _SecurityItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E6E7)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: Colors.black87),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -----------------------------------------------------------------------
/// SAVE BUTTON
/// -----------------------------------------------------------------------

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, size: 20, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Save Changes',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// -----------------------------------------------------------------------
/// LOG OUT BUTTON
/// -----------------------------------------------------------------------

class _LogOutButton extends StatelessWidget {
  const _LogOutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6B9BE),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE0808A)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, size: 20, color: Colors.black87),
            SizedBox(width: 10),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}