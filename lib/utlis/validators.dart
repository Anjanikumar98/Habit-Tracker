class Validators {
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _nameRegExp = RegExp(r'^[a-zA-Z\s]+$');

  // Static methods that match your usage in the UI
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    if (!_emailRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Check for at least one letter and one number
    if (!value.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Password must contain at least one letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }

    if (!_nameRegExp.hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }

    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }
    return null;
  }

  static final RegExp _phoneRegExp = RegExp(r'^\+?[\d\s\-()]+$');

  static final RegExp _alphanumericRegExp = RegExp(r'^[a-zA-Z0-9]+$');

  static final RegExp _urlRegExp = RegExp(
    r'^https?://(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  /// Validates habit name
  static String? validateHabitName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Habit name is required';
    }

    if (value.trim().length < 2) {
      return 'Habit name must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return 'Habit name must be less than 50 characters';
    }

    return null;
  }

  /// Validates habit description
  static String? validateHabitDescription(String? value) {
    if (value != null && value.trim().length > 200) {
      return 'Description must be less than 200 characters';
    }
    return null;
  }

  /// Validates email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }

    return null;
  }

  /// Validates password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (value.length > 128) {
      return 'Password must be less than 128 characters';
    }

    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    // Check for at least one digit
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }

    return null;
  }

  /// Validates password confirmation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Validates phone number
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (cleaned.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    if (!_phoneRegExp.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates name (first name, last name, etc.)
  static String? validateName(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Name'} is required';
    }

    if (value.trim().length < 2) {
      return '${fieldName ?? 'Name'} must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return '${fieldName ?? 'Name'} must be less than 50 characters';
    }

    if (!_nameRegExp.hasMatch(value.trim())) {
      return '${fieldName ?? 'Name'} can only contain letters and spaces';
    }

    return null;
  }

  /// Validates URL format
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    if (!_urlRegExp.hasMatch(value.trim())) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates minimum length
  static String? validateMinLength(
    String? value,
    int minLength, {
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (value.trim().length < minLength) {
      return '${fieldName ?? 'This field'} must be at least $minLength characters';
    }

    return null;
  }

  /// Validates maximum length
  static String? validateMaxLength(
    String? value,
    int maxLength, {
    String? fieldName,
  }) {
    if (value != null && value.trim().length > maxLength) {
      return '${fieldName ?? 'This field'} must be less than $maxLength characters';
    }

    return null;
  }

  /// Validates that a string contains only numbers
  static String? validateNumeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return '${fieldName ?? 'This field'} must contain only numbers';
    }

    return null;
  }

  /// Validates that a string contains only alphanumeric characters
  static String? validateAlphanumeric(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (!_alphanumericRegExp.hasMatch(value.trim())) {
      return '${fieldName ?? 'This field'} must contain only letters and numbers';
    }

    return null;
  }

  /// Validates that a number is within a specific range
  static String? validateRange(
    String? value,
    double min,
    double max, {
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }

    if (number < min || number > max) {
      return '${fieldName ?? 'This field'} must be between $min and $max';
    }

    return null;
  }

  /// Validates that a number is positive
  static String? validatePositiveNumber(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return '${fieldName ?? 'This field'} must be a valid number';
    }

    if (number <= 0) {
      return '${fieldName ?? 'This field'} must be a positive number';
    }

    return null;
  }

  /// Validates that a date is not in the past
  static String? validateFutureDate(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return '${fieldName ?? 'Date'} is required';
    }

    if (date.isBefore(DateTime.now())) {
      return '${fieldName ?? 'Date'} cannot be in the past';
    }

    return null;
  }

  /// Validates that a date is not in the future
  static String? validatePastDate(DateTime? date, {String? fieldName}) {
    if (date == null) {
      return '${fieldName ?? 'Date'} is required';
    }

    if (date.isAfter(DateTime.now())) {
      return '${fieldName ?? 'Date'} cannot be in the future';
    }

    return null;
  }

  /// Validates that a date is within a specific range
  static String? validateDateRange(
    DateTime? date,
    DateTime minDate,
    DateTime maxDate, {
    String? fieldName,
  }) {
    if (date == null) {
      return '${fieldName ?? 'Date'} is required';
    }

    if (date.isBefore(minDate) || date.isAfter(maxDate)) {
      return '${fieldName ?? 'Date'} must be between ${minDate.toLocal().toString().split(' ')[0]} and ${maxDate.toLocal().toString().split(' ')[0]}';
    }

    return null;
  }

  /// Validates habit frequency (daily, weekly, monthly)
  static String? validateFrequency(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Frequency is required';
    }

    final validFrequencies = ['daily', 'weekly', 'monthly'];
    if (!validFrequencies.contains(value.toLowerCase())) {
      return 'Please select a valid frequency';
    }

    return null;
  }

  /// Validates reminder time
  static String? validateReminderTime(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    // Basic time format validation (HH:MM)
    if (!RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9]$').hasMatch(value.trim())) {
      return 'Please enter a valid time format (HH:MM)';
    }

    return null;
  }

  /// Validates that a list is not empty
  static String? validateListNotEmpty(
    List<dynamic>? list, {
    String? fieldName,
  }) {
    if (list == null || list.isEmpty) {
      return '${fieldName ?? 'This field'} must have at least one item';
    }

    return null;
  }

  /// Validates that a value is one of the allowed options
  static String? validateOptions(
    String? value,
    List<String> options, {
    String? fieldName,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    if (!options.contains(value)) {
      return '${fieldName ?? 'This field'} must be one of: ${options.join(', ')}';
    }

    return null;
  }

  /// Validates username
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }

    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.trim().length > 20) {
      return 'Username must be less than 20 characters';
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  /// Validates habit target (number of times per frequency)
  static String? validateHabitTarget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Target is required';
    }

    final target = int.tryParse(value.trim());
    if (target == null) {
      return 'Target must be a valid number';
    }

    if (target < 1) {
      return 'Target must be at least 1';
    }

    if (target > 100) {
      return 'Target must be less than 100';
    }

    return null;
  }

  /// Validates habit streak goal
  static String? validateStreakGoal(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional field
    }

    final goal = int.tryParse(value.trim());
    if (goal == null) {
      return 'Streak goal must be a valid number';
    }

    if (goal < 1) {
      return 'Streak goal must be at least 1';
    }

    if (goal > 365) {
      return 'Streak goal must be less than 365 days';
    }

    return null;
  }

  /// Combines multiple validators
  static String? validateMultiple(
    String? value,
    List<String? Function(String?)> validators,
  ) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  /// Custom validator builder
  static String? Function(String?) customValidator({
    required bool Function(String?) condition,
    required String errorMessage,
  }) {
    return (String? value) {
      if (!condition(value)) {
        return errorMessage;
      }
      return null;
    };
  }
}
