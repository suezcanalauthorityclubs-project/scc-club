import 'package:flutter_bloc/flutter_bloc.dart';
import 'member_event.dart';
import 'member_state.dart';
import '../services/database_service.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final DatabaseService _service;

  MemberBloc(this._service) : super(MemberInitial()) {
    on<FetchMemberData>((event, emit) async {
      emit(MemberLoading());
      try {
        final member = await _service.getFullMemberDetails(event.membershipId);
        if (member != null) {
          emit(MemberSuccess(member));
        } else {
          emit(const MemberFailure("العضوية غير موجودة"));
        }
      } catch (e) {
        emit(MemberFailure(e.toString()));
      }
    });
  }
}