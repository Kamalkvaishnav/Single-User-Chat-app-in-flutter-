import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:listview_in_blocpattern/TokenForMessageBox.dart';
import 'package:listview_in_blocpattern/database_manager.dart';

class MessageBox extends StatefulWidget {
  @override
  State<MessageBox> createState() => _MessageBoxState();
}

final TextEditingController msgController = TextEditingController();

class _MessageBoxState extends State<MessageBox> {
  List Messages = [];

  @override
  void initState() {
    fetchMessages();
    super.initState();
  }

  fetchMessages() async {
    dynamic result = await DatabaseManager().fetchMessages();
    if (result == null) {
      print('Error in retriving UserData');
    } else {
      setState(() {
        Messages = result;
      });
      print(Messages.length);
      return Messages;
    }
  }

  @override
  Widget build(BuildContext context) {
    final SenderUID = context.read<User>().uid;
    final arg =
        ModalRoute.of(context)!.settings.arguments as TokenForMessageBox;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 112, 121, 181),
        title: const ListTile(
          title: Text("Receiver"),
          leading:
              CircleAvatar(backgroundImage: AssetImage('assets/avatar1.png')),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              itemCount: Messages.length,
              shrinkWrap: true,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Container(
                  padding:
                     const EdgeInsets.only(left: 14, right: 14, top: 10, bottom: 10),
                  child: Align(
                    alignment: (Messages[index]['receiver_token'] != arg.token
                        ? Alignment.topLeft
                        : Alignment.topRight),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: (Messages[index]['receiver_token'] != arg.token
                            ? Colors.grey.shade200
                            : Colors.blue[200]),
                      ),
                      padding: EdgeInsets.all(16),
                      child: Text(
                        Messages.length > 0
                            ? Messages[index]['Message']
                            : 'No messages yet',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                );
              },
            ),
            Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, bottom: 0, top: 10),
                    height: 60,
                    width: double.infinity,
                    color: Colors.white,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: msgController,
                            decoration: const InputDecoration(
                                floatingLabelAlignment:
                                    FloatingLabelAlignment.center,
                                hintText: "Write message...",
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none),
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        FloatingActionButton(
                          onPressed: () {
                            int timedata =
                                DateTime.now().millisecondsSinceEpoch;
                            DatabaseManager().createMessage(timedata, SenderUID,
                                arg.token, msgController.text.trim());
                            DatabaseManager().sendMessage(
                                arg.token,
                                'You got new Message',
                                msgController.text.trim());
                            msgController.clear();
                          },
                          backgroundColor: Colors.blue,
                          elevation: 0,
                          child: const Icon(
                            Icons.send,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
