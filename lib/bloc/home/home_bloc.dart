import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sentinal/utils/stogares.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeScreenButtonPressed>(_onHomeScreenButtonPressed);
  }

  Future<void> _onHomeScreenButtonPressed(
    HomeScreenButtonPressed event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading()); // Bắt đầu loading

    try {
      // Lấy token từ StorageUtils
      final String? token = await StorageUtils.instance.getString(key: 'token');

      if (token != null && token.isNotEmpty) {
        // Token hợp lệ
        emit(HomeSuccess('Token hợp lệ: $token'));
        log('Home button pressed OK');
      } else {
        // Token không hợp lệ
        emit(HomeFailure('Token không tồn tại hoặc không hợp lệ'));
        log('Home Screen no token');
      }
    } catch (e) {
      // Xử lý lỗi nếu có
      emit(HomeFailure('Lỗi khi kiểm tra token: $e'));
      log('Home Screen error: $e');
    }
  }
}