import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:sentinal/bloc/signin/signin_bloc.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/utils/stogares.dart';
import 'package:sentinal/widgets/button_app.dart';
import 'package:sentinal/widgets/custom_dialog.dart';
import 'package:sentinal/widgets/custom_form.dart';
import 'package:sentinal/widgets/text_app.dart';

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userController = TextEditingController();
  final passwordController = TextEditingController();
  final _formSignInKey = GlobalKey<FormState>();
  _SupportState _supportState = _SupportState.unknown;
  final LocalAuthentication auth = LocalAuthentication();
  String imageBiometric = 'assets/svg/face_ID.svg';
  String _authorized = 'Chưa xác thực';
  bool _isAuthenticating = false;

  bool rememberPassword = true;
  bool policy = true;
  bool passwordVisible = false;
  bool agreeWithCondition = true;

  @override
  void dispose() {
    super.dispose();
    userController.clear();
    passwordController.clear();
  }

  @override
  void initState() {
    super.initState();
    checkDevice();
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
  }

  void checkDevice() {
    if (!mounted) {
      return;
    }
    if (Platform.isAndroid) {
      setState(() {
        imageBiometric = 'assets/svg/android_fingerprint.svg';
      });
    } else if (Platform.isIOS) {
      setState(() {
        imageBiometric = 'assets/svg/face_ID.svg';
      });
    }
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    final List<BiometricType> availableBiometrics =
        await auth.getAvailableBiometrics();

    if (availableBiometrics.isNotEmpty) {
      // Some biometrics are enrolled.
      log("TYPE Biometric isNotEmpty");
    }
    if (availableBiometrics.contains(BiometricType.strong)) {
      log("TYPE Biometric strong");
    }
    if (availableBiometrics.contains(BiometricType.face)) {
      log("TYPE Biometric face");
      if (!mounted) {
        return;
      }
      if (Platform.isAndroid) {
        setState(() {
          imageBiometric = 'assets/svg/android_face.svg';
        });
      } else if (Platform.isIOS) {
        setState(() {
          imageBiometric = 'assets/svg/face_ID.svg';
        });
      }
    }
    if (availableBiometrics.contains(BiometricType.fingerprint)) {
      log("TYPE Biometric fingerprint");
      if (!mounted) {
        return;
      }
      if (Platform.isAndroid) {
        setState(() {
          imageBiometric = 'assets/svg/android_fingerprint.svg';
        });
      } else if (Platform.isIOS) {
        setState(() {
          imageBiometric = 'assets/svg/touch_ID.svg';
        });
      }
    }
    try {
      mounted
          ? setState(() {
              _isAuthenticating = true;
              _authorized = 'Đang xác thực';
            })
          : null;
      authenticated = await auth.authenticate(
        localizedReason: 'Xác thực danh tính của bạn',
        options: const AuthenticationOptions(
          stickyAuth: true,
        ),
      );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      mounted
          ? setState(() {
              _isAuthenticating = false;
              _authorized = 'Error - ${e.message}';
            })
          : null;
      return;
    }
    if (!mounted) {
      return;
    }

    setState(() =>
        _authorized = authenticated ? 'Đã xác thực' : 'Xác thực thất bại');
        log('authenticated: $authenticated');
    if (authenticated) {
      final String emailSaved =
          StorageUtils.instance.getString(key: 'email_login_autofill')!;
      final String passwordSaved =
          StorageUtils.instance.getString(key: 'password_login_autofill')!;

      context.read<SignInBloc>().add(
            SignInButtonPressed(
              email: emailSaved,
              password: passwordSaved,
            ),
          );
    } else {
      log("Authentication failed");
    }
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
                  padding: EdgeInsets.only(left: 15.w, right: 15.w),
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
                      _supportState == _SupportState.supported
                          ? SizedBox(
                              width: 1.sw,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                        height: 50.h,
                                        child: ButtonApp(
                                          text: 'Đăng nhập',
                                          fontsize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          colorText: Theme.of(context)
                                              .colorScheme
                                              .background,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          outlineColor: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          event: () {
                                            if (_formSignInKey.currentState!
                                                    .validate() &&
                                                agreeWithCondition) {
                                              final username =
                                                  userController.text;
                                              final password =
                                                  passwordController.text;
                                              context.read<SignInBloc>().add(
                                                    SignInButtonPressed(
                                                      email: username,
                                                      password: password,
                                                    ),
                                                  );
                                            } else if (!agreeWithCondition) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                    content: Text(
                                                        'Vui lòng tuân thủ điều khoản của SENTINAL')),
                                              );
                                            }
                                          },
                                        )),
                                  ),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      final String? emailSaved =
                                          StorageUtils.instance.getString(
                                              key: 'email_login_autofill');
                                      final String? passwordSaved =
                                          StorageUtils.instance.getString(
                                              key: 'password_login_autofill');
                                      if (emailSaved != null &&
                                          passwordSaved != null) {
                                        _authenticate();
                                      } else {
                                        showCustomDialogModal(
                                            context:
                                                navigatorKey.currentContext!,
                                            textDesc:
                                                "Bạn cần đăng nhập trước để có thể mở tính năng này",
                                            title: "Thông báo",
                                            colorButtonOk: Colors.blue,
                                            btnOKText: "Xác nhận",
                                            typeDialog: "info",
                                            eventButtonOKPress: () {},
                                            isTwoButton: false);
                                      }
                                    },
                                    child: SizedBox(
                                      width: 50.h,
                                      height: 50.h,
                                      child: SvgPicture.asset(
                                        imageBiometric,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          : SizedBox(
                              width: 1.sw,
                              height: 50.h,
                              child: ButtonApp(
                                text: 'Đăng nhập',
                                fontsize: 16.sp,
                                fontWeight: FontWeight.bold,
                                colorText:
                                    Theme.of(context).colorScheme.background,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                outlineColor:
                                    Theme.of(context).colorScheme.primary,
                                event: () {
                                  if (_formSignInKey.currentState!.validate() &&
                                      agreeWithCondition) {
                                    final username = userController.text;
                                    final password = passwordController.text;
                                    context.read<SignInBloc>().add(
                                          SignInButtonPressed(
                                            email: username,
                                            password: password,
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
                              )),
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
