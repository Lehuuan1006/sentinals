import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sentinal/screens/home.dart';
import 'package:sentinal/screens/index_home.dart';
import 'package:sentinal/screens/login.dart';
import 'package:sentinal/screens/signup.dart';
import 'package:sentinal/utils/stogares.dart';



// GoRouter configuration
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final router = GoRouter(
  navigatorKey: navigatorKey,
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/sign_up',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const IndexHome(),
    ),
   
  ],
  redirect: (BuildContext context, GoRouterState state) {
    final String? token = StorageUtils.instance.getString(key: 'token');
    if(token != null){
      return '/home';
    } else {
      return null;
    }
    
  },

);