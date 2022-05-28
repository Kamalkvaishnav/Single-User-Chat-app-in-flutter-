import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:listview_in_blocpattern/auth_service.dart';
import 'package:listview_in_blocpattern/chatList.dart';
import 'package:listview_in_blocpattern/database_manager.dart';
import 'package:listview_in_blocpattern/userModel.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List Users = [];

  @override
  void initState() {
    fetchuserInfo();
    super.initState();
  }

  fetchuserInfo() async {
    dynamic result = await DatabaseManager().fetchUserList();
    if (result == null) {
      print('Error in retriving UserData');
    } else {
      setState(() {
        Users = result;
      });
      print(Users.length);
      return Users;
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel user =
        UserModel(context.read<User>().email!, context.read<User>().uid);

    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(user.email),
              ElevatedButton(
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.blueGrey)),
                  onPressed: (() {
                    context.read<AuthService>().signOut();
                  }),
                  child: Text('Log out'))
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ListView.builder(
                itemCount: Users.length,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: EdgeInsets.only(top: 16),
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return (user.email == Users[index]['Email'])? Container() : ChatList(
                      email: Users[index]['Email'],
                      imageUrl: 'assets/avatar1.png',
                      date: '10/05',
                      token: Users[index]['Token'],
                      );
                },
              ),
            ],
          ),
        ));
  }
}
