// ignore_for_file: prefer_const_constructors

import 'package:ekc_project/Widgets/myAppBar.dart';
import 'package:faker/faker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'usersPage.dart';
import 'mainPage.dart';

class GoogleLoginApp extends StatefulWidget {
  const GoogleLoginApp({Key? key}) : super(key: key);

  @override
  _GoogleLoginAppState createState() => _GoogleLoginAppState();
}

class _GoogleLoginAppState extends State<GoogleLoginApp> {
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  @override
  Widget build(BuildContext context) {
    GoogleSignInAccount? user = _googleSignIn.currentUser;

    return MaterialApp(
      home: Scaffold(
        appBar: myAppBar('Auth: ' +
        (user == null
        ? 'Please Log in'
            : user.displayName ?? 'user.displayName is Null')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Random Sign with google
              ElevatedButton(
                  child: Text('Sign In with google'),
                  onPressed: () async {
                      final GoogleSignInAccount? googleSignInAccount =
                      await _googleSignIn.signIn();

                      if (googleSignInAccount != null) {
                        final GoogleSignInAuthentication googleSignInAuthentication =
                        await googleSignInAccount.authentication;

                        final AuthCredential credential = GoogleAuthProvider
                            .credential(
                          accessToken: googleSignInAuthentication.accessToken,
                          idToken: googleSignInAuthentication.idToken,
                        );

                        final FirebaseAuth auth = FirebaseAuth.instance;
                        final UserCredential userCredential =
                        await auth.signInWithCredential(credential);


                        final User? fireStoreUser = userCredential.user;
                        final myUid = fireStoreUser?.uid;

                        print('loginPAge user $fireStoreUser');
                        print('loginPAge myUid $myUid');

                        setState(() {
                          FirebaseChatCore.instance
                              .createUserInFirestore(
                            types.User(
                              firstName: fireStoreUser?.displayName,
                              id: fireStoreUser?.uid ?? UniqueKey().toString(),
                              // UID from Firebase Authentication
                              imageUrl: 'https://i.pravatar.cc/300',
                              lastName: '${fireStoreUser?.email}'.toLowerCase(),
                            ),
                          )
                              .whenComplete(() =>
                              print(
                                  'firebaseDatabase_basedFlyer Completed \n(FirebaseChatCore.instance.createUserInFirestore)'))
                              .onError((error, stackTrace) =>
                              print(
                                  'firebaseDatabase_basedFlyer FAILED: $error \n-|- $stackTrace \n(FirebaseChatCore.instance.createUserInFirestore)'));
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    MainPage(
                                      googleSign_user: _googleSignIn
                                          .currentUser,
                                    )),
                            // MaterialPageRoute(builder: (context) => MainPage(user: _user,)),
                          );
                        });
                      }
                  }),


              // Random Sign up
     /*         ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(dark) ,
                ),
                  child: Text('New Random account'),
                  onPressed: () async {
                    final faker = Faker();
                    String _name = faker.person.firstName();

                    setState(() async {
                      final _user =
                      await FirebaseAuth.instance.createUserWithEmailAndPassword(
                        email: '$_name@faker.com',
                        password: '${_name}1234',
                      );
                      await FirebaseChatCore.instance
                          .createUserInFirestore(
                        types.User(
                          firstName: _name,
                          id: _user.user?.uid ?? UniqueKey().toString(),
                          // UID from Firebase Authentication
                          imageUrl: 'https://i.pravatar.cc/300',
                          lastName: '$_name@faker.com',

                        ),
                      )
                          .whenComplete(() => print(
                          'firebaseDatabase_basedFlyer Completed \n(FirebaseChatCore.instance.createUserInFirestore)'))
                          .onError((error, stackTrace) => print(
                          'firebaseDatabase_basedFlyer FAILED: $error \n-|- $stackTrace \n(FirebaseChatCore.instance.createUserInFirestore)'));



                      Navigator.pushReplacement(
                        context,
                          Provider(
                          create: (_) => Person(name: "Yohan", age: 25),
                      child: MyApp(),
    */
              //
              /*                    MaterialPageRoute(
                            builder: (context) => AllUsersPage(
                              // classic_currentUser: _user,
                            )),*//*
                        // MaterialPageRoute(builder: (context) => MainPage(user: _user,)),
                      );
                    });
                  }),*/

              ElevatedButton(child: Text('Sign Out'),
                  onPressed: () async {
                    await _googleSignIn.signOut();
                    setState(() {});
                  }
              ),
            ],
          ), // Column
        ), // Center
      ),
    );
  }
}
