import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

part 'update_infor_profile_event.dart';
part 'update_infor_profile_state.dart';


class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UpdateProfileBloc() : super(UpdateProfileInitial()) {
    on<UpdateProfileInfo>(_onUpdateProfileInfo);
  }

  Future<void> _onUpdateProfileInfo(
    UpdateProfileInfo event,
    Emitter<UpdateProfileState> emit,
  ) async {
    emit(UpdateProfileLoading()); // Bắt đầu loading

    try {
      // Tạo một Map chứa các trường cần cập nhật
      final Map<String, dynamic> updateData = {};

      if (event.contactName != null) {
        updateData['contactName'] = event.contactName;
      }
      if (event.phoneNumber != null) {
        updateData['phoneNumber'] = event.phoneNumber;
      }
      if (event.profileImage != null) {
        updateData['profileImage'] = event.profileImage;
      }
      if (event.role != null) {
        updateData['role'] = event.role;
      }

      // Cập nhật thông tin người dùng lên Firestore
      await _firestore.collection('users').doc(event.userId).update(updateData);

      // Phát ra trạng thái thành công với thông báo
      emit(UpdateProfileSuccess('Cập nhật thông tin thành công!'));
      log('Profile updated successfully for userId: ${event.userId}');
    } catch (e) {
      // Phát ra trạng thái thất bại với thông báo lỗi
      emit(UpdateProfileFailure('Lỗi khi cập nhật thông tin: $e'));
      log('UpdateProfileFailure: $e');
    }
  }
}
