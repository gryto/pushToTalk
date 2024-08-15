import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../../../../widgets/spacer/spacer_custom.dart';
import '../../../gen/assets.gen.dart';
import '../../../recordAndplayFix222.dart';
import '../../../recordAndplayFix.dart';
import '../../../record_and_play copy.dart';
import '../../../record_and_play.dart';
import '../../../record_and_play_2.dart';
import '../../../speectAndRecordPlay.dart';
import '../../../src/api.dart';
import '../../../src/constant.dart';
import '../../../src/preference.dart';
import '../../../src/toast.dart';
import '../../../src/utils.dart';
import '../../chat_room/chat_room.dart';
import 'package:http/http.dart' as http;

class MessageViewWidget extends StatefulWidget {
  // final List<dynamic> data;
  final String id;
  const MessageViewWidget({
    super.key,
    // required this.data,
    required this.id,
  });

  @override
  State<MessageViewWidget> createState() => _MessageViewWidgetState();
}

class _MessageViewWidgetState extends State<MessageViewWidget> {
  SharedPref sharedPref = SharedPref();
  bool isProcess = false;
  int pageIndex = 0;
  String fullName = "";
  String division = "";
  String typeUser = "";
  String path = "";
  String accessToken = "";
  String message = "";
  List listData = [];

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() async {
    try {
      var accessToken = await sharedPref.getPref("access_token");
      var url = ApiService.listChannel;
      var uri = url;
      var bearerToken = 'Bearer $accessToken';
      var response = await http.get(Uri.parse(uri),
          headers: {"Authorization": bearerToken.toString()});

      if (response.statusCode == 200) {
        setState(() {
          print("isian listchannel");
          var content = json.decode(response.body);
          print(content);
          print("datanya");
          listData = content['data'];
          print(listData);
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
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 5, top: 5, left: 5.0, right: 5.0),
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemBuilder: (_, index) {
        var row = listData[index];
        print("lisdtdataperkara");
        print(row);

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  // Navigasi berdasarkan index atau data tertentu
                  if (index == 0) {
                    return RecordingScreen(
                      userId: widget.id,
                      channelId: row['id'].toString(),
                      dataUser: row['users'],
                    );
                  } else if (index == 1) {
                    return RecordingScreen(
                      userId: widget.id,
                      channelId: row['id'].toString(),
                      dataUser: row['users'],
                    );
                  } else {
                    // Navigasi default atau kondisi lainnya
                    return RecordingScreen(
                      userId: widget.id,
                      channelId: row['id'].toString(),
                      dataUser: row['users'],
                    );
                  }
                },
              ),
            );
          },
          child: ChatUserListCardWidget(
            image: ApiService.imgDefault,
            name: row['nama'] ?? "-",
            isOnline: true,
            message: Text(
              row['deskripsi'],
              overflow: TextOverflow.ellipsis,
              style: SafeGoogleFont(
                'SF Pro Text',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.2575,
                letterSpacing: 1,
                color: Colors.grey.shade500,
              ),
            ),
            unReadCount: '',
            isUnReadCountShow: false,
            time: '07.00',
          ),
        );
      },
      separatorBuilder: (_, index) => const SizedBox(
        height: 5,
      ),
      itemCount: listData.isEmpty ? 0 : listData.length,
    );

    // Column(
    //   children: [
    //     ChatUserListCardWidget(
    //       image: ApiService.imgDefault,
    //       name: 'Channel 1',
    //       isOnline: true,
    //       message: Text(
    //         "Aku adalah anak gembala selalu riang serta",
    //         overflow: TextOverflow.ellipsis,
    //         style: SafeGoogleFont(
    //           'SF Pro Text',
    //           fontSize: 14,
    //           fontWeight: FontWeight.w500,
    //           height: 1.2575,
    //           letterSpacing: 1,
    //           color: Colors.grey.shade500,
    //         ),
    //       ),
    //       unReadCount: '',
    //       isUnReadCountShow: false,
    //       time: '07.00',
    //       onTap: () {
    //         Navigator.of(context).push(
    //           MaterialPageRoute(
    //               builder: (context) => AudioRecordingPage(
    //                     userId: widget.id,
    //                   )),
    //         );
    //       },
    //     ),
    //     ChatUserListCardWidget(
    //       image: ApiService.imgDefault,
    //       name: 'Channel 2',
    //       isOnline: true,
    //       message: Text(
    //         "Aku adalah anak gembala selalu riang serta",
    //         overflow: TextOverflow.ellipsis,
    //         style: SafeGoogleFont(
    //           'SF Pro Text',
    //           fontSize: 14,
    //           fontWeight: FontWeight.w500,
    //           height: 1.2575,
    //           letterSpacing: 1,
    //           color: Colors.grey.shade500,
    //         ),
    //       ),
    //       unReadCount: '',
    //       isUnReadCountShow: false,
    //       time: '07.00',
    //       onTap: () {
    //         Navigator.of(context).push(
    //           MaterialPageRoute(
    //             builder: (context) => RecordingScreen(
    //               userId: widget.id,
    //             ),
    //           ),
    //         );
    //       },
    //     ),
    //     ChatUserListCardWidget(
    //       image: ApiService.imgDefault,
    //       name: 'Channel 3',
    //       isOnline: true,
    //       message: Text(
    //         "Aku adalah anak gembala selalu riang serta",
    //         overflow: TextOverflow.ellipsis,
    //         style: SafeGoogleFont(
    //           'SF Pro Text',
    //           fontSize: 14,
    //           fontWeight: FontWeight.w500,
    //           height: 1.2575,
    //           letterSpacing: 1,
    //           color: Colors.grey.shade500,
    //         ),
    //       ),
    //       unReadCount: '',
    //       isUnReadCountShow: false,
    //       time: '07.00',
    //       onTap: () {
    //         Navigator.of(context).push(
    //           MaterialPageRoute(
    //             builder: (context) => AudioRecordingPageFix(
    //               userId: widget.id,
    //             ),

    //             // RecordingScreen(userId: widget.id,),
    //           ),
    //         );
    //       },
    //     ),
    //     ChatUserListCardWidget(
    //       image: ApiService.imgDefault,
    //       // Assets.images.user3.path,
    //       name: 'Channel 4',
    //       isOnline: true,
    //       message: Text(
    //         "Aku adalah anak gembala selalu riang serta",
    //         overflow: TextOverflow.ellipsis,
    //         style: SafeGoogleFont(
    //           'SF Pro Text',
    //           fontSize: 14,
    //           fontWeight: FontWeight.w500,
    //           height: 1.2575,
    //           letterSpacing: 1,
    //           color: Colors.grey.shade500,
    //         ),
    //       ),
    //       unReadCount: '',
    //       isUnReadCountShow: false,
    //       time: '07.00',
    //       onTap: () {
    //         Navigator.of(context).push(
    //           MaterialPageRoute(
    //             builder: (context) => SoundRecorder(
    //               userId: widget.id,
    //             ),

    //             // RecordingScreen(userId: widget.id,),
    //           ),
    //         );
    //       },
    //     ),
    //   ],
    // );
  }

  // Fungsi untuk mengubah selisih waktu menjadi format menit yang lalu
  String timeAgoFromDuration(Duration difference) {
    if (difference.inSeconds < 60) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else {
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    }
  }
}

