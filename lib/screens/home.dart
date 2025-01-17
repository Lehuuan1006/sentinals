import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinal/bloc/logout/logout_bloc.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/utils/stogares.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

import 'package:sentinal/widgets/custom_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userRole;

  @override
  void initState() {
    super.initState();
  }

  @override
Widget build(BuildContext context) {
  final String? userRole = StorageUtils.instance.getString(key: 'user_role');
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      title: Text(
        userRole == 'Admin'
            ? 'Admin Home Page'
            : userRole == 'Member'
                ? 'Member Home Page'
                : 'Home Screen',
      ),
      actions: [
        BlocProvider(
          create: (context) => LogoutBloc(),
          child: BlocListener<LogoutBloc, LogoutState>(
            listener: (context, state) {
              if (state is LogoutSuccess) {
                navigatorKey.currentContext?.go('/');
              } else if (state is LogoutFailure) {
                showCustomDialogModal(
                  context: navigatorKey.currentContext!,
                  textDesc: state.errorText ?? 'Không thể kết nối đến máy chủ',
                  title: "Thông báo",
                  colorButtonOk: Colors.red,
                  btnOKText: "Xác nhận",
                  typeDialog: "error",
                  eventButtonOKPress: () {},
                  isTwoButton: false,
                );
              }
            },
            child: BlocBuilder<LogoutBloc, LogoutState>(
              builder: (context, state) {
                return InkWell(
                  onTap: () {
                    showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc: "Bạn có chắc muốn đăng xuất?",
                      title: "Thông báo",
                      colorButtonOk: Colors.blue,
                      btnOKText: "Xác nhận",
                      typeDialog: "question",
                      eventButtonOKPress: () {
                        context.read<LogoutBloc>().add(LogoutButtonPressed());
                      },
                      isTwoButton: true,
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Container(
                      padding: EdgeInsets.only(left: 5.w, right: 5.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5.r),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Đăng xuất",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          SizedBox(
                            width: 30.w,
                            height: 30.w,
                            child: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    ),
    body: const Center(
      child: Text('Nội dung màn hình chính'),
    ),
  );
}
}
