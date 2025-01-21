import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
part 'request_delete_users_list_event.dart';
part 'request_delete_users_list_state.dart';


class RequestDeleteUsersListBloc
    extends Bloc<RequestDeleteUserEvent, RequestDeleteUserListState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RequestDeleteUsersListBloc() : super(RequestDeleteUserListStateInitial()) {
    on<FetchRequestDeleteUser>(_onFetchRequestDeleteUser);
    on<LoadMoreRequestDeleteUser>(_onLoadMoreRequestDeleteUser);
    on<SearchRequestDeleteUser>(_onSearchRequestDeleteUser);
  }

  Future<void> _onFetchRequestDeleteUser(
    FetchRequestDeleteUser event,
    Emitter<RequestDeleteUserListState> emit,
  ) async {
    emit(RequestDeleteUserListStateLoading());

    try {
      final querySnapshot =
          await _firestore.collection('request_delete_user').limit(10).get();

      final requests = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      emit(RequestDeleteUserListStateSuccess(
        data: requests,
        page: 1,
        hasReachedMax: requests.length < 10,
      ));
    } catch (error) {
      emit(RequestDeleteUserListStateFailure(message: error.toString()));
    }
  }

  Future<void> _onLoadMoreRequestDeleteUser(
    LoadMoreRequestDeleteUser event,
    Emitter<RequestDeleteUserListState> emit,
  ) async {
    if (state is RequestDeleteUserListStateSuccess &&
        !(state as RequestDeleteUserListStateSuccess).hasReachedMax) {
      final currentState = state as RequestDeleteUserListStateSuccess;

      try {
        final lastDocument = await _firestore
            .collection('request_delete_user')
            .doc(currentState.data.last['id'])
            .get();

        Query query = _firestore
            .collection('request_delete_user')
            .limit(10)
            .startAfterDocument(lastDocument);

        // Áp dụng từ khóa tìm kiếm nếu có
        if (event.query.isNotEmpty) {
          query = query
              .where('email', isGreaterThanOrEqualTo: event.query)
              .where('email', isLessThan: event.query + 'z');
        }

        final querySnapshot = await query.get();

        final requests = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        emit(requests.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : RequestDeleteUserListStateSuccess(
                data: currentState.data + requests,
                page: currentState.page + 1,
                hasReachedMax: requests.length < 10,
                searchQuery: currentState.searchQuery,
              ));
      } catch (error) {
        emit(RequestDeleteUserListStateFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onSearchRequestDeleteUser(
    SearchRequestDeleteUser event,
    Emitter<RequestDeleteUserListState> emit,
  ) async {
    emit(RequestDeleteUserListStateLoading());

    try {
      final querySnapshot = await _firestore
          .collection('request_delete_user')
          .where('email', isNotEqualTo: null)
          .where('email', isGreaterThanOrEqualTo: event.query)
          .where('email', isLessThan: event.query + 'z')
          .get();

      final requests = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      emit(RequestDeleteUserListStateSuccess(
        data: requests,
        page: 1,
        hasReachedMax: requests.length < 10,
        searchQuery: event.query,
      ));
    } catch (error) {
      log('Error details: $error');
      emit(RequestDeleteUserListStateFailure(message: error.toString()));
    }
  }
}
