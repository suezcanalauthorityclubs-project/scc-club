// membership_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/firestore_service.dart';
import 'membership_state.dart';

class MembershipCubit extends Cubit<MembershipState> {
  final FirestoreService _service;
  MembershipCubit(this._service) : super(MembershipInitial());

  Future<void> fetchMembership(String id) async {
    if (id.isEmpty) {
      emit(MembershipError("يرجى إدخال رقم العضوية أولاً"));
      return;
    }

    emit(MembershipLoading());
    try {
      final result = await _service.getMembership(id);
      if (result != null) {
        emit(MembershipSuccess(result));
      } else {
        emit(MembershipError("عفواً، لم يتم العثور على عضوية بهذا الرقم"));
      }
    } catch (e) {
      emit(MembershipError("فشل الاتصال بالقاعدة: يرجى التحقق من الإنترنت"));
    }
  }
}