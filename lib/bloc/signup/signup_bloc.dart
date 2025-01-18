import 'dart:developer';
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
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      log('UserCredential | $userCredential');

      // Chuẩn bị dữ liệu để lưu vào Firestore
      final userData = {
        'email': event.email,
        'contactName': event.contactName,
        'phoneNumber': event.phoneNumber,
        'role': event.role,
        'profileImage': event.profileImage,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      };

      // log("User data to be saved: $userData");

      // Lưu thông tin người dùng vào Firestore
      try {
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(userData);

        log("User data saved successfully to Firestore.");
        emit(SignupSuccess(userCredential.user!.uid,
            message: 'Đăng ký thành công!'));
      } catch (e) {
        log("Error saving user data to Firestore: $e");
        emit(SignupFailure('Lỗi khi lưu thông tin người dùng',
            errorDetails: e.toString()));
      }
    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi đăng ký
      log("FirebaseAuthException: ${e.message}");
      emit(SignupFailure('Đăng ký thất bại', errorDetails: e.message));
    } catch (e) {
      // Xử lý các lỗi khác
      log("Unexpected error: $e");
      emit(SignupFailure('Đã xảy ra lỗi không xác định',
          errorDetails: e.toString()));
    }
  }
}