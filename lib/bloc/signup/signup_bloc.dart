import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'signup_event.dart';
part 'signup_state.dart';

class SignUpBloc extends Bloc<SignupEvent, SignupState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  SignUpBloc() : super(SignupInitial()) {
    on<SignupButtonPressed>(_onSignupButtonPressed);
  }

  Future<void> _onSignupButtonPressed(
    SignupButtonPressed event,
    Emitter<SignupState> emit,
  ) async {
    emit(SignupLoading()); // Bắt đầu loading

    try {
      // Tạo người dùng với email và mật khẩu
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );


      // Lưu thông tin người dùng vào Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': event.email,
        'contactName': event.contactName,
        'phoneNumber': event.phoneNumber,
        'role': event.role,
        'profileImage': event.profileImage,
        'createdAt': DateTime.now(),
      });

      // Đăng ký thành công
      emit(SignupSuccess(userCredential.user!.uid, message: 'Đăng ký thành công!'));
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi đăng ký
      emit(SignupFailure('Đăng ký thất bại', errorDetails: e.message));
    } catch (e) {
      // Xử lý các lỗi khác
      emit(SignupFailure('Đã xảy ra lỗi không xác định', errorDetails: e.toString()));
    }
  }
}