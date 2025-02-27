import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:sentinal/bloc/get_infor_profile/get_infor_profile_bloc.dart';
import 'package:sentinal/bloc/home/home_bloc.dart';
import 'package:sentinal/bloc/logout/logout_bloc.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/screens/camera.dart';
import 'package:sentinal/screens/device_manager.dart';
import 'package:sentinal/screens/list_user_request_role_screen.dart';
import 'package:sentinal/screens/notifications.dart';
import 'package:sentinal/screens/users_manager_screen.dart';
import 'package:sentinal/screens/users_request_delete_screen.dart';
import 'package:sentinal/utils/stogares.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sentinal/widgets/button_app.dart';
import 'package:sentinal/widgets/chart_home.dart';
import 'dart:developer';

import 'package:sentinal/widgets/custom_dialog.dart';
import 'package:sentinal/widgets/text_app.dart';
import 'package:sentinal/widgets/title_menu_home.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<double> _opacity = ValueNotifier<double>(1.0);
  final ScrollController _scrollController = ScrollController();
  final CarouselSliderController _controller = CarouselSliderController();

  String? userRole;
  String? contactName;
  String? role;
  bool isShowDashBoard = false;
  int _currentIndex = 0;
  int memberCount = 0;
  int adminCount = 0;
  String? profileImage; // Chuỗi base64
  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    init();
    _scrollController.addListener(_onScroll);
    countUsers();
    super.initState();
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    double newOpacity = 1.0 - (offset / 200.0);
    if (newOpacity < 0.0) newOpacity = 0.0;
    if (newOpacity > 1.0) newOpacity = 1.0;
    _opacity.value = newOpacity;
  }

  void init() async {
    BlocProvider.of<HomeBloc>(context).add(
      HomeScreenButtonPressed(),
    );
    await getInforUser();
  }

  Future<void> getInforUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? userId = user?.uid;

    if (userId != null && userId.isNotEmpty) {
      context.read<GetInforProfileBloc>().add(GetProfileInfo(userId: userId));
    } else {
      log('User ID is null or empty');
    }
  }

  void handleItemTap(int index) {
    switch (index) {
      case 0:
        vibrate();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageUser()),
        );

        break;
      case 1:
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CameraScreen()),
        );
        break;
      case 2:
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeviceManager()),
        );
        break;
      case 3:
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const ManageUserRequestDelete()),
        );
        break;
      case 4:
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ManageUser()),
        );
        break;
      case 5:
        vibrate();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeviceManager()),
        );

        break;
      case 6:
        vibrate();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DeviceManager()),
        );

        break;
      case 7:
        vibrate();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ListUserRequestRoleScreen()),
        );
        break;
    }
  }

  Future<void> countUsers() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Đếm số lượng Member
    QuerySnapshot membersSnapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: 'Member')
        .get();

    // Đếm số lượng Admin
    QuerySnapshot adminsSnapshot = await firestore
        .collection('users')
        .where('role', isEqualTo: 'Admin')
        .get();

    // Cập nhật trạng thái
    setState(() {
      memberCount = membersSnapshot.size;
      adminCount = adminsSnapshot.size;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
  }

  void vibrate() {
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? userRole = StorageUtils.instance.getString(key: 'user_role');
    return Scaffold(
      backgroundColor: Colors.white,
      body:
          // Sử dụng MultiBlocListener để lắng nghe cả LogoutBloc và GetInforProfileBloc
          MultiBlocListener(
        listeners: [
          BlocListener<GetInforProfileBloc, GetInforProfileState>(
            listener: (context, state) {
              if (state is GetInforProfileSuccess) {
                setState(() {
                  contactName = state.contactName;
                  profileImage = state.profileImage;
                  role = state.role;
                });
              }
            },
          ),
        ],
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return Center(
                child: SizedBox(
                  width: 250.w,
                  height: 250.w,
                  child: Lottie.asset('assets/lotties/loading_sentinal.json'),
                ),
              );
            } else if (state is HomeFailure) {
              return AlertDialog(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.w),
                ),
                actionsPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.only(
                    top: 35.w, bottom: 30.w, left: 35.w, right: 35.w),
                titlePadding: EdgeInsets.all(15.w),
                surfaceTintColor: Colors.white,
                backgroundColor: Colors.white,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextApp(
                      text: "CÓ LỖI XẢY RA !",
                      fontsize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 250.w,
                        height: 250.w,
                        child: Lottie.asset('assets/lottie/error_dialog.json',
                            fit: BoxFit.contain),
                      ),
                    ),
                    TextApp(
                      text:
                          "Đã có lỗi xảy ra! \nVui lòng liên hệ quản trị viên.",
                      fontsize: 18.sp,
                      softWrap: true,
                      isOverFlow: false,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Container(
                      width: 150.w,
                      height: 50.h,
                      child: ButtonApp(
                        event: () {
                          StorageUtils.instance.removeKey(key: 'token');
                          navigatorKey.currentContext?.go('/');
                        },
                        text: "Xác nhận",
                        fontsize: 14.sp,
                        colorText: Colors.white,
                        backgroundColor: Colors.black,
                        outlineColor: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is HomeSuccess) {
              return SafeArea(
                child: Stack(
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable: _opacity,
                      builder: (context, opacity, child) {
                        return AnimatedOpacity(
                          opacity: opacity,
                          duration: const Duration(milliseconds: 300),
                          child: Container(
                            decoration: const BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage("assets/images/bg.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    RefreshIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      onRefresh: () async {
                        init();
                      },
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: <Widget>[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(left: 10.w, right: 10.w),
                              child: Container(
                                height: 100.h,
                                color: Colors.transparent,
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Image.asset(
                                            "assets/images/logo_header_bg.png",
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        BlocProvider(
                                          create: (context) => LogoutBloc(),
                                          child: BlocListener<LogoutBloc,
                                              LogoutState>(
                                            listener: (context, state) {
                                              if (state is LogoutSuccess) {
                                                navigatorKey.currentContext
                                                    ?.go('/');
                                              } else if (state
                                                  is LogoutFailure) {
                                                showCustomDialogModal(
                                                  context: navigatorKey
                                                      .currentContext!,
                                                  textDesc: state.errorText ??
                                                      'Không thể kết nối đến máy chủ',
                                                  title: "Thông báo",
                                                  colorButtonOk: Colors.red,
                                                  btnOKText: "Xác nhận",
                                                  typeDialog: "error",
                                                  eventButtonOKPress: () {},
                                                  isTwoButton: false,
                                                );
                                              }
                                            },
                                            child: BlocBuilder<LogoutBloc,
                                                LogoutState>(
                                              builder: (context, state) {
                                                return InkWell(
                                                  onTap: () {
                                                    showCustomDialogModal(
                                                      context: navigatorKey
                                                          .currentContext!,
                                                      textDesc:
                                                          "Bạn có chắc muốn đăng xuất?",
                                                      title: "Thông báo",
                                                      colorButtonOk:
                                                          Colors.blue,
                                                      btnOKText: "Xác nhận",
                                                      typeDialog: "question",
                                                      eventButtonOKPress: () {
                                                        context
                                                            .read<LogoutBloc>()
                                                            .add(
                                                              LogoutButtonPressed(),
                                                            );
                                                      },
                                                      isTwoButton: true,
                                                    );
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.w),
                                                    child: Container(
                                                      padding: EdgeInsets.only(
                                                          left: 5.w,
                                                          right: 5.w),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5.r),
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.grey
                                                                .withOpacity(
                                                                    0.5),
                                                            spreadRadius: 2,
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                    0, 3),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          TextApp(
                                                            text: "Đăng xuất",
                                                            color: Colors.black,
                                                            fontsize: 14.sp,
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
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 50.w,
                                          height: 50.w,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(25.w),
                                            border: Border.all(
                                                width: 2.w,
                                                color: Colors.white),
                                            color: Colors.black,
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30.w),
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
                                        SizedBox(width: 15.w),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                TextApp(
                                                  text: "Xin chào, ",
                                                  color: Colors.black,
                                                  fontsize: 14.sp,
                                                ),
                                                TextApp(
                                                  text: contactName ?? '',
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  fontsize: 14.sp,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 5.w),
                                            TextApp(
                                              text: role ?? '',
                                              color: Colors.black,
                                              fontsize: 14.sp,
                                              maxLines: 2,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // SliverLayoutBuilder(
                          //   builder: (BuildContext context, constraints) {
                          //     final scrolled = constraints.scrollOffset > 0;
                          //     return SliverAppBar(
                          //       shadowColor: Colors.white,
                          //       surfaceTintColor: Colors.white,
                          //       foregroundColor: Colors.white,
                          //       bottom: PreferredSize(
                          //         preferredSize: Size.fromHeight(10.h),
                          //         child: Container(),
                          //       ),
                          //       expandedHeight: 140.h,
                          //       pinned: true,
                          //       floating: false,
                          //       backgroundColor: scrolled
                          //           ? Colors.white
                          //           : Colors.transparent,
                          //       flexibleSpace: Stack(
                          //         children: [
                          //           // Hình nền
                          //           ClipRRect(
                          //             borderRadius: BorderRadius.circular(15.r),
                          //             child: Container(
                          //               margin: EdgeInsets.all(10.w),
                          //               decoration: BoxDecoration(
                          //                   borderRadius:
                          //                       BorderRadius.circular(15.r),
                          //                   color: const Color.fromARGB(
                          //                       255, 54, 193, 240)
                          //                   // gradient: LinearGradient(
                          //                   //   colors: [
                          //                   //     Color.fromARGB(255, 111, 248, 248),
                          //                   //     Color.fromARGB(255, 175, 242, 242),
                          //                   //   ],
                          //                   //   begin: Alignment.topLeft,
                          //                   //   end: Alignment.bottomRight,
                          //                   // ),
                          //                   ),
                          //             ),
                          //           ),
                          //           // Các nút chức năng
                          //           Positioned(
                          //             top: 0,
                          //             bottom: 0,
                          //             left: 0,
                          //             right: 0,
                          //             child: Container(
                          //               padding: EdgeInsets.only(
                          //                   top: 30.h,
                          //                   bottom: 30
                          //                       .h), // Điều chỉnh padding trên và dưới
                          //               child: Center(
                          //                 child: Row(
                          //                   mainAxisAlignment:
                          //                       MainAxisAlignment.center,
                          //                   crossAxisAlignment:
                          //                       CrossAxisAlignment.center,
                          //                   children: [
                          //                     _buildActionButton(
                          //                       context: context,
                          //                       scrolled: false,
                          //                       icon: Icons.list,
                          //                       label: "List Users",
                          //                       onTap: () {
                          //                         vibrate();
                          //                         Navigator.push(
                          //                           context,
                          //                           MaterialPageRoute(
                          //                             builder: (context) =>
                          //                                 ManageUser(),
                          //                           ),
                          //                         );
                          //                       },
                          //                     ),
                          //                     SizedBox(width: 20.w),
                          //                     _buildActionButton(
                          //                       context: context,
                          //                       scrolled: false,
                          //                       icon:
                          //                           Icons.access_alarm_outlined,
                          //                       label: "Test",
                          //                       onTap: () {
                          //                         vibrate();
                          //                         Navigator.push(
                          //                           context,
                          //                           MaterialPageRoute(
                          //                             builder: (context) =>
                          //                                 ListUserRequestRoleScreen(),
                          //                           ),
                          //                         );
                          //                       },
                          //                     ),
                          //                     SizedBox(width: 20.w),
                          //                     _buildActionButton(
                          //                       context: context,
                          //                       scrolled: false,
                          //                       icon: Icons.camera,
                          //                       label: "Testt",
                          //                       onTap: () {
                          //                         vibrate();
                          //                         Navigator.push(
                          //                           context,
                          //                           MaterialPageRoute(
                          //                             builder: (context) =>
                          //                                 const ListUserScreen(),
                          //                           ),
                          //                         );
                          //                       },
                          //                     ),
                          //                     SizedBox(width: 20.w),
                          //                     _buildActionButton(
                          //                       context: context,
                          //                       scrolled: false,
                          //                       icon: Icons.info,
                          //                       label: "Testtt",
                          //                       onTap: () {
                          //                         vibrate();
                          //                         Navigator.push(
                          //                           context,
                          //                           MaterialPageRoute(
                          //                             builder: (context) =>
                          //                                 const ManageUserRequestDelete(),
                          //                           ),
                          //                         );
                          //                       },
                          //                     ),
                          //                   ],
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     );
                          //   },
                          // ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => Column(
                                children: [
                                  SizedBox(
                                    height: 20.h,
                                  ),
                                  Container(
                                    width: 1.sw,
                                    child: Column(
                                      children: [
                                        CarouselSlider(
                                          carouselController: _controller,
                                          options: CarouselOptions(
                                            aspectRatio: 2.0,
                                            viewportFraction: 1,
                                            enlargeCenterPage: true,
                                            enableInfiniteScroll: false,
                                            onPageChanged: (index, reason) {
                                              setState(() {
                                                _currentIndex = index;
                                              });
                                            },
                                          ),
                                          items: [
                                            //Tab Menu Tab 1
                                            GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    4, // Number of columns
                                                crossAxisSpacing: 4.0,
                                                mainAxisSpacing: 4.0,
                                              ),
                                              itemCount: iconListMiniMenuTab1
                                                  .length, // Number of items in the grid
                                              itemBuilder: (context, index) {
                                                return InkWell(
                                                  onTap: () {
                                                    handleItemTap(index);
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: 40.w,
                                                        height: 40.w,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.r),
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                        child: Center(
                                                          child: Icon(
                                                            size: 22.sp,
                                                            iconListMiniMenuTab1[
                                                                index],
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 5.h,
                                                      ),
                                                      SizedBox(
                                                        width: 75.w,
                                                        child: TextApp(
                                                          isOverFlow: false,
                                                          softWrap: true,
                                                          textAlign:
                                                              TextAlign.center,
                                                          text:
                                                              titleMiniMenuTab1[
                                                                  index],
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontsize: 12.sp,
                                                          color: Colors.black,
                                                          maxLines: 3,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),

                                  Padding(
                                    padding: EdgeInsets.all(20.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextApp(
                                              text: "Biểu đồ tổng quan",
                                              fontWeight: FontWeight.bold,
                                              fontsize: 16.sp,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 20.w, right: 20.w),
                                    child: Divider(
                                      height: 1,
                                      color: Colors.black,
                                    ),
                                  ),
                                  // isShowDashBoard
                                  //     ?
                                  Padding(
                                    padding: EdgeInsets.all(20.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                TextApp(
                                                  text: "Tổng Admin: ",
                                                  fontWeight: FontWeight.bold,
                                                  fontsize: 16.sp,
                                                ),
                                                TextApp(
                                                  text: adminCount.toString(),
                                                  fontsize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                )
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                TextApp(
                                                  text: "Tổng Member: ",
                                                  fontWeight: FontWeight.bold,
                                                  fontsize: 16.sp,
                                                ),
                                                Container(
                                                  width: 70.w,
                                                  child: TextApp(
                                                    text:
                                                        memberCount.toString(),
                                                    fontsize: 16.sp,
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  UserRegistrationChart(),
                                  SizedBox(
                                    height: 30.h,
                                  ),
                                ],
                              ),
                              childCount: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return AlertDialog(
                clipBehavior: Clip.antiAliasWithSaveLayer,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.w),
                ),
                actionsPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.only(
                    top: 35.w, bottom: 30.w, left: 35.w, right: 35.w),
                titlePadding: EdgeInsets.all(15.w),
                surfaceTintColor: Colors.white,
                backgroundColor: Colors.white,
                //
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: SizedBox(
                        width: 250.w,
                        height: 250.w,
                        child: Lottie.asset('assets/lotties/error_dialog.json',
                            fit: BoxFit.contain),
                      ),
                    ),
                    TextApp(
                      text: "Hết phiên đăng nhập \nVui lòng đăng nhập lại.",
                      fontsize: 18.sp,
                      softWrap: true,
                      isOverFlow: false,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Container(
                      width: 150.w,
                      height: 50.h,
                      child: ButtonApp(
                        event: () {
                          StorageUtils.instance.removeKey(key: 'token');
                          navigatorKey.currentContext?.go('/');
                        },
                        text: "Xác nhận",
                        fontsize: 14.sp,
                        colorText: Colors.white,
                        backgroundColor: Colors.black,
                        outlineColor: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

Widget _buildActionButton({
  required BuildContext context,
  required bool scrolled,
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25.w),
            color:
                scrolled ? Theme.of(context).colorScheme.primary : Colors.white,
          ),
          child: Center(
            child: Icon(
              icon,
              size: 28.sp,
              color: scrolled ? Colors.white : Colors.black,
            ),
          ),
        ),
        SizedBox(height: 5.h),
        !scrolled
            ? TextApp(
                text: label,
                fontWeight: FontWeight.bold,
                fontsize: 14.sp,
                color: scrolled ? Colors.black : Colors.white,
              )
            : Container(),
      ],
    ),
  );
}
