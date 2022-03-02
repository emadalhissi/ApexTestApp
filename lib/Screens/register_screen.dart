import 'package:apex_test_app/Helpers/snakbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SnackBarHelper {
  late TextEditingController emailEditingController;
  late TextEditingController passwordEditingController;

  late UserCredential userCredential;

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
                'Register',
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
                  print('pressed');
                  await performRegister();
                },
                child: const Text('Register'),
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
                  const Text('Already a user? '),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login_screen');
                    },
                    child: const Text('Log In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> performRegister() async {
     print('performRegister');
    if (checkData()) {
      print('checkData');
      await register();
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

  Future<void> register() async {
    try {
      userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailEditingController.text.toString(),
        password: passwordEditingController.text.toString(),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(
          context,
          message: 'The password provided is too weak!',
          error: true,
        );
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(
          context,
          message: 'The account already exists for that email!',
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
