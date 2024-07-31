import 'package:flutter/material.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../widgets/spacer/spacer_custom.dart';
import '../../../src/constant.dart';
import '../../../src/utils.dart';

class CallViewWidget extends StatelessWidget {
  const CallViewWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CallCardWidget(
            name: 'Pelican Steve',
            image: Assets.images.user6.path,
            isOnline: true,
            secondTitle: 'Missed Call',
            secondColor: clrPrimary,
            time: '32 min',
          ),
          const GroupCallCardWidget(),
          CallCardWidget(
            name: 'Jarvis Pepperspray',
            image: Assets.images.user4.path,
            isOnline: true,
            secondTitle: 'Missed Call',
            secondColor: clrPrimary,
            time: '1 hour',
          ),
          CallCardWidget(
            name: 'Carnegie Mondover',
            image: Assets.images.user3.path,
            isOnline: true,
            secondTitle: 'Incoming Call',
            secondColor: clrPrimary,
            time: '2 hour',
          ),
          CallCardWidget(
            name: 'Carnegie Mondover',
            image: Assets.images.user5.path,
            isOnline: false,
            secondTitle: 'Incoming Call',
            secondColor: clrPrimary,
            time: '2 hour',
          ),
          CallCardWidget(
            name: 'Theodore Handle',
            image: Assets.images.user6.path,
            isOnline: false,
            secondTitle: 'Video Call',
            secondColor: clrPrimary,
            time: '2 days',
          ),
          CallCardWidget(
            name: 'Theodore Handle',
            image: Assets.images.user7.path,
            isOnline: false,
            secondTitle: 'Video Call',
            secondColor: clrPrimary,
            time: '2 days',
          ),
          CallCardWidget(
            name: 'Justin Case',
            image: Assets.images.user8.path,
            isOnline: false,
            secondTitle: 'Outgoing Call (2)',
            secondColor: clrPrimary,
            time: '2 days',
          ),
        ],
      ),
    );
  }
}

class GroupCallCardWidget extends StatelessWidget {
  const GroupCallCardWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Assets.images.user3.path),
                      fit: BoxFit.fill),
                  shape: BoxShape.circle,
                ),
              ),
              const CustomHeightSpacer(),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Assets.images.user4.path),
                      fit: BoxFit.fill),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const CustomWidthSpacer(),
          Column(
            children: [
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Assets.images.user5.path),
                      fit: BoxFit.fill),
                  shape: BoxShape.circle,
                ),
              ),
              const CustomHeightSpacer(),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(Assets.images.user7.path),
                      fit: BoxFit.fill),
                  shape: BoxShape.circle,
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
                  "Friends Group Call",
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: const Color(0xff1e2022),
                  ),
                ),
                const CustomHeightSpacer(
                  size: 0.006,
                ),
                Text(
                  'Video Call',
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: const Color(0xff77838f),
                  ),
                ),
                const CustomHeightSpacer(
                  size: 0.006,
                ),
                Text(
                  '34 min',
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: const Color(0xff77838f),
                  ),
                ),
              ],
            ),
          ),
          const CustomWidthSpacer(),
          Image.asset(
            Assets.icons.icVideo.path,
            width: 20,
            height: 20,
          ),
          const CustomWidthSpacer(
            size: 0.05,
          ),
          Image.asset(
            Assets.icons.icCall.path,
            width: 15,
            height: 15,
          )
        ],
      ),
    );
  }
}

class CallCardWidget extends StatelessWidget {
  const CallCardWidget({
    super.key,
    required this.name,
    required this.image,
    required this.isOnline,
    required this.secondTitle,
    required this.secondColor,
    required this.time,
  });
  final String name;
  final String image;
  final bool isOnline;

  final String secondTitle;
  final Color secondColor;

  final String time;
  @override
  Widget build(BuildContext context) {
    return Padding(
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
                      image: AssetImage(image), fit: BoxFit.fill),
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
                    decoration: BoxDecoration(
                      color: clrPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.5),
                      child: Container(
                        decoration: BoxDecoration(
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
                const CustomHeightSpacer(
                  size: 0.006,
                ),
                Text(
                  secondTitle,
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: secondColor,
                  ),
                ),
                const CustomHeightSpacer(
                  size: 0.006,
                ),
                Text(
                  '15 min',
                  style: SafeGoogleFont(
                    'SF Pro Text',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.2575,
                    letterSpacing: 1,
                    color: const Color(0xff77838f),
                  ),
                ),
              ],
            ),
          ),
          const CustomWidthSpacer(),
          Image.asset(
            Assets.icons.icVideo.path,
            width: 20,
            height: 20,
          ),
          const CustomWidthSpacer(
            size: 0.05,
          ),
          Image.asset(
            Assets.icons.icCall.path,
            width: 15,
            height: 15,
          )
        ],
      ),
    );
  }
}
