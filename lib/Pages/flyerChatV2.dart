import 'dart:async';
import 'dart:io';
import 'package:ekc_project/Pages/mainPage.dart';
import 'package:ekc_project/Pages/roomsPage.dart';
import 'package:ekc_project/Services/myFirebaseFlyer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart' as intl;

import 'package:ekc_project/Widgets/addUserDialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ekc_project/Pages/flyerChat.dart';
import 'package:ekc_project/Widgets/addPtDialog.dart';
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
import 'package:ekc_project/Widgets/myAppBar.dart';
import 'package:ekc_project/Widgets/myDrawers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart' as lol;
import 'package:flutter_firebase_chat_core/flutter_firebase_chat_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

import '../Widgets/cardPost.dart';
import '../Widgets/snackbar.dart';
import '../myUtil.dart';
import '../theme/colors.dart';
import '../theme/constants.dart';
import 'A_loginPage.dart';
import 'flyerDm.dart';
import 'usersPage.dart';
import 'package:bubble/bubble.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlyerChatV2 extends StatefulWidget {
/*  const FireBaseChatPage({
    Key? key,
    required this.room,
  }) : super(key: key);*/

  final types.Room room;

  types.User? currentUser;

  // final UserCredential? currentUser;

  // final currentUser;

  FlyerChatV2({Key? key, this.currentUser, required this.room})
      : super(key: key);

  @override
  _FlyerChatV2State createState() => _FlyerChatV2State();
}

bool localIsShown = false;

