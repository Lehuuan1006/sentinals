import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:sentinal/bloc/logout/logout_bloc.dart';
import 'package:sentinal/bloc/get_infor_profile/get_infor_profile_bloc.dart';
import 'package:sentinal/bloc/request_role/request_role_bloc.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/screens/change_password.dart';
import 'package:sentinal/screens/edit_profile.dart';
import 'package:sentinal/utils/stogares.dart';
import 'package:sentinal/widgets/custom_dialog.dart';
import 'package:sentinal/widgets/text_app.dart';
import 'package:theme_provider/theme_provider.dart';

class ProfileUserScreen extends StatefulWidget {
  const ProfileUserScreen({super.key});

  @override
  State<ProfileUserScreen> createState() => _ProfileUserScreenState();
}

class _ProfileUserScreenState extends State<ProfileUserScreen> {
  String? contactName;
  String? email;
  String? phoneNumber;
  String? profileImage; // Chuỗi base64
  String? role;
  bool isTurnoffFaceID = false;
  List<String> menuMyAccountTitle = [
    "Thông tin tài khoản",
    "Đổi mật khẩu",
    "Biometric Login",
  ];

  List menuMyAccountIcon = [Icons.people, Icons.lock, Icons.face];

  final List<void Function(BuildContext)> menuMyAccountActions = [
    (context) {
      log("EditProfileScreen tapped");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
      );
    },
    (context) {
      log("Change Password tapped");
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const ChangePasswordScreen()));
    },
    (context) {
      // Action for "Face ID"
      log("Face ID tapped");
    },
  ];
  void turnOnFaceID() async {
    final String? emailSaved =
        StorageUtils.instance.getString(key: 'saved_email');
    final String? passwordSaved =
        StorageUtils.instance.getString(key: 'save_password');
    if (emailSaved != null && passwordSaved != null) {
      await StorageUtils.instance
          .setString(key: 'email_login_autofill', val: emailSaved);
      await StorageUtils.instance
          .setString(key: 'password_login_autofill', val: passwordSaved);
    }
  }

  void turnOffFaceID() async {
    await StorageUtils.instance.removeKey(key: 'email_login_autofill');
    await StorageUtils.instance.removeKey(key: 'password_login_autofill');
    await StorageUtils.instance.removeKey(key: 'saved_email');
    await StorageUtils.instance.removeKey(key: 'save_password');
  }

  bool faceIdEnabled = false;


