import 'package:flutter/material.dart';
import 'gen/assets.gen.dart';
import 'src/utils.dart';

class SamplePage extends StatelessWidget {
  const SamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width - 0;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child:  Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         HistoryDetail(listDetail: row, sosId: sosId),
                    //   ),
                    // );
                  },
                  child: ListTile(
                    leading: Text(
                      "A",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black38,
                      ),
                    ),
                  ),
                ),
                Divider(),
                Container(
                  width: w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.0),
                    color: Colors.white,
                  ),
                  child: GestureDetector(
                    onTap: () {
                    //   Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => const InfoUser(),
                    //   ),
                    // );
                    },
                    child: ListTile(
                      leading: Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage(Assets.images.user2.path),
                              fit: BoxFit.fill),
                          shape: BoxShape.circle,
                        ),
                      ),
                      title: Text(
                        "Aaron Loeb",
                        style: SafeGoogleFont(
                          'SF Pro Text',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.2575,
                          letterSpacing: 1,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        "+629576478988",
                        style: SafeGoogleFont(
                          'SF Pro Text',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.2575,
                          letterSpacing: 1,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         HistoryDetail(listDetail: row, sosId: sosId),
                    //   ),
                    // );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Assets.images.user5.path),
                            fit: BoxFit.fill),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      "Adeline Palmerston",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "+629576478988",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Text(
                    "B",
                    style: SafeGoogleFont(
                      'SF Pro Text',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.2575,
                      letterSpacing: 1,
                      color: Colors.black38,
                    ),
                  ),
                ),
                Divider(),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         HistoryDetail(listDetail: row, sosId: sosId),
                    //   ),
                    // );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Assets.images.user4.path),
                            fit: BoxFit.fill),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      "Baley Dupon",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "+629576478988",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         HistoryDetail(listDetail: row, sosId: sosId),
                    //   ),
                    // );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Assets.images.user3.path),
                            fit: BoxFit.fill),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      "Benjamin Syaih",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "+629576478988",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         HistoryDetail(listDetail: row, sosId: sosId),
                    //   ),
                    // );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Assets.images.user6.path),
                            fit: BoxFit.fill),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      "Brigoyye Schwart",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "+629576478988",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Text(
                    "C",
                    style: SafeGoogleFont(
                      'SF Pro Text',
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      height: 1.2575,
                      letterSpacing: 1,
                      color: Colors.black38,
                    ),
                  ),
                ),
                Divider(),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         HistoryDetail(listDetail: row, sosId: sosId),
                    //   ),
                    // );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Assets.images.user2.path),
                            fit: BoxFit.fill),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      "Charles and Keith",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "+629576478988",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         HistoryDetail(listDetail: row, sosId: sosId),
                    //   ),
                    // );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Assets.images.user2.path),
                            fit: BoxFit.fill),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      "Aaron Loeb",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "+629576478988",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         HistoryDetail(listDetail: row, sosId: sosId),
                    //   ),
                    // );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Assets.images.user2.path),
                            fit: BoxFit.fill),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      "Aaron Loeb",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "+629576478988",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         HistoryDetail(listDetail: row, sosId: sosId),
                    //   ),
                    // );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Assets.images.user2.path),
                            fit: BoxFit.fill),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      "Aaron Loeb",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "+629576478988",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) =>
                    //         HistoryDetail(listDetail: row, sosId: sosId),
                    //   ),
                    // );
                  },
                  child: ListTile(
                    leading: Container(
                      width: 55,
                      height: 55,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage(Assets.images.user2.path),
                            fit: BoxFit.fill),
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      "Aaron Loeb",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "+629576478988",
                      style: SafeGoogleFont(
                        'SF Pro Text',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.2575,
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const Divider(),
              ],
            ),
          
        ),
      ),
    );
  }
}
