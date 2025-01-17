import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert'; // Để giải mã base64
import 'dart:typed_data'; // Để chuyển đổi base64 thành Uint8List

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert'; // Để giải mã base64
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:lottie/lottie.dart';
import 'package:sentinal/bloc/get_infor_profile%20copy/update_infor_profile_bloc.dart';
import 'package:sentinal/bloc/get_infor_profile/get_infor_profile_bloc.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/utils/stogares.dart';
import 'package:sentinal/widgets/button_app.dart';
import 'package:sentinal/widgets/custom_dialog.dart';
import 'package:sentinal/widgets/custom_form.dart';
import 'package:sentinal/widgets/text_app.dart'; // Để chuyển đổi base64 thành Uint8List

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formField1 = GlobalKey<FormState>();
  final Map<String, TextEditingController> controllers = {};
  int? currentIndexCity;
  int? currentIndexDistric;
  int? currentIndexWard;
  String? email;
  String? role;
  List cityList = [];
  List districList = [];
  List wardList = [];

  final ImagePicker picker = ImagePicker();

  bool isLoadingButton = false;

  File? selectedImage;
  String? selectedFile;
  void pickImage() async {
    final returndImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returndImage == null) return;
    setState(() {
      selectedImage = File(returndImage.path);
    });
  }

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

  void handleUpdateProfile() async {
    if (_formField1.currentState!.validate()) {
      setState(() {
        isLoadingButton = true;
      });

      // Convert image to base64 if selected
      if (selectedImage != null) {
        Uint8List imageBytes = await selectedImage!.readAsBytes();
        selectedFile = base64Encode(imageBytes);
      }

      // Gửi sự kiện cập nhật thông tin
      context.read<UpdateProfileBloc>().add(
            UpdateProfileInfo(
              userId: FirebaseAuth.instance.currentUser!.uid,
              contactName: controllers['contactName']!.text,
              phoneNumber: controllers['phone']!.text,
              profileImage: selectedFile ?? controllers['profileImage']!.text,
              role: role??controllers['role']!.text,
            ),
          );

      setState(() {
        isLoadingButton = false;
      });
    }
  }

  void initializeControllers(List<String> keys) {
    for (var key in keys) {
      controllers[key] = TextEditingController();
    }
  }

  @override
  void initState() {
    super.initState();
    initializeControllers([
      'contactName',
      'role',
      'phone',
      'profileImage',
    ]);
    init();
  }

  @override
  void dispose() {
    controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Giải mã base64 thành Uint8List để hiển thị hình ảnh
    // Uint8List? imageBytes;
    // if (profileImage != null && profileImage!.isNotEmpty) {
    //   imageBytes = base64Decode(profileImage!);
    // }

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.white,
          shadowColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: TextApp(
            text: "Chỉnh sửa thông tin",
            fontsize: 20.sp,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<GetInforProfileBloc, GetInforProfileState>(
              listener: (context, state) {
                if (state is GetInforProfileSuccess) {
                  setState(() {
                    controllers['contactName']!.text = state.contactName;
                    email = state.email;
                    controllers['phone']!.text = state.phoneNumber;
                    controllers['profileImage']!.text = state.profileImage;
                    role = state.role;
                  });
                }
              },
            ),
            BlocListener<UpdateProfileBloc, UpdateProfileState>(
              listener: (context, state) {
                if (state is UpdateProfileSuccess) {
                  showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc: state.message,
                      title: "Thông báo",
                      colorButtonOk: Colors.green,
                      btnOKText: "Xác nhận",
                      typeDialog: "success",
                      eventButtonOKPress: () {},
                      isTwoButton: false);
                } else if (state is UpdateProfileFailure) {
                  showCustomDialogModal(
                      context: navigatorKey.currentContext!,
                      textDesc: state.message,
                      title: "Thông báo",
                      colorButtonOk: Colors.red,
                      btnOKText: "Xác nhận",
                      typeDialog: "error",
                      eventButtonOKPress: () {},
                      isTwoButton: false);
                }
              },
            ),
          ],
          child: BlocBuilder<GetInforProfileBloc, GetInforProfileState>(
            builder: (context, state) {
              if (state is GetInforProfileSuccess) {
                return SafeArea(
                  child: RefreshIndicator(
                    color: Theme.of(context).colorScheme.primary,
                    onRefresh: () async {
                      init();
                    },
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
                                  child: Padding(
                                    padding: EdgeInsets.all(0.w),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "TÀI KHOẢN",
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
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        Container(
                                          width: 120.w,
                                          height: 120.w,
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(60.r),
                                                child: selectedImage == null
                                                    ? (controllers[
                                                                'profileImage']!
                                                            .text
                                                            .isEmpty)
                                                        ? Image.asset(
                                                            "assets/images/user_avatar.png",
                                                            fit: BoxFit.cover,
                                                          )
                                                        : Container(
                                                            width: 120.w,
                                                            height: 120.w,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          60.r),
                                                              child:
                                                                  Image.memory(
                                                                base64Decode(
                                                                    controllers[
                                                                            'profileImage']!
                                                                        .text),
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          )
                                                    : Container(
                                                        width: 120.w,
                                                        height: 120.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      60.r),
                                                          color: Colors.grey,
                                                        ),
                                                        child: Image.file(
                                                          selectedImage!,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                              ),
                                              Positioned(
                                                bottom: 5.w,
                                                right: 5.w,
                                                child: Container(
                                                  width: 30.h,
                                                  height: 30.h,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.r),
                                                  ),
                                                  child: InkWell(
                                                    onTap: pickImage,
                                                    child: Icon(Icons.camera),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        SizedBox(
                                          width: 1.sw / 2,
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return "Nội dung không được để trống";
                                              } else {
                                                return null;
                                              }
                                            },
                                            onTapOutside: (event) {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                            },
                                            textAlign: TextAlign.center,
                                            controller:
                                                controllers['contactName']!,
                                            style:
                                                TextStyle(color: Colors.black),
                                            decoration: const InputDecoration(
                                              border: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.grey),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 100.w,
                                              child: Text(
                                                "Email: ",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Icomoon",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            Expanded(
                                              child: Text(
                                                email ?? '',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Icomoon",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5.h,
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 100.w,
                                              child: Text(
                                                "Role: ",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Icomoon",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10.w,
                                            ),
                                            Expanded(
                                              child: Text(
                                                role ?? '',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontFamily: "Icomoon",
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14.sp,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "LIÊN LẠC",
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
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextApp(
                                              text: " Số điện thoại",
                                              fontsize: 14.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              height: 10.h,
                                            ),
                                            CustomTextFormField(
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return 'Vui lòng nhập số điện thoại';
                                                  }
                                                  if (value.isEmpty) {
                                                    // return phoneIsRequied;
                                                  }
                                                  bool phoneValid = RegExp(
                                                          r'^(?:[+0]9)?[0-9]{10}$')
                                                      .hasMatch(value);

                                                  if (!phoneValid) {
                                                    return "Số điện thoại không hợp lệ";
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                controller:
                                                    controllers['phone']!,
                                                hintText: '')
                                          ],
                                        ),
                                        SizedBox(
                                          height: 20.h,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            isLoadingButton
                                                ? const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  )
                                                : ButtonApp(
                                                    text: 'Cập nhật',
                                                    fontsize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                    colorText: Theme.of(context)
                                                        .colorScheme
                                                        .background,
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                    outlineColor:
                                                        Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                    event: () {
                                                      if (_formField1
                                                          .currentState!
                                                          .validate()) {
                                                        handleUpdateProfile();
                                                      }
                                                    },
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
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
        ));
  }
}
