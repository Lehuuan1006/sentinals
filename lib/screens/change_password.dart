import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinal/bloc/change_password/change_password_bloc.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/utils/stogares.dart';
import 'package:sentinal/widgets/button_app.dart';
import 'package:sentinal/widgets/custom_dialog.dart';
import 'package:sentinal/widgets/custom_form.dart';
import 'package:sentinal/widgets/text_app.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formField1 = GlobalKey<FormState>();
  final _formField2 = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {};

  bool currentPasswordVisible = true;
  bool newPasswordVisible = true;
  bool confirmNewPasswordVisible = true;
  bool controller2FAEnabled = false;

  void initializeControllers(List<String> keys) {
    for (var key in keys) {
      controllers[key] = TextEditingController();
    }
  }

  void handleChangePassword() {
    context.read<ChangePasswordBloc>().add(HandleChangePassword(
        userID: FirebaseAuth.instance.currentUser!.uid,
        oldPassword: controllers['currentPassword']!.text,
        newPassword: controllers['newPassword']!.text,
        confirmNewPassword: controllers['confirmNewPasword']!.text));
    StorageUtils.instance.removeKey(key: 'email_login_autofill');
    StorageUtils.instance.removeKey(key: 'password_login_autofill');
  }



  void RemoveKey() {
    StorageUtils.instance.removeKey(key: 'token');
    StorageUtils.instance.removeKey(key: 'branch_response');
    StorageUtils.instance.removeKey(key: 'user_ID');
    StorageUtils.instance.removeKey(key: 'user_position');
    StorageUtils.instance.removeKey(key: 'isEditOrderPickup');
    StorageUtils.instance.removeKey(key: 'isUpdateMotification');
    StorageUtils.instance.removeKey(key: 'isEditShipment');
    StorageUtils.instance.removeKey(key: 'isCanScan');
    StorageUtils.instance.removeKey(key: 'isCreateTicket');
    StorageUtils.instance.removeKey(key: 'isEditDebit');
    StorageUtils.instance.removeKey(key: 'isPrintKIKI');
    String? token = StorageUtils.instance.getString(key: 'token');
    log('Token after removal: $token'); // In ra giá trị của token
  }

  @override
  void initState() {
    super.initState();
    initializeControllers([
      'currentPassword',
      'newPassword',
      'confirmNewPasword',
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    controllers.forEach((key, controller) {
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? user_position =
        StorageUtils.instance.getString(key: 'user_position');
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black, //change your color here
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: TextApp(
            text: "Thay đổi mật khẩu",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            
            BlocListener<ChangePasswordBloc, ChangePasswordState>(
              listener: (context, state) {
                if (state is HandleChangePasswordStateSuccess) {
                  RemoveKey();
                  showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                  Future.delayed(const Duration(seconds: 2), () {
                    context.go('/'); // Điều hướng đến trang chính
                  });
                } else if (state is HandleChangePasswordStateFailure) {
                  showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.message,
                    title: "Thông báo",
                    colorButtonOk: Colors.red,
                    btnOKText: "Xác nhận",
                    typeDialog: "error",
                    eventButtonOKPress: () {},
                    isTwoButton: false,
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<ChangePasswordBloc, ChangePasswordState>(
            builder: (context, state) {
              return SafeArea(
                  child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    children: [
                      Form(
                          key: _formField1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r),
                              color: Colors.white,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "CÀI ĐẶT MẬT KHẨU",
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontFamily: "Icomoon",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.sp,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 10.w,
                                    ),
                                    Expanded(
                                      child: Divider(
                                        height: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextApp(
                                      text: " Mật khẩu cũ",
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    CustomTextFormField(
                                      controller:
                                          controllers['currentPassword']!,
                                      hintText: 'Nhập mật khẩu cũ',
                                      isPassword:
                                          true, // Enable password behavior
                                      passwordVisible:
                                          false, // Password visibility initial state
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          return null;
                                        } else {
                                          return "Vui lòng điền mật khẩu hiện tại";
                                        }
                                      },
                                      opacityHintText: 0.5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextApp(
                                      text: " Mật khẩu mới",
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    CustomTextFormField(
                                      controller: controllers['newPassword']!,
                                      hintText: 'Nhập mật khẩu mới',
                                      isPassword:
                                          true, // Enable password behavior
                                      passwordVisible:
                                          false, // Password visibility initial state
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          if (value.length < 8) {
                                            return "Mật khẩu phải ít nhất 8 kí tự";
                                          }
                                          return null;
                                        } else {
                                          return "Mật khẩu không được để trống";
                                        }
                                      },
                                      opacityHintText: 0.5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextApp(
                                      text: " Xác nhận mật khẩu mới",
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                    SizedBox(
                                      height: 10.h,
                                    ),
                                    CustomTextFormField(
                                      controller:
                                          controllers['confirmNewPasword']!,
                                      hintText: 'Nhập mật lại khẩu mới',
                                      isPassword:
                                          true, // Enable password behavior
                                      passwordVisible:
                                          false, // Password visibility initial state
                                      validator: (value) {
                                        if (value != null && value.isNotEmpty) {
                                          if (value !=
                                              controllers['newPassword']!
                                                  .text) {
                                            return "Mật khẩu xác nhận không khớp!";
                                          } else {
                                            return null;
                                          }
                                        } else {
                                          return "Xác nhận mật khẩu không được để trống";
                                        }
                                      },
                                      opacityHintText: 0.5,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 20.h,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ButtonApp(
                                      text: 'Đổi Mật Khẩu',
                                      fontsize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      colorText: Theme.of(context)
                                          .colorScheme
                                          .background,
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary,
                                      outlineColor:
                                          Theme.of(context).colorScheme.primary,
                                      event: () {
                                        if (_formField1.currentState!
                                            .validate()) {
                                          handleChangePassword();
                                        }
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          )),
                      SizedBox(
                        height: 10.h,
                      ),
                    ],
                  ),
                ),
              ));
            },
          ),
        ));
  }
}
