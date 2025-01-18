import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'change_password_event.dart';
part 'change_password_state.dart';

class ChangePasswordBloc extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChangePasswordBloc() : super(HandleChangePasswordStateInitial()) {
    on<HandleChangePassword>(_onHandleChangePassword);
  }

  Future<void> _onHandleChangePassword(
    HandleChangePassword event,
    Emitter<ChangePasswordState> emit,
  ) async {
    emit(HandleChangePasswordStateLoading());

    try {
      // Kiểm tra mật khẩu mới và xác nhận mật khẩu mới có khớp nhau không
      if (event.newPassword != event.confirmNewPassword) {
        emit(HandleChangePasswordStateFailure(
          message: 'Mật khẩu mới và xác nhận mật khẩu không khớp.',
        ));
        return;
      }

      // Lấy người dùng hiện tại
      final User? user = _auth.currentUser;

      if (user == null) {
        emit(HandleChangePasswordStateFailure(
          message: 'Người dùng chưa đăng nhập.',
        ));
        return;
      }

      // Xác thực mật khẩu cũ
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: event.oldPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Đổi mật khẩu mới
      await user.updatePassword(event.newPassword);

      emit(HandleChangePasswordStateSuccess(
        message: 'Đổi mật khẩu thành công.',
      ));
    } on FirebaseAuthException catch (e) {
      emit(HandleChangePasswordStateFailure(
        message: 'Lỗi: ${e.message}',
      ));
    } catch (e) {
      emit(HandleChangePasswordStateFailure(
        message: 'Đã xảy ra lỗi không xác định.',
      ));
    }
  }
}