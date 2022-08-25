import 'package:flutter/material.dart';

import 'package:herewego/services/auth_service.dart';
import 'package:herewego/ui/provider.dart';

import 'sign_in_page.dart';

class SignUpProvider extends ChangeNotifier {
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLoading = false;

  void doSignUp(BuildContext context) async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isNotEmpty &&
        email.contains("@") &&
        password.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty) {
      isLoading = true;
      notifyListeners();

      await AuthService.signUpUser(
        "$firstName $lastName",
        email,
        password,
      ).then((value) {
        isLoading = false;
        notifyListeners();

        if (value != null) {
          Navigator.pushReplacementNamed(context, SignInPage.id);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("User not created!"),
            ),
          );
        }
      });
    }
  }
}

class SignUpPage extends StatelessWidget {
  static const id = "/sign_up_page";

  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      model: SignUpProvider(),
      child: const _View(),
    );
  }
}

class _View extends StatelessWidget {
  const _View({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SignUpProvider>()!;
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
                        text: "First Name",
                        controller: provider._firstNameController,
                      ),
                      const SizedBox(height: 10),
                      _CustomTextField(
                        text: "Last Name",
                        controller: provider._lastNameController,
                      ),
                      const SizedBox(height: 10),
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
                            borderRadius: BorderRadius.circular(13)),
                        onPressed: () => provider.doSignUp(context),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const Text("Already have an account?  "),
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                context,
                                SignInPage.id,
                              );
                            },
                            child: const Text("Sign In"),
                          )
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final IconData? icon;
  final String text;
  final TextEditingController controller;

  const _CustomTextField({
    Key? key,
    this.icon,
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
        prefixIcon: icon != null ? Icon(icon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
        ),
      ),
    );
  }
}
