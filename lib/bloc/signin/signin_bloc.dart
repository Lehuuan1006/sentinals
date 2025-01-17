import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentinal/utils/stogares.dart';
import 'package:equatable/equatable.dart';
part 'signin_event.dart';
part 'signin_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SignInBloc() : super(SignInInitial()) {
    on<SignInButtonPressed>(_onSignInButtonPressed);
  }

  Future<void> _onSignInButtonPressed(
    SignInButtonPressed event,
    Emitter<SignInState> emit,
  ) async {
    emit(SignInLoading()); // Bắt đầu loading

    try {
      // Đăng nhập với email và mật khẩu
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      // Lấy token từ Firebase Auth
      final String? token = await userCredential.user?.getIdToken();

      if (token == null) {
        emit(SignInFailure('Không thể lấy token'));
        return;
      }

      // Lưu token vào StorageUtils
      await StorageUtils.instance.setString(key: 'token', val: token);
      log('Token | $token');
      // Lấy thông tin người dùng từ Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        final userRole = userDoc['role'] as String; // Lấy vai trò từ Firestore

        // Lưu vai trò vào StorageUtils
        await StorageUtils.instance.setString(key: 'user_role', val: userRole);

        // Đăng nhập thành công
        emit(SignInSuccess(userId: userCredential.user!.uid, userRole: userRole));
      } else {
        emit(SignInFailure('Người dùng không tồn tại'));
      }
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi đăng nhập
      emit(SignInFailure(e.message ?? 'Đăng nhập thất bại'));
    } catch (e) {
      // Xử lý các lỗi khác
      emit(SignInFailure('Đã xảy ra lỗi không xác định'));
    }
  }
}