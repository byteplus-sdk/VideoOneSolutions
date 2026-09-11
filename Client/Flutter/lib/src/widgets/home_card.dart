import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeCard extends StatelessWidget {
  const HomeCard({
    super.key,
    required this.imgPath,
    required this.title,
    required this.subTitle,
    required this.linkRoute,
  });

  final String imgPath;

  final String title;

  final String subTitle;

  final String? linkRoute;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16).w,
      padding: const EdgeInsets.symmetric(vertical: 3).w,
      height: 252.w,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imgPath),
          fit: BoxFit.contain,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0).w,
            child: GestureDetector(
              onTap: () {
                if (linkRoute != null) {
                  Navigator.pushNamed(context, linkRoute!);
                } else {
                  Fluttertoast.showToast(
                    msg: 'Coming Soon',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.CENTER,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 24 / 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subTitle,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12).w,
                    child: Image(
                        width: 32.w,
                        height: 32.w,
                        image:
                            const AssetImage('assets/images/home/back.png')),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
