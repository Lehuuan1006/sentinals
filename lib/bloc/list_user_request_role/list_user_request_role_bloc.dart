import 'dart:convert';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
part 'list_user_request_role_event.dart';
part 'list_user_request_role_state.dart';


class ListRoleRequestBloc
    extends Bloc<ListRoleRequestEvent, ListRoleRequestState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ListRoleRequestBloc() : super(ListRoleRequestInitial()) {
    on<FetchRoleRequests>(_onFetchRoleRequests);
    on<LoadMoreRoleRequests>(_onLoadMoreRoleRequests);
    on<SearchRoleRequests>(_onSearchRoleRequests);
  }

  Future<void> _onFetchRoleRequests(
    FetchRoleRequests event,
    Emitter<ListRoleRequestState> emit,
  ) async {
    emit(ListRoleRequestLoading());

    try {
      final querySnapshot = await _firestore
          .collection('role_requests')
          .limit(10)
          .get();

      final requests = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      emit(ListRoleRequestSuccess(
        data: requests,
        page: 1,
        hasReachedMax: requests.length < 10,
      ));
    } catch (error) {
      emit(ListRoleRequestFailure(message: error.toString()));
      log('Error details: $error');
    }
  }

  Future<void> _onLoadMoreRoleRequests(
    LoadMoreRoleRequests event,
    Emitter<ListRoleRequestState> emit,
  ) async {
    if (state is ListRoleRequestSuccess &&
        !(state as ListRoleRequestSuccess).hasReachedMax) {
      final currentState = state as ListRoleRequestSuccess;

      try {
        final lastDocument = await _firestore
            .collection('role_requests')
            .doc(currentState.data.last['id'])
            .get();

        Query query = _firestore
            .collection('role_requests')
            .limit(10)
            .startAfterDocument(lastDocument);

        // Áp dụng từ khóa tìm kiếm nếu có
        if (event.query.isNotEmpty) {
          query = query
              .where('contactName', isGreaterThanOrEqualTo: event.query)
              .where('contactName', isLessThan: event.query + 'z');
        }

        final querySnapshot = await query.get();

        final requests = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();

        emit(requests.isEmpty
            ? currentState.copyWith(hasReachedMax: true)
            : ListRoleRequestSuccess(
                data: currentState.data + requests,
                page: currentState.page + 1,
                hasReachedMax: requests.length < 10,
                searchQuery: currentState.searchQuery,
              ));
      } catch (error) {
        emit(ListRoleRequestFailure(message: error.toString()));
      }
    }
  }

  Future<void> _onSearchRoleRequests(
    SearchRoleRequests event,
    Emitter<ListRoleRequestState> emit,
  ) async {
    emit(ListRoleRequestLoading());

    try {
      final querySnapshot = await _firestore
          .collection('role_requests')
          .where('contactName', isGreaterThanOrEqualTo: event.query)
          .where('contactName', isLessThan: event.query + 'z')
          .get();

      final requests = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      emit(ListRoleRequestSuccess(
        data: requests,
        page: 1,
        hasReachedMax: requests.length < 10,
        searchQuery: event.query,
      ));
    } catch (error) {
      log('Error details: $error');
      emit(ListRoleRequestFailure(message: error.toString()));
    }
  }
}


class DeleteRoleRequestBloc
    extends Bloc<DeleteRoleRequestEvent, DeleteRoleRequestState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DeleteRoleRequestBloc() : super(DeleteRoleRequestInitial()) {
    on<DeleteRoleRequest>(_onDeleteRoleRequest);
  }

  Future<void> _onDeleteRoleRequest(
    DeleteRoleRequest event,
    Emitter<DeleteRoleRequestState> emit,
  ) async {
    emit(DeleteRoleRequestLoading()); // Bắt đầu loading

    try {
      // Xóa request dựa trên requestId
      await _firestore.collection('role_requests').doc(event.requestId).delete();

      // Phát ra trạng thái thành công
      emit(DeleteRoleRequestSuccess('Xóa yêu cầu thành công!'));
      log('Request deleted successfully: ${event.requestId}');
    } catch (e) {
      // Phát ra trạng thái thất bại
      emit(DeleteRoleRequestFailure('Lỗi khi xóa yêu cầu: $e'));
      log('DeleteRoleRequestFailure: $e');
    }
  }
}