Future<void> getInforUser() async {
  // Lấy userId từ FirebaseAuth
  final User? user = FirebaseAuth.instance.currentUser;
  final String? userId = user?.uid;

  if (userId != null && userId.isNotEmpty) {
    // Gửi sự kiện GetProfileInfo đến GetInforProfileBloc với userId
    context.read<GetInforProfileBloc>().add(GetProfileInfo(userId: userId));
  } else {
    // Xử lý trường hợp userId là null hoặc rỗng
    log('User ID is null or empty');
  }
}

  void init() async {
    await getInforUser();
  }

  @override
  void initState() {
    init();
    super.initState();
    final bool? enableFaceID =
        StorageUtils.instance.getBool(key: 'enable_faceID');
    if (enableFaceID != null) {
      faceIdEnabled = enableFaceID;
    } else {
      faceIdEnabled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? userrole = StorageUtils.instance.getString(key: 'user_role');
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        foregroundColor: Theme.of(context).colorScheme.background,
        shadowColor: Theme.of(context).colorScheme.background,
        surfaceTintColor: Theme.of(context).colorScheme.background,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.background,
        ),
        title: TextApp(
          text: "Profile",
          fontsize: 20.sp,
          color: Theme.of(context).colorScheme.onBackground,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<GetInforProfileBloc, GetInforProfileState>(
            listener: (context, state) {
              if (state is GetInforProfileSuccess) {
                setState(() {
                  contactName = state.contactName;
                  email = state.email;
                  phoneNumber = state.phoneNumber;
                  profileImage = state.profileImage;
                  role = state.role;
                });
              }
            },
          )
        ],
        child: BlocBuilder<GetInforProfileBloc, GetInforProfileState>(
          builder: (context, state) {
            if (state is GetInforProfileSuccess) {
              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 1.sw,
                        color: Theme.of(context).colorScheme.background,
                        child: Padding(
                          padding: EdgeInsets.all(10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 60.w,
                                    height: 60.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(30),
                                      border: Border.all(
                                        width: 2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(30.w),
                                      child: profileImage == null ||
                                              profileImage!.isEmpty
                                          ? Image.asset(
                                              'assets/images/user_avatar.png',
                                              fit: BoxFit.contain,
                                            )
                                          : Image.memory(
                                              base64Decode(profileImage!),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 15.w,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          TextApp(
                                            text: contactName ?? '',
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                          TextApp(
                                            text: " | ",
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                          TextApp(
                                            text: role ?? '',
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onBackground,
                                          ),
                                        ],
                                      ),
                                      TextApp(
                                        text: email ?? '',
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.w),
                        child: TextApp(text: "MY ACCOUNT"),
                      ),
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: menuMyAccountTitle.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              menuMyAccountActions[index](context);
                            },
                            child: Container(
                              width: 1.sw,
                              // height: 100.h,
                              color: Theme.of(context).colorScheme.background,
                              child: Padding(
                                padding: EdgeInsets.only(
                                    bottom: 10.w, left: 10.w, right: 10.w),
                                child: Column(
                                  children: [
                                    index == 0
                                        ? SizedBox(
                                            height: 10.h,
                                          )
                                        : Container(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              menuMyAccountIcon[index],
                                              size: 30.w,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                            ),
                                            SizedBox(
                                              width: 15.w,
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    TextApp(
                                                      text: menuMyAccountTitle[
                                                          index],
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onBackground,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        index ==
                                                menuMyAccountTitle
                                                    .indexOf("Biometric Login")
                                            ? Transform.scale(
                                                scale:
                                                    0.8, // Adjust the scale factor as needed
                                                child: Switch(
                                                  activeColor: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  value: faceIdEnabled,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      faceIdEnabled = value;
                                                    });

                                                    if (faceIdEnabled == true) {
                                                      StorageUtils.instance
                                                          .setBool(
                                                              key:
                                                                  'enable_faceID',
                                                              val: true);
                                                      turnOnFaceID();
                                                      isTurnoffFaceID = false;
                                                    } else {
                                                      StorageUtils.instance
                                                          .setBool(
                                                              key:
                                                                  'enable_faceID',
                                                              val: false);
                                                      // turnOffFaceID();
                                                      isTurnoffFaceID = true;
                                                    }
                                                  },
                                                ),
                                              )
                                            : Icon(
                                                Icons.chevron_right_outlined,
                                                size: 30.w,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                              ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    const Divider(
                                      height: 0,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      if (userrole == "Member")
                      BlocProvider(
                        create: (context) => RequestRoleBloc(),
                        child: BlocListener<RequestRoleBloc, RequestRoleState>(
                          listener: (context, state) {
                            if (state is RequestRoleSuccess) {
                              showCustomDialogModal(
                                context: navigatorKey.currentContext!,
                                textDesc: "Request lên Admin thành công",
                                title: "Thông báo",
                                colorButtonOk: Colors.green,
                                btnOKText: "Xác nhận",
                                typeDialog: "success",
                                eventButtonOKPress: () {},
                                isTwoButton: false,
                              );
                            } else if (state is RequestRoleFailure) {
                              showDialog(
                                context: navigatorKey.currentContext!,
                                builder: (BuildContext context) {
                                  return ErrorDialog(
                                    eventConfirm: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              );
                              log('Request Role Failure: ${state.message}');
                            }
                          },
                          child: BlocBuilder<RequestRoleBloc, RequestRoleState>(
                            builder: (context, state) {
                              return InkWell(
                                onTap: () {
                                  showCustomDialogModal(
                                    context: navigatorKey.currentContext!,
                                    textDesc:
                                        "Bạn có chắc muốn gửi yêu cầu lên Admin?",
                                    title: "Thông báo",
                                    colorButtonOk: Colors.blue,
                                    btnOKText: "Xác nhận",
                                    typeDialog: "question",
                                    eventButtonOKPress: () {
                                      final User? user =
                                          FirebaseAuth.instance.currentUser;
                                      if (user != null) {
                                        context.read<RequestRoleBloc>().add(
                                              RequestRole(
                                                userId: user.uid,
                                                email: user.email ?? '',
                                                roleRequested: 'Admin',
                                              ),
                                            );
                                      }
                                    },
                                    isTwoButton: true,
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.all(10.w),
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: 8.h, bottom: 8.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.r),
                                      color: Colors.blue,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        TextApp(
                                          text: "Request Lên Admin",
                                          color: Colors.white,
                                          fontsize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        SizedBox(width: 5.w),
                                        SizedBox(
                                          width: 30.w,
                                          height: 30.w,
                                          child: const Icon(
                                            Icons.person_add,
                                            color: Colors.white,
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
                      BlocProvider(
                        create: (context) => LogoutBloc(),
                        child: BlocListener<LogoutBloc, LogoutState>(
                          listener: (context, state) {
                            if (state is LogoutSuccess) {
                              navigatorKey.currentContext?.go('/');
                            } else if (state is LogoutFailure) {
                              showCustomDialogModal(
                                  context: navigatorKey.currentContext!,
                                  textDesc: state.errorText ??
                                      'Không thể kết nối đến máy chủ',
                                  title: "Thông báo",
                                  colorButtonOk: Colors.red,
                                  btnOKText: "Xác nhận",
                                  typeDialog: "error",
                                  eventButtonOKPress: () {},
                                  isTwoButton: false);
                            }
                          },
                          child: BlocBuilder<LogoutBloc, LogoutState>(
                            builder: (context, state) {
                              return InkWell(
                                  onTap: () {
                                    showCustomDialogModal(
                                        context: navigatorKey.currentContext!,
                                        textDesc:
                                            "Bạn có chắc muốn đăng xuất ?",
                                        title: "Thông báo",
                                        colorButtonOk: Colors.blue,
                                        btnOKText: "Xác nhận",
                                        typeDialog: "question",
                                        eventButtonOKPress: () {
                                          if (isTurnoffFaceID) {
                                            turnOffFaceID();
                                          } else {
                                            turnOnFaceID();
                                          }
                                          ;
                                          context.read<LogoutBloc>().add(
                                                LogoutButtonPressed(),
                                              );
                                        },
                                        isTwoButton: true);
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(10.w),
                                    child: Container(
                                      // width: 1.sw,
                                      padding: EdgeInsets.only(
                                          top: 8.h, bottom: 8.h),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.r),
                                        color: Colors.red,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 4,
                                            offset: const Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          TextApp(
                                            text: "Đăng xuất",
                                            color: Colors.white,
                                            fontsize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          SizedBox(width: 5.w),
                                          SizedBox(
                                              width: 30.w,
                                              height: 30.w,
                                              child: const Icon(
                                                Icons.logout,
                                                color: Colors.white,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ));
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 35.h,
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is GetInforProfileFailure) {
              return ErrorDialog(
                eventConfirm: () {
                  Navigator.pop(context);
                },
              );
            }
            return Center(
              child: SizedBox(
                width: 250.w,
                height: 250.w,
                child: Lottie.asset('assets/lotties/loading_sentinal.json'),
              ),
            );
          },
        ),
      ),
    );
  }
}
