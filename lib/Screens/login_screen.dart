import 'package:apex_test_app/Helpers/snakbar.dart';
import 'package:apex_test_app/Screens/map_page.dart';
import 'package:apex_test_app/Shared%20Preferences/shared_preferences_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SnackBarHelper {
  late UserCredential userCredential;
  User? user = FirebaseAuth.instance.currentUser;
  late TextEditingController emailEditingController;
  late TextEditingController passwordEditingController;

  @override
  void initState() {
    super.initState();

    emailEditingController = TextEditingController();
    passwordEditingController = TextEditingController();
  }

  @override
  void dispose() {
    emailEditingController.dispose();
    passwordEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 25, right: 25, left: 25),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailEditingController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordEditingController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25)),
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () async {
                  await performLogin();
                },
                child: const Text('LOGIN'),
                style: ElevatedButton.styleFrom(
                  primary: const Color(0xff222222),
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? '),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, '/register_screen');
                    },
                    child: const Text('Create Account'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> performLogin() async {
    if (checkData()) {
      await login();
    }
  }

  bool checkData() {
    if (emailEditingController.text.isEmpty) {
      showSnackBar(
        context,
        message: 'Please enter email!',
        error: true,
      );
      return false;
    } else if (passwordEditingController.text.isEmpty) {
      showSnackBar(
        context,
        message: 'Please enter password!',
        error: true,
      );
      return false;
    }

    return true;
  }

  Future<void> login() async {
    try {
      userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailEditingController.text.toString(),
        password: passwordEditingController.text.toString(),
      );
      print('emailVerified? ' + '${userCredential.user!.emailVerified}');
      if (userCredential.user!.emailVerified == false) {
        showSnackBar(
          context,
          message: 'Please verify your email!',
          error: true,
        );
        await user!.sendEmailVerification();
      } else if (userCredential.user!.emailVerified == true) {
        showSnackBar(
          context,
          message: 'Logged in successfully!',
        );
        print('userCredential => ${userCredential.user!.uid}');
        SharedPreferencesController().saveUId(userName: userCredential.user!.uid);
        print('userCredential from Shared => ${SharedPreferencesController().getUId}');
        SharedPreferencesController().saveLoggedIn();
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const MapPage(),
            ));
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showSnackBar(
          context,
          message: 'User not found!',
          error: true,
        );
      } else if (e.code == 'wrong-password') {
        showSnackBar(
          context,
          message: 'Wrong password!',
          error: true,
        );
      }
    } catch (e) {
      showSnackBar(
        context,
        message: 'Something went wrong, please try again!',
        error: true,
      );
      print(e);
    }
  }
}
