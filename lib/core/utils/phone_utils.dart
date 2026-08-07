/// Philippine mobile numbers show up in two common shapes across this app:
/// signup collects `+63XXXXXXXXXX`, login collects `09XXXXXXXXX`. Both
/// represent the same number, so anything that needs to *compare* two
/// phone numbers (e.g. matching a login attempt against a stored account)
/// should normalize both sides first with [PhoneUtils.toE164].
class PhoneUtils {
  const PhoneUtils._();

  /// Converts a PH mobile number in either local (`09XXXXXXXXX`) or
  /// international (`+63XXXXXXXXXX`) form into a canonical
  /// `+63XXXXXXXXXX` (E.164) string. Non-digit characters (spaces,
  /// dashes) are stripped first.
  static String toE164(String phone) {
    final trimmed = phone.trim();
    if (trimmed.startsWith('+63')) {
      return '+63${trimmed.substring(3).replaceAll(RegExp(r'\D'), '')}';
    }

    final digitsOnly = trimmed.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.startsWith('63')) {
      return '+$digitsOnly';
    }
    if (digitsOnly.startsWith('0')) {
      return '+63${digitsOnly.substring(1)}';
    }
    return '+63$digitsOnly';
  }
}