import 'package:herewego/services/auth_service.dart';
import 'package:herewego/services/hive_service.dart';
import 'package:herewego/services/log_service.dart';
import 'package:herewego/ui/provider.dart';

import 'home_page.dart';
import 'package:flutter/material.dart';

import 'sign_up_page.dart';

class SignInProvider extends ChangeNotifier {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;

  void doSignIn(BuildContext context) async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    /// ! for crashing app
    // FirebaseCrashlytics.instance.crash();

    if (email.isNotEmpty && email.contains("@") && password.isNotEmpty) {
      isLoading = true;
      notifyListeners();

      await AuthService.signInUser(email, password).then((value) {
        isLoading = false;
        notifyListeners();

        if (value != null) {
          String id = value.uid;
          HiveDB.storeUserId(id);

          HiveDB.loadUserId().d;
          Navigator.pushReplacementNamed(context, HomePage.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Wrong password or email."),
            ),
          );
        }
      });
    }
  }
}

class SignInPage extends StatelessWidget {
  static const id = "/sign_in_page";

  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      model: SignInProvider(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignInProvider>()!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator.adaptive(),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CustomTextField(
                        icon: Icons.email_rounded,
                        text: "Email",
                        controller: provider._emailController,
                      ),
                      const SizedBox(height: 10),
                      _CustomTextField(
                        icon: Icons.lock,
                        text: "Password",
                        controller: provider._passwordController,
                      ),
                      const SizedBox(height: 20),
                      MaterialButton(
                        color: Colors.red,
                        minWidth: MediaQuery.of(context).size.width,
                        height: 55,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        onPressed: () => provider.doSignIn(context),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text("Don't have an account?  "),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                SignUpPage.id,
                              );
                            },
                            child: const Text("Sign Up"),
                          )
                        ],
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final IconData icon;
  final String text;
  final TextEditingController controller;

  const _CustomTextField({
    Key? key,
    required this.icon,
    required this.text,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: text,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }
}
