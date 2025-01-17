import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:sentinal/bloc/signin/signin_bloc.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/utils/stogares.dart';
import 'package:sentinal/widgets/button_app.dart';
import 'package:sentinal/widgets/custom_dialog.dart';
import 'package:sentinal/widgets/custom_form.dart';
import 'package:sentinal/widgets/text_app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final _formSignInKey = GlobalKey<FormState>();

  bool rememberPassword = true;
  bool policy = true;
  bool passwordVisible = false;
  bool agreeWithCondition = true;

  Future<void> handleLogin() async {
    // BlocProvider.of<SignInBloc>(context).add(
    //   SignInButtonPressed(
    //     email: userController.text,
    //     password: passwordController.text,
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: BlocConsumer<SignInBloc, SignInState>(
          listener: (context, state) {
            if (state is SignInSuccess) {
              Future.delayed(const Duration(milliseconds: 300), () {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: "Đăng nhập thành công",
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              });
              context.go('/home');
            } else if (state is SignInFailure) {
              showCustomDialogModal(
                  context: navigatorKey.currentContext!,
                  textDesc: 'Sai mật khẩu',
                  title: "Thông báo",
                  colorButtonOk: Colors.red,
                  btnOKText: "Xác nhận",
                  typeDialog: "error",
                  eventButtonOKPress: () {},
                  isTwoButton: false);
            }
          },
          builder: (context, state) {
            if (state is SignInLoading) {
              return Center(
                child: SizedBox(
                  width: 250.w,
                  height: 250.w,
                  child: Lottie.asset('assets/lotties/loading_sentinal.json'),
                ),
              );
            }
            return SafeArea(
                child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Form(
                key: _formSignInKey,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.w, right: 5.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 100.h,
                      ),
                      SizedBox(
                        width: 280.w,
                        height: 120.w,
                        child: Image.asset('assets/images/logo.png'),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        "Nhập thông tin để đăng nhập",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextApp(
                                  text: "Tài khoản",
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontsize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            CustomTextFormField(
                                controller: userController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập tài khoản';
                                  }
                                  return null;
                                },
                                hintText: 'Nhập tài khoản'),
                            SizedBox(
                              height: 10.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextApp(
                                  text: "Mật khẩu",
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontsize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 5.h,
                            ),
                            CustomTextFormField(
                              controller: passwordController,
                              hintText: 'Nhập mật khẩu',
                              isPassword: true, // Enable password behavior
                              passwordVisible:
                                  false, // Password visibility initial state
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu';
                                }
                                return null;
                              },
                              opacityHintText: 0.5,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                checkColor:
                                    Theme.of(context).colorScheme.background,
                                value: rememberPassword,
                                onChanged: (bool? value) {
                                  if (!mounted) {
                                    return;
                                  }
                                  setState(() {
                                    rememberPassword = value!;
                                  });
                                },
                                activeColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                              Text(
                                'Ghi nhớ đăng nhập',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 1.sw,
                        child: Row(
                          children: [
                            Checkbox(
                              checkColor:
                                  Theme.of(context).colorScheme.background,
                              value: agreeWithCondition,
                              onChanged: (bool? value) {
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  agreeWithCondition = value!;
                                });
                              },
                              activeColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextApp(
                                  text: 'Tuân thủ Điều Khoản của SENTINAL',
                                  fontsize: 14.sp,
                                  isOverFlow: false,
                                  softWrap: true,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ButtonApp(
                        text: 'Đăng nhập',
                        fontsize: 16.sp,
                        fontWeight: FontWeight.bold,
                        colorText: Theme.of(context).colorScheme.background,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        outlineColor: Theme.of(context).colorScheme.primary,
                        event: () {
                          if (_formSignInKey.currentState!.validate() &&
                              agreeWithCondition) {
                            context.read<SignInBloc>().add(
                                  SignInButtonPressed(
                                    email: userController.text,
                                    password: passwordController.text,
                                  ),
                                );
                          } else if (!agreeWithCondition) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Vui lòng tuân thủ điều khoản của SENTINAL')),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Chưa có tài khoản? ",
                              style: TextStyle(color: Colors.black)),
                          InkWell(
                            onTap: () => context.go('/sign_up'),
                            child: Text(
                              "Đăng kí",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontSize: 16.sp),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ));
          },
        ),
      ),
    );
  }
}
