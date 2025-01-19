import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:sentinal/widgets/text_app.dart';

class NoDataFoundWidget extends StatelessWidget {
  const NoDataFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: SizedBox(
            width: 200.w,
            height: 200.w,
            child: Lottie.asset('assets/lotties/empty_box.json',
                fit: BoxFit.contain),
          ),
        ),
        TextApp(
          text: "Không có dữ liệu!",
          fontsize: 18.sp,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ],
    );
  }
}