class _FlyerChatV2State extends State<FlyerChatV2> {
  Widget _bubbleBuilder(
    Widget child, {
    required types.Message message,
    required nextMessageInGroup,
  }) {
    // var user = widget.currentUser;
    var user = firestoreUserData;

    print('Message C - Whats _bubbleBuilder gets: ${message.toJson()}');

    // String image = user?.imageUrl ?? 'https://bit.ly/3l64LIk';
    String? image = message.metadata?['imageUrl'] ?? 'https://bit.ly/3l64LIk';
    print('IMAGE $image');
    // print('X IMAGE: $image');
    // var name = message.author.firstName ?? user?.firstName;
    String name = message.metadata?['firstName'] ?? 'UserName Here.';
    var createdAgo = timeAgo(message.createdAt);
    var text = message.toJson()['text'];
    String age =
        '${message.metadata?['metadata']?['age'] ?? 'XY'}'.substring(0, 2);

    bool isCurrentUser = user!.id == message.author.id;
    // if(currentUser) print('user ${user.firstName} connected now.');

    return Container(
      // color: Colors.blue,
      width: kMediaQuery(context).size.width * 0.90,
      // width: 300,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: InkWell(
          onLongPress: firestoreUserData?.toJson()['metadata']['MyModerator'] ==
                  true
              ? () async {
                  print('Long press taped.');
                  print(message.toJson());
                  showCustomRilAlert(
                    context,
                    title: 'למחוק הודעה זו?',
                    desc: '${message.toJson()['text']}',
                    actions: [
                      TextButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('rooms/NAMAkmZKdEAv9AefwXhR/messages')
                              .doc(message.id)
                              .delete();
                          kNavigator(context).pop();
                        },
                        child: const Text('מחק הודעה',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                      ),
                      TextButton(
                        onPressed: () => kNavigator(context).pop(),
                        child: const Text('ביטול',
                            style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  );
                }
              : () {
                  print(firestoreUserData?.toJson());
                },
          onTap: isCurrentUser
              ? () {}
              : () async {
                  final room = await FirebaseChatCore.instance
                      .createRoom(message.author);
                  kPushNavigator(
                      context,
                      FlyerDm(
                        room: room,
                      ));
                },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey[200]!, width: 1.5),
              borderRadius: BorderRadius.circular(6.0),
            ),
            elevation: 0,
            shadowColor: Colors.black87,
            color: Colors.grey[100]!,
            // color: Colors.white,
            child: Column(
              children: [
                const SizedBox(
                  height: 2,
                ),
                Container(
                  height: 20,
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  alignment: Alignment.centerRight,
/*                child:
                    InkWell(
                      child:
                      Icon(
                        Icons.more_horiz,
                        color: Colors.grey[400]!,
                     ),
                      onTap: () {},
                    ),*/
                ),
                Container(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  alignment: Alignment.topRight,
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  height: 80,
                  padding: const EdgeInsets.only(right: 10),
                  // color: Colors.primaries[Random().nextInt(Colors.primaries.length)].shade300,
                  // color: cGrey100,
                  child: Row(
                    children: [
                      Flexible(
                        child: ListTile(
                            dense: true,
                            visualDensity: VisualDensity.standard,
                            title: Text(
                              '$name ($age)',
                              style: TextStyle(
                                  // color: Colors.primaries[Random().nextInt(Colors.primaries.length)].shade600,
                                  // color: Colors.black
                                  color: Colors.grey[600]!,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                              // style: bodyText1Format(context)
                            ),
                            subtitle: Text(
                              /*' · '*/
                              'לפני '
                              '$createdAgo',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                  // color: Colors.primaries[Random().nextInt(Colors.primaries.length)].shade600,
                                  // color: Colors.black
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12),
                              // style: bodyText1Format(context)
                            ),
                            contentPadding: EdgeInsets.zero,
                            leading: CircleAvatar(
                              backgroundColor: Colors.grey,
                              backgroundImage: NetworkImage(image!),
                              // backgroundImage: NetworkImage('https://bit.ly/3l64LIk'),
                            )),
                      ),

                      if (!isCurrentUser)
                        Builder(
                            builder: (context) => Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[200],
                                      radius: 20,
                                      child: IconButton(
                                          onPressed: () async {
                                            final room = await FirebaseChatCore
                                                .instance
                                                .createRoom(message.author);
                                            kPushNavigator(
                                                context,
                                                FlyerDm(
                                                  room: room,
                                                ));
                                          },
                                          icon: Icon(
                                            Icons.send_rounded,
                                            color: Colors.grey[500],
                                            size: 20,
                                          )),
                                    ),
                                  ),
                                ))

                      // const SizedBox(width: 10),
                      // const Spacer(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    /*return Bubble(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if ('${user?.id}' == message.author.id)
                Text('${user?.firstName}'),
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage('${user?.imageUrl}'),
              ),
              if ('${user?.id}' != message.author.id)
                Text('${user?.firstName}',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14)
                ),
            ],
          ),
          child,
        ],
      ),
      color: '${user?.id}' != message.author.id ||
          message.type == types.MessageType.image
          ? const Color(0xfff5f5f7)
          : const Color(0xff6f61e8),
      margin: nextMessageInGroup
          ? const BubbleEdges.symmetric(horizontal: 6)
          : null,
      nip: nextMessageInGroup
          ? BubbleNip.no
          : '${user?.id}' != message.author.id
          ? BubbleNip.leftBottom
          : BubbleNip.rightBottom,
    );*/
  }

  bool _isAttachmentUploading = false;
  var guestUser;

  // GoogleSignInAccount? guestUser;
  // UserCredential? guestUser;
  String? appBarTitle;
  List<String>? roomEmailUsers;

  types.User? firestoreUserData;

  final isDisplayed = 'isDisplayed';

  /*    FirebaseChatCore.instance
        .createGroupRoom(
      users: [widget.currentUser!],
      name: 'RilHome',
    ).then((room) {
      print('room.id');
      print(room.id);
      print(room.name);
    });*/

  @override
  void initState() {
    // FirebaseAuth.instance.authStateChanges();

/*    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) async {
      // if ((await SharedPreferences.getInstance()).getBool(isDisplayed) ?? false)
      showAlert(context);
      localIsShown = true;
    });*/

    // if(!localIsShown) {
    //   Future.delayed(const Duration(seconds: 3), () => showAlert(context));
    //   localIsShown = true;
    // }

    // if (widget.currentUser?.imageUrl == null) {

    //~ Fetch user
    // fetchUser(widget.currentUser!.id, 'users').then((user) => print('fetchUser Json: $user'));
    var getUser = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.currentUser!.id)
        .get()
        .then((userDoc) {
      // print('init user DATA: ${userDoc.data()}');
      var data = userDoc.data() ?? {};
      // print('init AGE: ${data['metadata']['age']}');

      data['lastName'] = data['lastName'] ?? '';
      data['role'] = data['role'] ?? 'user';
      data['id'] = data['metadata']['id'] ?? '';
      // data['metadata']['age'] = data['metadata']['age'] ?? 0;
      data['createdAt'] = data['createdAt']?.millisecondsSinceEpoch;
      data['lastSeen'] = data['lastSeen']?.millisecondsSinceEpoch;
      data['updatedAt'] = data['updatedAt']?.millisecondsSinceEpoch;
      data['lastHomeMessage'] = data['metadata']['lastHomeMessage'];
      // data['metadata'] = data['updatedAt']?.millisecondsSinceEpoch;
      // widget.currentUser = types.User.fromJson(data);
      firestoreUserData = types.User.fromJson(data);
      print('firestore User DATA: ${firestoreUserData?.toJson()}');
    });
    // } else {
    //   firestoreUserData = widget.currentUser;
    //   print('widget.currentUser (from signup)'
    //       'User DATA: ${firestoreUserData?.toJson()}');
    //   // firestoreUserData?.metadata?['age'] = 19;
    //   // print('Debug: ${firestoreUserData?.metadata?['age']}');
    // }

