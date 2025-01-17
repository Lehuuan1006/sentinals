import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'get_infor_profile_event.dart';
part 'get_infor_profile_state.dart';

class GetInforProfileBloc
    extends Bloc<GetInforProfileEvent, GetInforProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GetInforProfileBloc() : super(GetInforProfileInitial()) {
    on<GetProfileInfo>(_onGetProfileInfo);
  }

  Future<void> _onGetProfileInfo(
    GetProfileInfo event,
    Emitter<GetInforProfileState> emit,
  ) async {
    emit(GetInforProfileLoading()); // Bắt đầu loading
    // log('Fetching profile for userId: ${event.userId}');

    try {
      // Lấy thông tin người dùng từ Firestore
      final userDoc =
          await _firestore.collection('users').doc(event.userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        // log('User Data: $userData');

        // Phát ra trạng thái thành công
        emit(GetInforProfileSuccess(
          contactName: userData['contactName'] as String? ?? '',
          email: userData['email'] as String? ?? '',
          phoneNumber: userData['phoneNumber'] as String? ?? '',
          profileImage: userData['profileImage'] as String? ?? '',
          role: userData['role'] as String? ?? '',
        ));
      } else {
        emit(GetInforProfileFailure('Người dùng không tồn tại'));
        log('GetInforProfileFailure 1: User document does not exist for userId: ${event.userId}');
      }
    } catch (e) {
      // Phát ra trạng thái thất bại nếu có lỗi
      emit(GetInforProfileFailure('Lỗi khi lấy thông tin: $e'));
      log('GetInforProfileFailure 2: $e');
    }
  }
}
