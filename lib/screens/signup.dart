import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;
import 'package:lottie/lottie.dart';
import 'package:sentinal/bloc/signup/signup_bloc.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/widgets/box_alert.dart';
import 'package:sentinal/widgets/button_app.dart';
import 'package:sentinal/widgets/custom_dialog.dart';
import 'package:sentinal/widgets/custom_form.dart';
import 'package:sentinal/widgets/notifyimage.dart';
import 'package:sentinal/widgets/signin_success.dart';
import 'package:sentinal/widgets/text_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Role {
  final String positionName;
  final int positionId;

  Role({required this.positionName, required this.positionId});
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // final userController = TextEditingController();
  // final passwordController = TextEditingController();
  // final passwordConfirmController = TextEditingController();
  final Map<String, TextEditingController> controllers = {};

  final _formSignupKey = GlobalKey<FormState>();
  int? currentRoleIndex;
  bool passwordVisible = false;
  bool passwordConfirmVisible = false;
  String? selectedRole;

  final List<Role> role = [
    Role(positionName: 'Admin', positionId: 1),
    Role(positionName: 'Member', positionId: 2),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initializeControllers([
      'email',
      'password',
      'confirmPassword',
      'role',
      'contactName',
      'phoneNumber',
    ]);
  }

  void initializeControllers(List<String> keys) {
    for (var key in keys) {
      controllers[key] = TextEditingController();
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    selectedImage = null;
  }

  List cityList = [];
  List districtList = [];
  List wardList = [];
  final ImagePicker picker = ImagePicker();

  File? selectedImage;
  String selectedFile = '';
  void pickImage() async {
    final returndImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returndImage == null) return;
    setState(() {
      selectedImage = File(returndImage.path);
    });
  }

  void deleteImage() {
    setState(() {
      selectedImage = null;
    });
  }

  void captureImage() async {
    final XFile? capturedImage =
        await picker.pickImage(source: ImageSource.camera);
    if (capturedImage != null) {
      setState(() {
        selectedImage = File(capturedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => SignUpBloc(),
        child: BlocListener<SignUpBloc, SignupState>(
          listener: (context, state) async {
            if (state is SignupSuccess) {
              navigatorKey.currentContext?.go('/');

              Future.delayed(const Duration(milliseconds: 300), () {
                showCustomDialogModal(
                    context: navigatorKey.currentContext!,
                    textDesc: state.message ?? 'Đăng kí thành công',
                    title: "Thông báo",
                    colorButtonOk: Colors.green,
                    btnOKText: "Xác nhận",
                    typeDialog: "success",
                    eventButtonOKPress: () {},
                    isTwoButton: false);
              });
            } else if (state is SignupFailure) {
              showCustomDialogModal(
                  context: navigatorKey.currentContext!,
                  textDesc:
                      state.errorDetails ?? 'Không thể kết nối đến máy chủ',
                  title: "Thông báo",
                  colorButtonOk: Colors.red,
                  btnOKText: "Xác nhận",
                  typeDialog: "error",
                  eventButtonOKPress: () {},
                  isTwoButton: false);
            }
          },
          child:
              BlocBuilder<SignUpBloc, SignupState>(builder: (context, state) {
            if (state is SignupLoading) {
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
                key: _formSignupKey,
                child: Padding(
                  padding: EdgeInsets.only(left: 5.w, right: 5.w),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      SizedBox(
                        width: 280,
                        height: 120,
                        // color: Colors.amber,
                        child: Image.asset('assets/images/logo.png'),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        "Nhập thông tin để đăng kí",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextApp(
                                  text: "Email",
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
                                keyboardType: TextInputType.emailAddress,
                                controller: controllers['email']!,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập Email';
                                  }
                                  bool emailValid = RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(value);
                                  if (!emailValid) {
                                    return "Email không hợp lệ";
                                  } else {
                                    return null;
                                  }
                                },
                                hintText: 'Nhập email'),
                            SizedBox(
                              height: 20.h,
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
                            // password
                            CustomTextFormField(
                              controller: controllers['password']!,
                              hintText: 'Nhập mật khẩu',
                              isPassword: true, // Enable password behavior
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
                            SizedBox(
                              height: 20.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextApp(
                                  text: "Xác nhận mật khẩu",
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
                              controller: controllers['confirmPassword']!,
                              hintText: 'Nhập mật khẩu',
                              isPassword: true, // Enable password behavior
                              passwordVisible:
                                  false, // Password visibility initial state
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng xác nhận mật khẩu';
                                } else if (value !=
                                    controllers['password']!.text) {
                                  return "Mật khẩu xác nhận không khớp!";
                                } else {
                                  return null;
                                }
                              },
                              opacityHintText: 0.5,
                            ),
                            SizedBox(height: 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextApp(
                                  text: "Tên Liên Hệ",
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
                            // email
                            CustomTextFormField(
                                controller: controllers['contactName']!,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập tên liên hệ';
                                  }
                                  return null;
                                },
                                hintText: 'Nhập tên liên hệ'),
                            SizedBox(
                              height: 15.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextApp(
                                  text: "Điện thoại",
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
                                keyboardType: TextInputType.number,
                                controller: controllers['phoneNumber']!,
                                textInputFormatter: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]")),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Vui lòng nhập số điện thoại';
                                  }

                                  bool phoneValid =
                                      RegExp(r'^(?:[+0]9)?[0-9]{10}$')
                                          .hasMatch(value);

                                  if (!phoneValid) {
                                    return "Số điện thoại không hợp lệ";
                                  } else {
                                    return null;
                                  }
                                },
                                hintText: 'Nhập số điện thoại'),

                            SizedBox(
                              height: 15.h,
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextApp(
                                      text: "Chức vụ",
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
                                  readonly: true,
                                  controller: controllers['role']!,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nội dung không được để trống';
                                    }
                                    return null;
                                  },
                                  hintText: 'Chọn chức vụ',
                                  suffixIcon: Transform.rotate(
                                    angle: 90 * math.pi / 180,
                                    child: Icon(
                                      Icons.chevron_right,
                                      size: 32.sp,
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                  onTap: () {
                                    showMyCustomModalBottomSheet(
                                      context: context,
                                      itemCount: role.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20.w),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    controllers['role']!.text =
                                                        role[index]
                                                            .positionName;
                                                    currentRoleIndex =
                                                        role[index].positionId;
                                                    selectedRole = role[index]
                                                        .positionName;
                                                  });
                                                  log('Selected Role: $selectedRole, ID = ${role[index].positionId}');
                                                },
                                                child: Row(
                                                  children: [
                                                    TextApp(
                                                      text: role[index]
                                                          .positionName,
                                                      color: Colors.black,
                                                      fontsize: 20.sp,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Divider(
                                              height: 25.h,
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                ),
                                SizedBox(
                                  height: 15.h,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Upload ảnh khuôn mặt",
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            selectedImage == null
                                ? DottedBorder(
                                    dashPattern: const [3, 1, 0, 2],
                                    color: Colors.black.withOpacity(0.6),
                                    strokeWidth: 1.5,
                                    padding: const EdgeInsets.all(3),
                                    child: SizedBox(
                                      width: 500,
                                      height: 200,
                                      child: Center(
                                          child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              pickImage();
                                            },
                                            child: Container(
                                                width: 120,
                                                // height: 50.h,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                                child: Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons.collections,
                                                          size: 24,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "Chọn ảnh",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ))),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              captureImage();
                                            },
                                            child: Container(
                                                width: 120,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(8),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.camera,
                                                        size: 24,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        "Chụp ảnh",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                          ),
                                        ],
                                      )),
                                    ),
                                  )
                                : Stack(
                                    children: [
                                      SizedBox(
                                          width: 500,
                                          height: 250,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Image.file(
                                              selectedImage!,
                                              fit: BoxFit.fill,
                                            ),
                                          )),
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: InkWell(
                                          onTap: () {
                                            deleteImage();
                                          },
                                          child: Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              color:
                                                  Colors.white.withOpacity(0.8),
                                            ),
                                            child: Center(
                                                child: Icon(
                                              Icons.close,
                                              size: 20,
                                              color: Colors.black,
                                            )),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            SizedBox(
                              height: 20,
                            ),
                            ButtonApp(
                              text: 'Đăng kí',
                              fontWeight: FontWeight.bold,
                              fontsize: 16,
                              colorText:
                                  Theme.of(context).colorScheme.background,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              outlineColor:
                                  Theme.of(context).colorScheme.primary,
                              event: () async {
                                if (_formSignupKey.currentState!.validate() &&
                                    selectedImage != null) {
                                  Uint8List imagebytes = await selectedImage!
                                      .readAsBytes(); //convert to bytes
                                  String base64string =
                                      base64Encode(imagebytes);
                                  log("nhấn nút đăng kí");
                                  context.read<SignUpBloc>().add(
                                        SignupButtonPressed(
                                          email: controllers['email']!.text,
                                          password:
                                              controllers['password']!.text,
                                          contactName:
                                              controllers['contactName']!.text,
                                          phoneNumber:
                                              controllers['phoneNumber']!.text,
                                          role: selectedRole ?? '',
                                          profileImage: base64string,
                                        ),
                                      );
                                } else if (selectedImage == null) {
                                  showCustomDialogModal(
                                      context: navigatorKey.currentContext!,
                                      textDesc: "Chọn ít nhất một ảnh logo công ty !",
                                      title: "Thông báo",
                                      colorButtonOk: Colors.blue,
                                      btnOKText: "Xác nhận",
                                      typeDialog: "info",
                                      eventButtonOKPress: () {},
                                      isTwoButton: false);
                                  log("chưa chọn ảnh");
                                }
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Đã có tài khoản? ",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                                InkWell(
                                  onTap: () {
                                    context.go('/');
                                  },
                                  child: Text("Đăng nhập",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: const Color.fromARGB(
                                              255, 58, 22, 220))),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
          }),
        ),
      ),
    );
  }
}
