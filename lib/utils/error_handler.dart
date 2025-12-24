import 'package:flutter/material.dart';

class ErrorHandler {
  // Log error with context
  static void logError(String context, dynamic error,
      [StackTrace? stackTrace]) {
    print('ERROR [$context]: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }

  // Get user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    String errorText = error.toString().toLowerCase();

    // Firebase errors
    if (errorText.contains('network') || errorText.contains('connection')) {
      return 'Please check your internet connection and try again.';
    }

    if (errorText.contains('permission') ||
        errorText.contains('unauthorized')) {
      return 'You don\'t have permission to perform this action.';
    }

    if (errorText.contains('storage') && errorText.contains('upload')) {
      return 'Failed to upload file. Please check your connection and try again.';
    }

    // PDF errors
    if (errorText.contains('pdf') && errorText.contains('text')) {
      return 'Could not read text from the PDF file. Please ensure it contains readable text.';
    }

    if (errorText.contains('pdf') && errorText.contains('format')) {
      return 'The file format is not supported. Please use a valid PDF file.';
    }

    if (errorText.contains('pdf') && errorText.contains('corrupted')) {
      return 'The PDF file appears to be corrupted. Please try with a different file.';
    }

    // File errors
    if (errorText.contains('file') && errorText.contains('large')) {
      return 'The file is too large. Please use a file smaller than 50MB.';
    }

    if (errorText.contains('file') && errorText.contains('empty')) {
      return 'The file is empty or could not be read.';
    }

    if (errorText.contains('file') && errorText.contains('exist')) {
      return 'The selected file no longer exists. Please select a different file.';
    }

    // AI errors
    if (errorText.contains('ai') ||
        errorText.contains('gemini') ||
        errorText.contains('questions')) {
      return 'Failed to generate questions. Please try again in a moment.';
    }

    if (errorText.contains('api') && errorText.contains('key')) {
      return 'Service configuration error. Please contact support.';
    }

    // Authentication errors
    if (errorText.contains('auth') || errorText.contains('login')) {
      return 'Authentication failed. Please log in again.';
    }

    // Generic errors
    if (errorText.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorText.contains('server')) {
      return 'Server error. Please try again later.';
    }

    // Default message
    return 'An unexpected error occurred. Please try again.';
  }

  // Show error dialog
  static void showErrorDialog(
      BuildContext context, String title, dynamic error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(getUserFriendlyMessage(error)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(getUserFriendlyMessage(error)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Handle and display error appropriately
  static void handleError(
    BuildContext context,
    String context_name,
    dynamic error, {
    bool showDialog = false,
    StackTrace? stackTrace,
  }) {
    logError(context_name, error, stackTrace);

    if (showDialog) {
      showErrorDialog(context, 'Error', error);
    } else {
      showErrorSnackBar(context, error);
    }
  }
}

// Error types for better categorization
enum ErrorType {
  network,
  authentication,
  fileProcessing,
  aiService,
  storage,
  validation,
  unknown,
}

class AppError extends Error {
  final String message;
  final ErrorType type;
  final dynamic originalError;

  AppError({
    required this.message,
    required this.type,
    this.originalError,
  });

  factory AppError.network(String message, [dynamic originalError]) {
    return AppError(
      message: message,
      type: ErrorType.network,
      originalError: originalError,
    );
  }

  factory AppError.authentication(String message, [dynamic originalError]) {
    return AppError(
      message: message,
      type: ErrorType.authentication,
      originalError: originalError,
    );
  }

  factory AppError.fileProcessing(String message, [dynamic originalError]) {
    return AppError(
      message: message,
      type: ErrorType.fileProcessing,
      originalError: originalError,
    );
  }

  factory AppError.aiService(String message, [dynamic originalError]) {
    return AppError(
      message: message,
      type: ErrorType.aiService,
      originalError: originalError,
    );
  }

  factory AppError.storage(String message, [dynamic originalError]) {
    return AppError(
      message: message,
      type: ErrorType.storage,
      originalError: originalError,
    );
  }

  factory AppError.validation(String message, [dynamic originalError]) {
    return AppError(
      message: message,
      type: ErrorType.validation,
      originalError: originalError,
    );
  }

  @override
  String toString() => message;
}
