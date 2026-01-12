abstract class Dependent {
  final String id;
  final String name;
  final String gender;
  final String cardStatus;
  final String photoUrl;

  Dependent({
    required this.id,
    required this.name,
    required this.gender,
    required this.cardStatus,
    required this.photoUrl,
  });
}

class Wife extends Dependent {
  Wife({required super.id, required super.name, required super.gender, required super.cardStatus, required super.photoUrl});

  factory Wife.fromMap(Map<String, dynamic> data) {
    return Wife(
      id: data['wife_id']?.toString() ?? '',
      name: data['name'] ?? '',
      gender: data['gender'] ?? '',
      cardStatus: data['card_status'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }
}

class Child extends Dependent {
  Child({required super.id, required super.name, required super.gender, required super.cardStatus, required super.photoUrl});

  factory Child.fromMap(Map<String, dynamic> data) {
    return Child(
      id: data['child_id']?.toString() ?? '',
      name: data['name'] ?? '',
      gender: data['gender'] ?? '',
      cardStatus: data['card_status'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }
}

class Membership {
  final String membershipId;
  final int membershipType;
  final String name;
  final String job;
  final String mobileNumber;
  final String maritalStatus;
  final String nationalId;
  final String membershipStatus;
  final String cardExpiryDate;
  final int dependentsCount;
  final String photoUrl;
  final Map<String, bool> memberships;
  List<Wife> wives;
  List<Child> children;

  Membership({
    required this.membershipId,
    required this.membershipType,
    required this.name,
    required this.job,
    required this.mobileNumber,
    required this.maritalStatus,
    required this.nationalId,
    required this.membershipStatus,
    required this.cardExpiryDate,
    required this.dependentsCount,
    required this.photoUrl,
    required this.memberships,
    this.wives = const [],
    this.children = const [],
  });

  factory Membership.fromMap(Map<String, dynamic> data, String id) {
    return Membership(
      membershipId: data['membership_id'] ?? id,
      membershipType: data['membership_type'] ?? 0,
      name: data['name'] ?? '',
      job: data['job'] ?? '',
      mobileNumber: data['mobile_number'] ?? '',
      maritalStatus: data['marital_status'] ?? '',
      nationalId: data['national_id'] ?? '',
      membershipStatus: data['membership_status'] ?? '',
      cardExpiryDate: data['card_expiry_date'] ?? '',
      dependentsCount: data['dependents'] ?? 0,
      photoUrl: data['photoUrl'] ?? '',
      memberships: Map<String, bool>.from(data['memberships'] ?? {}),
    );
  }
}