import 'package:equatable/equatable.dart';
import 'family_model.dart';

class MemberModel extends Equatable {
  final String id;
  final String name;
  final String job;
  final String mobileNumber;
  final String nationalId;
  final String membershipStatus;
  final String cardExpiryDate;
  final String photoUrl;
  final int dependentsCount;
  final Map<String, bool> memberships;
  final List<FamilyMemberModel> children;
  final List<FamilyMemberModel> wives;

  const MemberModel({
    required this.id,
    required this.name,
    required this.job,
    required this.mobileNumber,
    required this.nationalId,
    required this.membershipStatus,
    required this.cardExpiryDate,
    required this.photoUrl,
    required this.dependentsCount,
    required this.memberships,
    this.children = const [],
    this.wives = const [],
  });

  factory MemberModel.fromFirestore(
    Map<String, dynamic> json, 
    String docId, 
    {List<FamilyMemberModel> children = const [], List<FamilyMemberModel> wives = const []}
  ) {
    return MemberModel(
      id: docId,
      name: json['name'] ?? '',
      job: json['job'] ?? '',
      mobileNumber: json['mobile_number'] ?? '',
      nationalId: json['national_id'] ?? '',
      membershipStatus: json['membership_status'] ?? '',
      cardExpiryDate: json['card_expiry_date'] ?? '',
      photoUrl: json['photoUrl'] ?? '',
      dependentsCount: json['dependents'] ?? 0,
      memberships: Map<String, bool>.from(json['memberships'] ?? {}),
      children: children,
      wives: wives,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'membership_id': id,
      'name': name,
      'job': job,
      'mobile_number': mobileNumber,
      'national_id': nationalId,
      'membership_status': membershipStatus,
      'card_expiry_date': cardExpiryDate,
      'photoUrl': photoUrl,
      'dependents': dependentsCount,
      'memberships': memberships,
    };
  }

  @override
  List<Object?> get props => [id, name, memberships, children, wives];
}