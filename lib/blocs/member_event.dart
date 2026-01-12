import 'package:equatable/equatable.dart';

abstract class MemberEvent extends Equatable {
  const MemberEvent();

  @override
  List<Object> get props => [];
}

// event to fetch member data
class FetchMemberData extends MemberEvent {
  final String membershipId;

  const FetchMemberData(this.membershipId);

  @override
  List<Object> get props => [membershipId];
}