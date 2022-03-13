import 'package:herewego/services/auth_service.dart';

import 'sign_in_page.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  static const id = "/sign_up_page";

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  void doSignUp() async {
    String firstName = _firstNameController.text.trim().toString();
    String lastName = _lastNameController.text.trim().toString();
    String email = _emailController.text.trim().toString();
    String password = _passwordController.text.trim().toString();

    if (email.isNotEmpty &&
        email.contains("@") &&
        password.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      await AuthService.signUpUser("$firstName $lastName", email, password)
          .then((value) {
        setState(() {
          isLoading = false;
        });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: isLoading
                ? const Center(
              child: CircularProgressIndicator.adaptive(),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                textField(
                    text: "First Name", controller: _firstNameController),
                const SizedBox(height: 10),
                textField(
                    text: "Last Name", controller: _lastNameController),
                const SizedBox(height: 10),
                textField(
                    icon: Icons.email_rounded,
                    text: "Email",
                    controller: _emailController),
                const SizedBox(height: 10),
                textField(
                    icon: Icons.lock,
                    text: "Password",
                    controller: _passwordController),
                const SizedBox(height: 20),
                MaterialButton(
                  color: Colors.amber,
                  minWidth: MediaQuery.of(context).size.width,
                  height: 55,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  onPressed: doSignUp,
                  child: const Text("Sign In"),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, SignInPage.id);
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

  TextFormField textField(
      {IconData? icon,
        required String text,
        required TextEditingController controller}) {
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
