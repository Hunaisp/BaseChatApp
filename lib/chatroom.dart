
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatRoom extends StatefulWidget {
  final String chatRoomId;
  final Map<String, dynamic> userMap;

  const ChatRoom({Key? key, required this.userMap, required this.chatRoomId})
      : super(key: key);

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

TextEditingController message = TextEditingController();
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseAuth auth = FirebaseAuth.instance;

class _ChatRoomState extends State<ChatRoom> {
  void onSendMessage() async {
    if (message.text.isNotEmpty) {
      String uid = auth.currentUser!.uid;
      Map<String, dynamic> messages = {
        "sendby": uid,
        "message": message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      message.clear();
      await firestore
          .collection('chatroom')
          .doc(widget.chatRoomId)
          .collection('chats')
          .add(messages);
    } else {
      print("Enter Some Text");
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(     appBar: AppBar(
      title: StreamBuilder<DocumentSnapshot>(
        stream:
        firestore.collection("users").doc(widget.userMap['uid']).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            return Column(
              children: [
                Text(widget.userMap['name']),
                Text(
                  snapshot.data!['status'],
                  style: TextStyle(fontSize: 14),
                ),
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    ),
      bottomSheet: Container(height: 150, child: Row(children: [
      Container(height: 60,width: 150,
        child: TextFormField(controller: message,
          decoration: InputDecoration(hintText: 'Enter Your Message'),),),
      SizedBox(width: 45,),
      TextButton(onPressed: (){
        onSendMessage();
      }, child:Text('Send'))
    ],),),
      // appBar: AppBar(
      //   title: Text(widget.userMap['name']),
      // ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: size.height / 1.25,
              width: size.width,
              child: StreamBuilder(
                stream: firestore
                    .collection('chatroom')
                    .doc(widget.chatRoomId)
                    .collection('chats')
                    .orderBy('time')
                    .snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading");
                  }

                  List<QueryDocumentSnapshot> chatDocs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: chatDocs.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                      chatDocs[index].data() as Map<String, dynamic>;
                      String message = data['message'];
                      String senderId = data['sendby'];

                      // Determine if the message was sent by the current user
                      bool isMe = senderId == auth.currentUser!.uid;

                      return ListTile(
                        title: Text(message),
                        subtitle: Text(isMe ? 'You' : widget.userMap['name']),
                        trailing: isMe ? Icon(Icons.check) : null,
                      );
                    },
                  );
                },
              )

            ),
            Container(
              height: size.height / 10,
              width: size.width,
              alignment: Alignment.center,
              child: Container(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        icon: Icon(Icons.send), onPressed: onSendMessage),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
  Widget messages(Size size, Map<String, dynamic> map, BuildContext context) {
    return map['type'] == "text"
        ? Container(
      width: size.width,
      alignment: map['sendby'] == auth.currentUser!.displayName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.blue,
        ),
        child: Text(
          map['message'],
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    )
        : Container(
      height: size.height / 2.5,
      width: size.width,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      alignment: map['sendby'] == auth.currentUser!.displayName
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        height: size.height / 2.5,
        width: size.width / 2,
        decoration: BoxDecoration(border: Border.all()),
        alignment: map['message'] != "" ? null : Alignment.center,
        child: map['message'] != ""
            ? Text(
          map['message'],
        )
            : CircularProgressIndicator(),
      ),
    );
  }
}

