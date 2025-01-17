import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sentinal/utils/stogares.dart';

part 'logout_event.dart';
part 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  LogoutBloc() : super(LogoutInitial()) {
    on<LogoutButtonPressed>(_onLogoutButtonPressed);
  }

  Future<void> _onLogoutButtonPressed(LogoutButtonPressed event, Emitter<LogoutState> emit) async {
    emit(LogoutInProgress());
    try {
      // Đăng xuất khỏi Firebase Authentication
      await FirebaseAuth.instance.signOut();

      // Xóa token và userRole khỏi StorageUtils
      await StorageUtils.instance.removeKey(key: 'token');
      await StorageUtils.instance.removeKey(key: 'user_role');

      emit(LogoutSuccess());
    } catch (e) {
      log('Lỗi khi đăng xuất: $e');
      emit(LogoutFailure('Đăng xuất thất bại: $e'));
    }
  }
}