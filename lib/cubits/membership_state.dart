// membership_state.dart
import '../models/membership_model.dart';

abstract class MembershipState {}
class MembershipInitial extends MembershipState {}
class MembershipLoading extends MembershipState {}
class MembershipSuccess extends MembershipState {
  final Membership membership;
  MembershipSuccess(this.membership);
}
class MembershipError extends MembershipState {
  final String message;
  MembershipError(this.message);
}