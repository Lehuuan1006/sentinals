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
    on<SearchListUser>(
        _onSearchListUser); // Đăng ký trình xử lý sự kiện SearchListUser
  }

  Future<void> _onFetchListUser(
    FetchListUser event,
    Emitter<ListUserState> emit,
  ) async {
    emit(ListUserStateLoading());

    try {
      final querySnapshot =
          await _firestore.collection('users').limit(10).get();

      final users = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
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
        final lastDocument = await _firestore
            .collection('users')
            .doc(currentState.data.last['id'])
            .get();

        Query query = _firestore
            .collection('users')
            .limit(10)
            .startAfterDocument(lastDocument);

        // Áp dụng từ khóa tìm kiếm nếu có
        if (currentState.searchQuery.isNotEmpty) {
          query = query
              .where('role', isGreaterThanOrEqualTo: currentState.searchQuery)
              .where('role', isLessThan: currentState.searchQuery + 'z');
        }

        final querySnapshot = await query.get();

        final users = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        emit(users.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : ListUserStateSuccess(
                data: currentState.data + users,
                page: currentState.page + 1,
                hasReachedMax: users.length < 10,
                searchQuery:
                    currentState.searchQuery, // Giữ nguyên từ khóa tìm kiếm
              ));
      } catch (error) {
        emit(ListUserStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onSearchListUser(
    SearchListUser event,
    Emitter<ListUserState> emit,
  ) async {
    emit(ListUserStateLoading());

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role',
              isGreaterThanOrEqualTo:
                  event.query.toString()) // Chuyển đổi sang String
          .where('role', isLessThan: event.query.toString() + 'z')
          .get();

      final users = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      emit(ListUserStateSuccess(
        data: users,
        page: 1,
        hasReachedMax: users.length < 10,
        searchQuery: event.query, // Lưu từ khóa tìm kiếm
      ));
    } catch (error) {
      log('Error details: $error');
      emit(ListUserStateFailure(message: error.toString()));
    }
  }
}
