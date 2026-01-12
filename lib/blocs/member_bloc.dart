import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/database_service.dart';
import 'member_event.dart';
import 'member_state.dart';

class MemberBloc extends Bloc<MemberEvent, MemberState> {
  final DatabaseService _databaseService;

  //create bloc with initial state
  MemberBloc(this._databaseService) : super(MemberInitial()) {
    
    // handle FetchMemberData event
    on<FetchMemberData>((event, emit) async {
      emit(MemberLoading()); // loading state
      
      try {
        final member = await _databaseService.getMemberFullData(event.membershipId);
        
        if (member != null) {
          emit(MemberSuccess(member)); // emit success state with member data
        } else {
          emit(const MemberFailure("رقم العضوية غير موجود")); 
        }
      } catch (e) {
        emit(MemberFailure("حدث خطأ غير متوقع: ${e.toString()}"));
      }
    });
  }
}