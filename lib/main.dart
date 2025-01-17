import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sentinal/bloc/bloc_provider.dart';
import 'package:sentinal/router/index.dart';
import 'package:sentinal/utils/stogares.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Add error handling for StorageUtils initialization
  try {
    await StorageUtils.instance.init();
  } catch (e) {
    // Handle the error appropriately (e.g., show an error message, log the error, etc.)
    log('Error initializing storage: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360,
          690), // Adjust design size to match your UI design reference (width x height)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AppBlocProvider(
          child: MaterialApp.router(
            routerConfig: router, // Ensure your router is properly configured
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
            ),
          ),
        );
      },
    );
  }
}
