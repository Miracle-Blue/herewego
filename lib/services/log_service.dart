import 'package:logger/logger.dart';
import 'auth_service.dart';

extension Logging on Object {
  void d() {
    if (AuthService.isTester) Logger(printer: PrettyPrinter()).d(this);
  }

  void i() {
    if (AuthService.isTester) Logger(printer: PrettyPrinter()).i(this);
  }

  void e() {
    if (AuthService.isTester) Logger(printer: PrettyPrinter()).e(this);
  }

  void w() {
    if (AuthService.isTester) Logger(printer: PrettyPrinter()).w(this);
  }

  void wtf() {
    if (AuthService.isTester) Logger(printer: PrettyPrinter()).wtf(this);
  }

  void v() {
    if (AuthService.isTester) Logger(printer: PrettyPrinter()).v(this);
  }
}
