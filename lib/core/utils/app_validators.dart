/// Reusable Form Input Validation Utility Functions
class AppValidators {
  AppValidators._();

  static String? required(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value, [String message = 'Enter a valid email address']) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return message;
    }
    return null;
  }

  static String? phone(String? value, [String message = 'Enter a valid phone number']) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return message;
    }
    return null;
  }

  static String? minLength(String? value, int minLen, [String? message]) {
    if (value == null || value.trim().length < minLen) {
      return message ?? 'Must be at least $minLen characters long';
    }
    return null;
  }

  static String? password(String? value, [int minLength = 6]) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }
}
