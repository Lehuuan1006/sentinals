import 'dart:io';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sentinal/screens/camera.dart';
import 'package:sentinal/screens/home.dart';
import 'package:sentinal/screens/list_user.dart';
import 'package:sentinal/screens/notifications.dart';
import 'package:sentinal/screens/profile_user.dart';
import 'package:sentinal/screens/users_manager_screen.dart';
import 'package:sentinal/utils/stogares.dart';
import 'package:sentinal/widgets/custom_dialog.dart';
import 'package:sentinal/widgets/text_app.dart';

class IndexHome extends StatefulWidget {
  const IndexHome({super.key});

  @override
  State<IndexHome> createState() => _IndexHomeState();
}

class _IndexHomeState extends State<IndexHome> {
  int _selectedIndex = 0;

  List<IconData> iconList = [
    Icons.home,
    Icons.camera,
    Icons.notifications,
    Icons.person
  ];
  List<String> titleBottomNav = [
    "Trang chủ",
    "Camera",
    "Thông báo",
    "Cá nhân"
  ];

  String currentTitle = 'Dashboard';
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CameraScreen(),
    NotificationsScreen(),
    ProfileUserScreen()
  ];
  bool isHaveNoti = false;

  void _onItemTapped(int index) {
    vibrate();
    if (mounted) {
      setState(() {
        _selectedIndex = index;
        currentTitle = titleBottomNav[index]; // Cập nhật tiêu đề dựa trên index
      });
    }
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
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.transparent,
        elevation: 0,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageUser()),
          );
        },
        child: Container(
          padding: EdgeInsets.all(5.r),
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30.w),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          child: Container(
            width: 60.w,
            height: 60.w,
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.w),
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Icon(Icons.list, color: Colors.white),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar.builder(
        backgroundColor: Colors.white,
        height: 65.h,
        borderWidth: 1.5.w,
        borderColor: Theme.of(context).colorScheme.surface,
        itemCount: iconList.length,
        tabBuilder: (int index, bool isActive) {
          return Column(
            children: [
              SizedBox(
                height: 10.h,
              ),
              Icon(
                iconList[index],
                size: 24.sp,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.black,
              ),
              TextApp(
                text: titleBottomNav[index],
                fontWeight: FontWeight.bold,
                fontsize: 12.sp,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey,
              ),
            ],
          );
        },
        activeIndex: _selectedIndex,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.smoothEdge,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        onTap: _onItemTapped,
      ),
    );
  }
}