// ----------------
/*
        var userData = widget.currentUser?.copyWith(
            firstName: '${data['firstName']}',
            imageUrl: '${data['imageUrl']}',
            metadata: {
              'email' : data['metadata']['email'],
              'age' : data['metadata']['age'],
              // 'id' : data['id'] ?? '',
              'id' : 'dd7WBSncPIhLwm7wl4FJEpiGRBj2',
              'birthDay' : data['metadata']['birthDay'],
              // 'lastHomeMessage': data['metadata']['lastHomeMessage']?.millisecondsSinceEpoch,
            }
        );
        widget.currentUser = userData;
        print('userData?.toJson()');
        print(userData?.toJson());
*/ /*


      // print('widget.currentUser ${widget.currentUser}');
      });
      // print('widget.currentUser.toJson() ${widget.currentUser?.toJson()}');
    }*/

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /*if(!localIsShown) {
      Future.delayed(const Duration(seconds: 3), () => showAlert(context));
      localIsShown = true;
    }*/

    var _timePassed = 0;
    var timeLeft = 60 * 5 - _timePassed;

    // print('BUILD currentUser JSON is:');
    // print(firestoreUserData?.toJson());

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: StreamBuilder<types.Room>(
          initialData: widget.room,
          stream: FirebaseChatCore.instance.room(widget.room.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return StreamBuilder<List<types.Message>>(
                initialData: const [],
                stream: FirebaseChatCore.instance.messages(snapshot.data!),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    types.Message msgWithAuthor;
                    // print('What Stream snapshot Data get: ${snapshot.data}');

                    // widget.currentUser = widget.room.users.firstWhere((user) =>
                    //   user.id == widget.currentUser!.id);
                    //
                    // print('STREAM currentUser JSON is:');
                    // print(widget.currentUser?.toJson());

                    List<types.Message> filteredMsgs = [];
                    // print('snapshot.data');
                    // print(snapshot.data);

                    // print('A G E: $');
                    // ----------------- Age filter

                    snapshot.data?.forEach((msg) {
                      // print(msg.toJson());
                      double authorAge =
                          msg.metadata?['metadata']['age'] ?? 0.0;
                      double currentUserAge =
                          firestoreUserData?.metadata?['age'] ?? 0.0;

                      var ageFilter = 3; //{14 [17] 20}
                      var minAge = currentUserAge - ageFilter; // ?? 14;
                      var maxAge = currentUserAge + ageFilter; // ?? 20;
                      // print(currentUserAge.runtimeType);

                      bool inAgeRange =
                          authorAge >= minAge && authorAge <= maxAge;
                      if (inAgeRange || authorAge == 0.0) filteredMsgs.add(msg);
                    });

                    return SafeArea(
                      bottom: false,
                      child: Chat(
                        theme: DefaultChatTheme(
                          inputBackgroundColor: cGrey300,
                          // backgroundColor: Colors.grey[100]!,
                          // inputBackgroundColor: cRilDeepPurple.withOpacity(0.85),
                        ),
                        isAttachmentUploading: _isAttachmentUploading,
                        // messages: snapshot.data ?? [],
                        messages: filteredMsgs,
                        // onAttachmentPressed: _handleAtachmentPressed,
                        // onMessageTap: _handleMessageTap,
                        sendButtonVisibilityMode:
                            SendButtonVisibilityMode.always,
                        onPreviewDataFetched: _handlePreviewDataFetched,
                        onSendPressed: (partialText) async =>
                            _handleSendPressed(partialText, firestoreUserData!),
                        user: types.User(
                            id: FirebaseChatCore.instance.firebaseUser?.uid ??
                                '',
                            firstName: 'WHATEVER'),
                        // user: widget.currentUser!,
                        bubbleBuilder: _bubbleBuilder,

                        /*
                      bubbleBuilder: (Widget child, {
                        required types.Message message,
                        required nextMessageInGroup,
                      }) {
                        return _bubbleBuilder(
                            child,
                            // message: message,
                            message: msgWithAuthor,
                            nextMessageInGroup: nextMessageInGroup);
                      },
                      */

                        showUserAvatars: false,
                        showUserNames: true,
                        // customMessageBuilder: (customMessage, {required int messageWidth}){return customMessage.copyWith()},
                        // customMessageBuilder: ,
                      ),
                    );
                  } else {
                    return GestureDetector(
                        onTap: () async {
                          print('Tapped');
                        },
                        child: const Center(child: Text('Loading..')));
                  }
                },
              );
            } else {
              return const Text(
                'Loading...',
                style: TextStyle(
                  color: neutral2,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              );
            }
          },
        ),

        /*floatingActionButton: Offstage(
          offstage: timeLeft <= 0,
          child: FloatingActionButton(
            onPressed: (){},
            child: StatefulBuilder(
                builder: (context, setState){
*/ /*                  Timer.periodic(const Duration(seconds: 1), (timer) {
                    setState((){
                      print('1 sec passed.');
                      print('$timeLeft');
                      print('${timeLeft <= 0}');
                      timeLeft = timeLeft - 1;
                    if (timeLeft <= 0) timer.cancel();
                    });
                    // timer.cancel();
                  });*/ /*
                  return Text('$timeLeft');
                }),
          ),
        ),*/
      ),
    );
  }

  void _handleAtachmentPressed() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SizedBox(
            height: 144,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleImageSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Photo'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleFileSelection();
                  },
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('File'),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      _setAttachmentUploading(true);
      final name = result.files.single.name;
      final filePath = result.files.single.path!;
      final file = File(filePath);

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialFile(
          mimeType: lookupMimeType(filePath),
          name: name,
          size: result.files.single.size,
          uri: uri,
        );

        FirebaseChatCore.instance.sendMessage(message, widget.room.id);
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      _setAttachmentUploading(true);
      final file = File(result.path);
      final size = file.lengthSync();
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);
      final name = result.name;

      try {
        final reference = FirebaseStorage.instance.ref(name);
        await reference.putFile(file);
        final uri = await reference.getDownloadURL();

        final message = types.PartialImage(
          height: image.height.toDouble(),
          name: name,
          size: size,
          uri: uri,
          width: image.width.toDouble(),
        );

        FirebaseChatCore.instance.sendMessage(
          message,
          widget.room.id,
        );
        _setAttachmentUploading(false);
      } finally {
        _setAttachmentUploading(false);
      }
    }
  }

  void _handleMessageTap(types.Message message) async {
    if (message is types.FileMessage) {
      var localPath = message.uri;

      if (message.uri.startsWith('http')) {
        final client = http.Client();
        final request = await client.get(Uri.parse(message.uri));
        final bytes = request.bodyBytes;
        final documentsDir = (await getApplicationDocumentsDirectory()).path;
        localPath = '$documentsDir/${message.name}';

        if (!File(localPath).existsSync()) {
          final file = File(localPath);
          await file.writeAsBytes(bytes);
        }
      }

      await OpenFile.open(localPath);
    }
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    final updatedMessage = message.copyWith(previewData: previewData);

    FirebaseChatCore.instance.updateMessage(updatedMessage, widget.room.id);
  }

  void _setAttachmentUploading(bool uploading) {
    setState(() {
      _isAttachmentUploading = uploading;
    });
  }

  void _handleSendPressed(
      types.PartialText message, types.User currentUser) async {
    print('my little msg $message');
    // var newMsg = message.metadata?.update
    //   ('8', (value) => 'New', ifAbsent: () => 'Mercury');

    // FirebaseChatCore.instance.updateMessage(newMsg, roomId);

    var getUser = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.id)
        .get();
    // print('AA');

    DateTime date;
    var _lastHomeMessage = getUser.data()?['metadata']['lastHomeMessage'];
    try {
      final _dateFormat = intl.DateFormat("yyyy-MM-dd HH:mm:ss");
      date = _dateFormat
          .parse(_lastHomeMessage); //Converting String to DateTime object
    } catch (e) {
      print('lastHomeMessage is probably timestamp. dealing with it..: err $e');
      date = _lastHomeMessage.toDate();
    }

    // Static Value - Don't use!
    // var date = firestoreUserData?.metadata?['lastHomeMessage'];
    //  2022-05-1317: 25: 18.649543,
    // print('FS MD ${firestoreUserData?.metadata?['lastHomeMessage']}');
    // String _lastHomeMessage = '${firestoreUserData?.metadata?['lastHomeMessage']}';

    final nowDate = DateTime.now();
    final difference = nowDate.difference(date);
    print('difference.inSeconds');
    print(difference.inSeconds);

    var time2Wait = kDebugMode ? 30 : 60 * 3;

    var waitUntil =
        DateTime.now().add(Duration(seconds: time2Wait - difference.inSeconds));
    print('waitUntil');
    print(waitUntil);

    if (difference.inSeconds < time2Wait) {
      cleanSnack(context,
          text: 'בבקשה המתן עד ' +
              '$waitUntil'.substring(11, 16) +
              ' (${time2Wait - difference.inSeconds}'
                  ' שניות'
                  ')');
    } else {
      var _user = FirebaseAuth.instance.currentUser;
      var lastHomeMessage = DateTime.now();
      print('_user: ${_user?.uid}');

      var _userData = currentUser.copyWith(
          firstName: '${currentUser.firstName}',
          imageUrl: '${currentUser.imageUrl}',
          metadata: {
            'id': currentUser.id,
            'email': '${currentUser.metadata?['email']}',
            'birthDay': currentUser.metadata?['birthDay'],
            'age': currentUser.metadata?['age'],
            'lastHomeMessage': '$lastHomeMessage',
          });

      // setState(() async {
      // create or update
      await FirebaseChatCore.instance
          .createUserInFirestore(_userData)
          .whenComplete(() => print(
              'firebaseDatabase_basedFlyer Completed \n(FirebaseChatCore.instance.createUserInFirestore)'
              '\n userData: $_userData'))
          .onError((error, stackTrace) => print(
              'firebaseDatabase_basedFlyer FAILED: $error \n-|- $stackTrace \n(FirebaseChatCore.instance.createUserInFirestore)'));
      // });

      print('Message A: ${message.toJson()}');

      FirebaseChatCore.instance.sendMessage(
        message,
        widget.room.id,
        myAuthUser: _userData,
      );
    }
  }
}

