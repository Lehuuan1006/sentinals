import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentinal/bloc/change_password/change_password_bloc.dart';
import 'package:sentinal/bloc/get_infor_users/get_infor_users_bloc.dart';
import 'package:sentinal/bloc/home/home_bloc.dart';
import 'package:sentinal/bloc/list_user/list_user_bloc.dart';
import 'package:sentinal/bloc/list_user_request_role/list_user_request_role_bloc.dart';
import 'package:sentinal/bloc/request_delete_user/request_delete_user_bloc.dart';
import 'package:sentinal/bloc/list_request_delete_users/request_delete_users_list_bloc.dart';
import 'package:sentinal/bloc/request_role/request_role_bloc.dart';
import 'package:sentinal/bloc/update_infor_profile/update_infor_profile_bloc.dart';
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
        BlocProvider(create: (_) => HomeBloc()),
        BlocProvider(create: (_) => SignInBloc()),
        BlocProvider(create: (_) => SignUpBloc()),
        BlocProvider(create: (_) => LogoutBloc()),
        BlocProvider(create: (_) => GetInforProfileBloc()),
        BlocProvider(create: (_) => GetUsersProfileBloc()),
        BlocProvider(create: (_) => UpdateProfileBloc()),
        BlocProvider(create: (_) => ChangePasswordBloc()),
        BlocProvider(create: (_) => ListUserBloc()),
        BlocProvider(create: (_) => RequestDeleteUserBloc()),
        BlocProvider(create: (_) => RequestDeleteUsersListBloc()),
        BlocProvider(create: (_) => RequestRoleBloc()),
        BlocProvider(create: (_) => ListRoleRequestBloc()),
        BlocProvider(create: (_) => DeleteRoleRequestBloc()),
      ],
      child: child,
    );
  }
}
