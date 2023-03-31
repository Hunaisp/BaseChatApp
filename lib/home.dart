import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Home1 extends StatefulWidget {
  const Home1({Key? key}) : super(key: key);

  @override
  State<Home1> createState() => _Home1State();
}
FirebaseFirestore firestore = FirebaseFirestore.instance;
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
      ),body: ListTile(title: Text(userMap['email'].toString()),),
    );
  }
}
