import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
part 'list_user_event.dart';
part 'list_user_state.dart';

class ListUserBloc extends Bloc<ListUserEvent, ListUserState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ListUserBloc() : super(ListUserStateInitial()) {
    on<FetchListUser>(_onFetchListUser);
    on<LoadMoreListUser>(_onLoadMoreListUser);
  }

  Future<void> _onFetchListUser(
  FetchListUser event,
  Emitter<ListUserState> emit,
) async {
  emit(ListUserStateLoading());

  try {
    final querySnapshot = await _firestore.collection('users').limit(10).get();

    // Thêm Document ID vào dữ liệu của mỗi user
    final users = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>; // Lấy dữ liệu từ DocumentSnapshot
      data['id'] = doc.id; // Thêm Document ID vào dữ liệu
      return data;
    }).toList();

    emit(ListUserStateSuccess(
      data: users,
      page: 1,
      hasReachedMax: users.length < 10,
    ));
  } catch (error) {
    emit(ListUserStateFailure(message: error.toString()));
  }
}

  Future<void> _onLoadMoreListUser(
    LoadMoreListUser event,
    Emitter<ListUserState> emit,
  ) async {
    if (state is ListUserStateSuccess &&
        !(state as ListUserStateSuccess).hasReachedMax) {
      final currentState = state as ListUserStateSuccess;

      try {
        // Lấy DocumentSnapshot của document cuối cùng trong danh sách hiện tại
        final lastDocument = await _firestore
            .collection('users')
            .doc(currentState.data.last['id'])
            .get();

        // Sử dụng lastDocument để load thêm dữ liệu
        final querySnapshot = await _firestore
            .collection('users')
            .limit(10)
            .startAfterDocument(lastDocument) // Sử dụng DocumentSnapshot
            .get();

        final users = querySnapshot.docs.map((doc) => doc.data()).toList();

        emit(users.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : ListUserStateSuccess(
                data: currentState.data + users,
                page: currentState.page + 1,
                hasReachedMax: users.length < 10,
              ));
      } catch (error) {
        emit(ListUserStateFailure(message: error.toString()));
      }
    }
  }
}
