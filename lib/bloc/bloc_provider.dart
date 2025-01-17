import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentinal/bloc/get_infor_profile%20copy/update_infor_profile_bloc.dart';
import 'package:sentinal/bloc/signin/signin_bloc.dart';
import 'package:sentinal/bloc/logout/logout_bloc.dart';
import 'package:sentinal/bloc/get_infor_profile/get_infor_profile_bloc.dart';
import 'package:sentinal/bloc/signup/signup_bloc.dart';

class AppBlocProvider extends StatelessWidget {
  const AppBlocProvider({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SignInBloc()),
        BlocProvider(create: (_) => SignUpBloc()),
        BlocProvider(create: (_) => LogoutBloc()),
        BlocProvider(create: (_) => GetInforProfileBloc()),
        BlocProvider(create: (_) => UpdateProfileBloc()),

      ],
      child: child,
    );
  }
}
