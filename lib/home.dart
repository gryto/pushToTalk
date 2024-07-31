import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pushtotalk/screen/talk/page.dart';
import '../src/preference.dart';
import 'audiospeech.dart';
import 'record_and_play.dart';
import 'record_and_play_2.dart';
import 'sample.dart';
import 'screen/chat_room/chat_room.dart';
import 'screen/message/page.dart';
import 'screen/profile/page.dart';
import 'speechToText.dart';
import 'src/api.dart';
import 'src/constant.dart';
import 'src/toast.dart';
import 'src/utils.dart';
import 'package:http/http.dart' as http;

import 'widgets/bottom_icon_widget.dart';

class MainTabBar extends StatefulWidget {
  final id;
  final page;
  const MainTabBar({Key? key, required this.id, required this.page})
      : super(key: key);

  @override
  _MainTabBarState createState() => _MainTabBarState();
}

class _MainTabBarState extends State<MainTabBar> {
  SharedPref sharedPref = SharedPref();
  bool isProcess = false;
  int pageIndex = 0;
  String fullName = "";
  String division = "";
  String typeUser = "";
  String path = "";
  String accessToken = "";
  String dateString = "";
  late final Function(int) callback;
  String message = "";
  List<Map<String, dynamic>> listData = [];
  List<Widget> pages = <Widget>[]; // Declare pages here

  String fullname = "";
  late int userId = 0;

  var offset = 0;
  var limit = 10;

  @override
  void initState() {
    getData(widget.id);
    pageIndex = widget.page;
    super.initState();
  }

  getData(id) async {
    pages = [
      MessageListPage(
        id: userId.toString(),
      ),
      const Stt(),
      // SpeechScreen(),
      // SpeechSampleApp(),
      // AudioRecorder(),
      // RecordingScreen(),
      // const Stt(),
      // MessageListPage(),
      // SosListPage(),
      // ChatRoomPage(id: userId.toString()),
      // ContactPage(userName: fullname, division: division, image: path, id: userId.toString()),
      // const SamplePage(),
    ];
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.detailUser;
      var uri = "$url/$id";
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});

      if (response.statusCode == 200) {
        setState(() {
          var content = json.decode(response.body);

          fullname = content['data']['fullname'];
          division = content['data']['getrole']['name'];
          listData.add(content['data']);
          userId = content['data']['id'];
          path = content['data']['image'];
          pages = [
            // RecordingScreen(),
            MessageListPage(
              id: userId.toString(),
            ),
            const Stt(),

            // SpeechScreen(),
            // SpeechSampleApp(),
            // AudioRecorder(),

            // SosListPage(),
            // ChatRoomPage(id: userId.toString()),
            // ContactPage(userName: fullname, division: division, image: path, id:userId.toString() ),
            // const SamplePage(),
          ];
        });
      } else {
        toastShort(context, message);
      }
    } catch (e) {
      toastShort(context, e.toString());
    }

    setState(() {
      isProcess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SettingLogic(id: widget.id),
                    ),
                  );
                },
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(
                          '${ApiService.folder}/$path',
                          scale: 10,
                        ),
                        fit: BoxFit.fill),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullname,
                    style: SafeGoogleFont(
                      'SF Pro Text',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.2575,
                      letterSpacing: 1,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    division,
                    style: SafeGoogleFont(
                      'SF Pro Text',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.2575,
                      letterSpacing: 1,
                      color: clrBackground,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      body: Center(
        child: pages[pageIndex],
        // ContactPage(userName: fullname, division: division, image: path, id: userId.toString()),
      ),
      bottomNavigationBar: Container(
        height: 70,
        color: Colors.white,
        margin: const EdgeInsets.only(top: 2, right: 0, left: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            BottomIconWidget(
              title: 'Talk',
              iconName: Icons.record_voice_over,
              iconColor: pageIndex == 0 ? clrPrimary : clrBackground,
              tap: () {
                setState(() {
                  pageIndex = 0;
                });
              },
            ),
            BottomIconWidget(
              title: 'Timeline',
              iconName: Icons.voice_chat,
              iconColor: pageIndex == 1 ? clrPrimary : clrBackground,
              tap: () {
                setState(() {
                  pageIndex = 1;
                });
              },
            ),
            // BottomIconWidget(
            //   title: 'Call',
            //   iconName: Icons.call,
            //   iconColor: pageIndex == 2 ? clrPrimary : clrBackground,
            //   tap: () {
            //     setState(() {
            //       pageIndex = 2;
            //     });
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}
