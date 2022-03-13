import 'package:herewego/services/auth_service.dart';
import 'package:herewego/services/hive_service.dart';
import 'package:herewego/services/log_service.dart';

import 'home_page.dart';
import 'package:flutter/material.dart';

import 'sign_up_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  static const id = "/sign_in_page";

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  void doSignIn() async {
    String email = _emailController.text.trim().toString();
    String password = _passwordController.text.trim().toString();

    if (email.isNotEmpty && email.contains("@") && password.isNotEmpty) {
      setState(() {
        isLoading = true;
      });

      await AuthService.signInUser(email, password).then((value) {
        setState(() {
          isLoading = false;
        });

        if (value != null) {
          String id = value.uid;
          HiveDB.storeUserId(id);

          Log.d(HiveDB.loadUserId());
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
                        onPressed: doSignIn,
                        child: const Text("Sign In"),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushReplacementNamed(
                                  context, SignUpPage.id);
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

  TextFormField textField(
      {required IconData icon,
      required String text,
      required TextEditingController controller}) {
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
