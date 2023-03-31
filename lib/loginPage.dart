import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './home.dart';
FirebaseAuth auth = FirebaseAuth.instance;


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

//sign out function:- use in the log out button of your app
// _signOut() async {
//   await FirebaseAuth.instance.signOut();
//   await GoogleSignIn().signOut();
// }
TextEditingController email = TextEditingController();
TextEditingController password = TextEditingController();

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          TextFormField(controller: email,
            decoration: InputDecoration(hintText: 'email'),
          ),
          SizedBox(
            height: 20,
          ),
          TextFormField(controller: password,
            decoration: InputDecoration(hintText: 'password'),
          ),
          SizedBox(
            height: 60,
          ),
          TextButton(
              onPressed: () {
                auth
                    .createUserWithEmailAndPassword(
                        email: email.text, password: password.text)
                    .then((value) async {

                  await firestore
                      .collection('users')
                      .doc(auth.currentUser!.uid)
                      .set({
                    'name':auth.currentUser!.photoURL,
                    'email':auth.currentUser!.email,
                    'status':'Not Available'

                  });
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx)=>Home1()));
                  print('success');
                });
              },
              child: Text('Login'))
        ],
      ),
    ));
  }
}
