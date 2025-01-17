import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BoxAlert extends StatelessWidget {
  const BoxAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      actionsPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.only(top: 0, bottom: 30, left: 35, right: 35),
      titlePadding: EdgeInsets.all(15),
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Email không hợp lệ!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 300,
              height: 150,
              child: Lottie.asset('assets/lotties/exclamation.json'),
            ),
          ),
        ],
      ),
    );
  }
}