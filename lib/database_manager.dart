import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class DatabaseManager {
  final CollectionReference userList =
      FirebaseFirestore.instance.collection('UserInfo');
  final CollectionReference chats =
      FirebaseFirestore.instance.collection('Chats');

  Future<void> createuser(String email, String uId, String token) async {
    return await userList.doc(uId).set({
      'Email': email,
      'uID': uId,
      'Token': token,
    });
  }

  Future<void> createMessage(
      int timestamp, String uId, String receiverToken, String message) async {
    int tdata = DateTime.now().millisecondsSinceEpoch;
    return await chats.doc('${timestamp}').set({
      'timestamp': tdata,
      'uID': uId,
      'receiver_token': receiverToken,
      'Message': message,
    });
  }

  Future fetchUserList() async {
    List profileUserList = [];
    try {
      await userList.get().then((value) {
        value.docs.forEach((element) {
          profileUserList.add(element.data());
        });
      });
      return profileUserList;
    } catch (e) {
      print(e.toString());
    }
  }

  Future fetchMessages() async {
    List messageList = [];
    try {
      await chats.orderBy('timestamp').get().then((value) {
        value.docs.forEach((element) {
          messageList.add(element.data());
        });
      });
      return messageList;
    } catch (e) {
      print(e.toString());
    }
  }

  //
  Future<http.Response> sendMessage(
      String token, String title, String body) async {
    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'key=AAAAfIAwgFg:APA91bHs-PUH5lXteAK03p-srZHZWSuLOVVouhJXGv1Qv4NE-ySaEufvoyX2uhPCbM9rmr2mQVHQJ0XEYQ3CswwtCw0Jw-w81RVsBeoWUJ838t5fXke3F0P-j_NLYm4m8du9-ZOypYFb'
      },
      body: jsonEncode(<String, dynamic>{
        'to': token,
        "content_available": true,
        "notification": {
          "title": title,
          "body": body,
          "click_action": "fcm.ACTION.HELLO"
        },
        "data": {"extra": "Juice"}
      }),
    );

    return response;
  }
}
