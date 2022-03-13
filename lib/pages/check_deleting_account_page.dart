import 'package:flutter/material.dart';
import 'package:herewego/services/auth_service.dart';

class CheckAccountPage extends StatefulWidget {
  const CheckAccountPage({Key? key}) : super(key: key);

  static const id = "check_deleting_account_page";

  @override
  _CheckAccountPageState createState() => _CheckAccountPageState();
}

class _CheckAccountPageState extends State<CheckAccountPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void deleteAccount() async {
    String email = _emailController.text.trim().toString();
    String password = _passwordController.text.trim().toString();

    if (email.isNotEmpty && email.contains("@") && password.isNotEmpty) {
      await AuthService.deleteUser(context, email, password);
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
            child: Column(
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
                  color: Colors.red,
                  minWidth: MediaQuery.of(context).size.width,
                  height: 55,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13)),
                  onPressed: deleteAccount,
                  child: const Text("Delete"),
                ),
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