class ChatUserListCardWidget extends StatelessWidget {
  const ChatUserListCardWidget({
    required this.name,
    required this.image,
    required this.isOnline,
    required this.message,
    required this.unReadCount,
    required this.isUnReadCountShow,
    required this.time,
    this.onTap,
  });

  final String name;
  final String image;
  final bool isOnline;

  final Widget message;
  final String unReadCount;
  final bool isUnReadCountShow;
  final String time;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: NetworkImage(image), fit: BoxFit.fill),
                    shape: BoxShape.circle,
                  ),
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: clrPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(1.5),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: clrPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const CustomWidthSpacer(
              size: 0.03,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: SafeGoogleFont(
                      'SF Pro Text',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.2575,
                      letterSpacing: 1,
                      color: const Color(0xff1e2022),
                    ),
                  ),
                  message
                ],
              ),
            ),
            const CustomWidthSpacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  textAlign: TextAlign.right,
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: const Color(0xff77838f),
                  ),
                ),
                const CustomHeightSpacer(),
                if (isUnReadCountShow)
                  Container(
                    width: 43,
                    height: 25,
                    decoration: BoxDecoration(
                      color: clrPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        unReadCount,
                        textAlign: TextAlign.center,
                        style: SafeGoogleFont(
                          'SF Pro Text',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.2575,
                          color: const Color(0xffffffff),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
