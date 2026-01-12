import 'package:equatable/equatable.dart';
import '../../models/member_model.dart';

abstract class MemberState extends Equatable {
  const MemberState();

  @override
  List<Object?> get props => [];
}

class MemberInitial extends MemberState {} // final initial state
class MemberLoading extends MemberState {} // request in progress
class MemberSuccess extends MemberState {   // request successful
  final MemberModel member;
  const MemberSuccess(this.member);

  @override
  List<Object?> get props => [member];
}
class MemberFailure extends MemberState {  // request failed
  final String error;
  const MemberFailure(this.error);

  @override
  List<Object?> get props => [error];
}