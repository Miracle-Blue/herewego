import 'package:logger/logger.dart';
import 'auth_service.dart';

class Log {
  static final Logger _logger = Logger(printer: PrettyPrinter());

  static void d(String message) {
    if (AuthService.isTester) _logger.d(message);
  }

  static void i(String message) {
    if (AuthService.isTester) _logger.i(message);
  }

  static void w(String message) {
    if (AuthService.isTester) _logger.w(message);
  }

  static void e(String message) {
    if (AuthService.isTester) _logger.e(message);
  }
}