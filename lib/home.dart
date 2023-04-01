import 'package:basechatapp/signup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'chatroom.dart';

class Home1 extends StatefulWidget {
  const Home1({Key? key}) : super(key: key);

  @override
  State<Home1> createState() => _Home1State();
}
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;
Map<String,dynamic>userMap={};
TextEditingController search = TextEditingController();
bool isLoading=false;
class _Home1State extends State<Home1> {
  void onSearch()async{
    setState(() {
      isLoading=true;
    });
    await firestore
        .collection('users').where('email',isEqualTo: search.text).get().then((value) {
          print('item foudnd');
         setState(() {
           userMap=value.docs[0].data();
           isLoading=false;
         });

    });
  }
  String chatRoomId(String user1, String user2){
    if(user1[0].toLowerCase().codeUnits[0]>user2[0].toLowerCase().codeUnits[0]){
      return '$user1$user2';
    }
    else{
      return '$user2$user1';
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                onSearch();
              },
              icon: Icon(
                Icons.search,
                color: Colors.red,
              ))
        ],
        backgroundColor: Colors.white,
        title: TextFormField(
          controller: search,
          decoration: InputDecoration(hintText: 'Enter Your Keyword'),
        ),
      ),body: ListTile(title: Text(userMap['email'].toString()),onTap: (){

        String roomId=chatRoomId(auth.currentUser!.displayName.toString(),userMap['name']);
        print(roomId);
        Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext a)=>ChatRoom(userMap: userMap, chatRoomId: roomId,)));

    },),
    );
  }
}
