class AppValidationHelper {
  /// Validate if the input is not empty.
  static String? validateRequired(
    String? value, {
    String fieldName = "This field",
  }) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required.";
    }
    return null;
  }

  /// Validate email format.
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required.";
    }
    const emailPattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    final regExp = RegExp(emailPattern);
    if (!regExp.hasMatch(value)) {
      return "Enter a valid email address.";
    }
    return null;
  }

  /// Validate password (min 6 characters, at least 1 letter & 1 number).
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required.";
    }
    if (value.length < 6) {
      return "Password must be at least 6 characters.";
    }
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(value)) {
      return "Password must contain at least 1 letter and 1 number.";
    }
    return null;
  }

  /// Validate phone number (supports international format).
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required.";
    }
    const phonePattern = r'^\+?[0-9]{10,15}$';
    final regExp = RegExp(phonePattern);
    if (!regExp.hasMatch(value)) {
      return "Enter a valid phone number.";
    }
    return null;
  }

  /// Validate name (only letters allowed).
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required.";
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return "Enter a valid name (only letters allowed).";
    }
    return null;
  }

  /// Validate numeric input (only numbers allowed).
  static String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "This field is required.";
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return "Enter a valid number.";
    }
    return null;
  }

  /// Validate username (alphanumeric & underscores, min 3 chars).
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Username is required.";
    }
    if (value.length < 3) {
      return "Username must be at least 3 characters.";
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return "Username can only contain letters, numbers, and underscores.";
    }
    return null;
  }

  /// Validate custom length (min & max characters).
  static String? validateLength(String? value, {int min = 3, int max = 50}) {
    if (value == null || value.trim().isEmpty) {
      return "This field is required.";
    }
    if (value.length < min) {
      return "Must be at least $min characters.";
    }
    if (value.length > max) {
      return "Cannot exceed $max characters.";
    }
    return null;
  }

  /// Validate if two fields match (useful for password confirmation).
  static String? validateMatch(
    String? value,
    String? compareWith, {
    String fieldName = "Fields",
  }) {
    if (value != compareWith) {
      return "$fieldName do not match.";
    }
    return null;
  }
}
