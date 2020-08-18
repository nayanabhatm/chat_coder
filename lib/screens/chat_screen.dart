import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chatcoder/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _firestore=Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  static const String id='ChatScreen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth=FirebaseAuth.instance;
  String messageText;
  TextEditingController messageTextController=TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async{
      final user=await _auth.currentUser();
      try{
        if(user!=null){
          loggedInUser=user;
          print(loggedInUser.email);
        }
      }
      catch(e){
        print(e);
      }

  }

//  void getMessages() async{
//    final messages=await _firestore.collection('messages').getDocuments();
//    for(var message in messages.documents){
//      print(message.data);
//    }
//
//  }

  void messageStream() async{
    await for(var snapshot in _firestore.collection('messages').snapshots()){
      for(var message in snapshot.documents){
        print(message.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
                messageStream();
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _firestore.collection('messages').add({
                           'text':messageText,
                           'sender':loggedInUser.email,
                      });
                      messageTextController.clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('messages').snapshots(),
      builder: (context, snapshot){
        List<MessageBubble> messageBubbles=[];
        if(!snapshot.hasData){
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlueAccent,
            ),
          );
        }
        final messages=snapshot.data.documents.reversed; //list gets reversed.. to get the new messages at teh bottom of the list.
        for(var message in messages){
          final messageText=message.data['text'];
          final messageSender=message.data['sender'];
          final currentUser=loggedInUser.email;
          final messageWidget=MessageBubble(
            text: messageText,
            sender: messageSender,
            isMe:currentUser == messageSender,
          );
          messageBubbles.add(messageWidget);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;

  Color bubbleColor;
  CrossAxisAlignment crossAxisAlignmentType;
  double topRight,topLeft;
  MessageBubble({this.text,this.sender,this.isMe});

  @override
  Widget build(BuildContext context) {
    if(isMe){
      bubbleColor=Colors.white;
      topRight=30.0;
      topLeft=0.0;
      crossAxisAlignmentType=CrossAxisAlignment.start;
    }
    else{
      bubbleColor=Colors.lightBlueAccent;
      topRight=0.0;
      topLeft=30.0;
      crossAxisAlignmentType=CrossAxisAlignment.end;
    }
    return Padding(
      padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: crossAxisAlignmentType,
          children: <Widget>[
            Text(
                '$sender',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
            Material(
              elevation: 5.0,
              borderRadius: BorderRadius.only(topRight:Radius.circular(topRight),topLeft: Radius.circular(topLeft),bottomLeft: Radius.circular(30.0), bottomRight: Radius.circular(30.0)),
              color: bubbleColor,
              child:Padding(
                padding: EdgeInsets.all(10.0),
                child: Text(
                    '$text',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }
}