showRilAlert(context, bool exitProfile) async {
  showDialog(
    barrierDismissible: true,
    context: context,
    // barrierColor: StreamChatTheme.of(context).colorTheme.overlay,
    builder: (context) => Center(
        child: AlertDialog(
      // contentPadding: EdgeInsets.zero,
      // titlePadding: EdgeInsets.zero,
      actionsAlignment: MainAxisAlignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title:
      Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 13.0),
            child: Text(
              exitProfile ? 'תרצה לצאת' : 'ברוכים הבאים אל',
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                exitProfile ? ' מרילטופיה?' : 'רילטופיה',
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 25),
              ),

              SvgPicture.asset(
                'assets/svg_icons/CleanLogo.svg',
                height: 30,
                // color: StreamChatTheme.of(context).colorTheme.accentPrimary,
              ),
              // trailing: Image.asset('assets/RilTopialLogoAndTxt.png',
              //   height: 45,)
            ],
          ),
          const SizedBox(height: 20),
          const Center(
              child: Text(
            'כולם כאן בגיל שלך (+3-)'
            '\n זה המקום להכיר, לשתף, לעזור ולהיות מי שאתה!',
            style: TextStyle(
              color: neutral2,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          )),
        ],
      )),
      // content: Text("Saved successfully"),
      actions: [
        TextButton(
          onPressed: () => kNavigator(context).pop(),
          child: Text(exitProfile ? 'חזור' : 'התחל',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: cRilPurple)),
        ),
        if (exitProfile)
          TextButton(
            onPressed: () => kPushNavigator(context, const LoginPage()),
            child: const Text('יציאה', style: TextStyle(color: Colors.grey)),
          ),
      ],
    )),
  );
}

showCustomRilAlert(context,{
      String? title,
      String? desc,
      List<Widget>? actions,
      Widget? titleWidget
}) async {
  showDialog(
    barrierDismissible: true,
    context: context,
    // barrierColor: StreamChatTheme.of(context).colorTheme.overlay,
    builder: (context) => Center(
        child: AlertDialog(
      // contentPadding: EdgeInsets.zero,
      // titlePadding: EdgeInsets.zero,
      actionsAlignment: MainAxisAlignment.center,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title:
          titleWidget ?? Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 13.0),
            child: Text(
              '$title',
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
          ),
          const SizedBox(height: 20),
          Center(
              child: Text(
            '$desc',
            style: const TextStyle(
              color: neutral2,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          )),
        ],
      )),
      // content: Text("Saved successfully"),
      actions: actions,
    )),
  );
}
