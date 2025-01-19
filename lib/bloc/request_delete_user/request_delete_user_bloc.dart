import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'request_delete_user_event.dart';
part 'request_delete_user_state.dart';

class RequestDeleteUserBloc
    extends Bloc<RequestDeleteUserEvent, RequestDeleteUserState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RequestDeleteUserBloc() : super(RequestDeleteUserInitial()) {
    on<RequestDeleteUser>(_onRequestDeleteUser);
  }

  Future<void> _onRequestDeleteUser(
    RequestDeleteUser event,
    Emitter<RequestDeleteUserState> emit,
  ) async {
    emit(RequestDeleteUserLoading()); // Bắt đầu loading

    try {
      // Gửi dữ liệu đến Firestore
      await _firestore.collection('request_delete_user').add({
        'uid': event.uid,
        'email': event.email,
        'timestamp': FieldValue.serverTimestamp(), // Thêm timestamp
      });

      emit(const RequestDeleteUserSuccess('Request sent successfully'));
    } catch (e) {
      emit(RequestDeleteUserFailure(e.toString()));
    }
  }
}