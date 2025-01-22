import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'request_role_event.dart';
part 'request_role_state.dart';

class RequestRoleBloc extends Bloc<RequestRoleEvent, RequestRoleState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RequestRoleBloc() : super(RequestRoleInitial()) {
    on<RequestRole>(_onRequestRole);
  }

  Future<void> _onRequestRole(
    RequestRole event,
    Emitter<RequestRoleState> emit,
  ) async {
    emit(RequestRoleLoading()); 

    try {
      // Gửi dữ liệu đến Firestore
      await _firestore.collection('role_requests').add({
        'contactName': event.contactName,
        'userId': event.userId,
        'email': event.email,
        'roleRequested': event.roleRequested,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending', // Trạng thái ban đầu
      });

      emit(RequestRoleSuccess('Role request sent successfully'));
    } catch (e) {
      emit(RequestRoleFailure(e.toString()));
    }
  }
}