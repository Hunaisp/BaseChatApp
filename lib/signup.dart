import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './home.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

//sign out function:- use in the log out button of your app
// _signOut() async {
//   await FirebaseAuth.instance.signOut();
//   await GoogleSignIn().signOut();
// }
TextEditingController email = TextEditingController();
TextEditingController password = TextEditingController();
TextEditingController name = TextEditingController();

class _SignupState extends State<Signup> {
  Future<User?> createAccount(
      String name, String email, String password) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    try {
      UserCredential userCrendetial = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      print("Account created Succesfull");
//create a username like this
      userCrendetial.user!.updateDisplayName(name);

      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "name": name,
        "email": email,
        "status": "Unavalible",
        "uid": _auth.currentUser!.uid,
      });

      return userCrendetial.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          TextFormField(
            controller: email,
            decoration: InputDecoration(hintText: 'email'),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: password,
            decoration: InputDecoration(hintText: 'password'),
          ),
          SizedBox(
            height: 60,
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(
            controller: name,
            decoration: InputDecoration(hintText: 'name'),
          ),
          TextButton(
              onPressed: () {
                if (name.text.isNotEmpty &&
                    email.text.isNotEmpty &&
                    password.text.isNotEmpty) {
                  setState(() {
                    isLoading = true;
                  });

                  createAccount(name.text, email.text, password.text)
                      .then((user) {
                    if (user != null) {
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.push(
                          context, MaterialPageRoute(builder: (_) => Home1()));
                      print("Account Created Sucessfull");
                    } else {
                      print("Login Failed");
                      setState(() {
                        isLoading = false;
                      });
                    }
                  });
                } else {
                  print("Please enter Fields");
                }
              },
              child: Text('Login'))
        ],
      ),
    ));
  }
}
