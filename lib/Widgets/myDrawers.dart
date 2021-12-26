import 'package:ekc_project/Pages/flyerChat.dart';
import 'package:ekc_project/Services/myFirebaseFlyer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ekc_project/Widgets/myAlertDialog.dart';
import 'package:ekc_project/Widgets/myAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'dart:convert';
import 'package:ekc_project/Widgets/myDrawers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:uuid/uuid.dart';

import '../myUtil.dart';



Widget sampleDrawer(context, {onPressed_newProject,  projectNum}) {
  return
    Drawer(
      child: Column(
    children: [
      Container(
        padding: const EdgeInsets.only(top: 8.0),
        height: MediaQuery.of(context).size.height * 0.13,
        child: const DrawerHeader(child: Text("Projects")),
      ),
      Expanded(
        child: ListView.builder(
          itemCount: projectNum.length,
          itemBuilder: (context, i) {
            return ListTile(
              title: Text('Project ${projectNum[i]}'),
              /*                leading: CachedNetworkImage(
                        imageUrl: "http://aarongorka.com/eks-orig.jpg",
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) {
                          // print(error);
                          return Icon(Icons.error);
                        },
                      )*/
              // >> << \\
              /*             Image(
                            width: 50,
                              image: AssetImage('Assets/eks-thumb.jpg'))
                              */
            );
          },
        ),
      ),
      TextButton(onPressed: onPressed_newProject, child: const Text('Create New Project')),
    ],
  ));
}

Widget projectsDrawer(context, currentUser) {
  return
    Drawer(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 8.0),
              height: MediaQuery.of(context).size.height * 0.13,
              child: const DrawerHeader(child: Text("Projects")),
            ),
            StreamBuilder<List<types.Room>>(
              stream: FirebaseChatCore.instance.rooms(),
              initialData: const [],
              builder: (context, snapshot) {
                // print(snapshot.data);
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, i) {
                      if (snapshot.data![i].type.toString() == 'RoomType.group') {
                        return ListTile(
                          onTap: () {
                            print(snapshot.data?[i].id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FireBaseChatPage(
                                    room: snapshot.data![i],
                                    currentUser: currentUser,
                                    // user: _user,
                                  )),
                            );
                          },
                          title: Text(
                              'Project ${i + 1}: "${snapshot.data![i].name}"'),
                          /*                leading: CachedNetworkImage(
                        imageUrl: "http://aarongorka.com/eks-orig.jpg",
                        placeholder: (context, url) =>
                            CircularProgressIndicator(),
                        errorWidget: (context, url, error) {
                          // print(error);
                          return Icon(Icons.error);
                        },
                      )*/
                          // >> << \\
                          /*             Image(
                            width: 50,
                              image: AssetImage('Assets/eks-thumb.jpg'))
                              */
                        );
                      }
                      return Container();
                    },
                  ),
                );
                // ...
              },
            ),
            TextButton(
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return MyAlertDialog(
                          title: 'New Project Name',
                          onPressed: () {},
                          projectNameController: projectNameController,
                          actions: [
                            Transform.translate(
                              offset: const Offset(40, 0),
                              child: Row(
                                children: [
                                  TextButton(
                                    child: Text('Dismiss'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  Container(
                                    height: 60,
                                    width: 180,
                                    child: TextButton(
                                      child: Text('Create'),
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await createGroupRoom(context,
                                            projectNameController.text, currentUser)
                                            .whenComplete(
                                                () => print('New Project Added!'))
                                            .onError((error, stackTrace) => print(
                                            'New Project Error: $error // $stackTrace'));
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      });
                },
                child: const Text('Create New Project')),
          ],
        ));
}