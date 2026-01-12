import 'package:equatable/equatable.dart';

class FamilyMemberModel extends Equatable {
  final String id;
  final String name;
  final String gender;
  final String cardStatus;
  final String photoUrl;

  const FamilyMemberModel({
    required this.id, required this.name, required this.gender, 
    required this.cardStatus, required this.photoUrl,
  });

  factory FamilyMemberModel.fromMap(Map<String, dynamic> map, String id) {
    return FamilyMemberModel(
      id: id,
      name: map['name'] ?? '',
      gender: map['gender'] ?? '',
      cardStatus: map['card_status'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name, 'gender': gender, 'card_status': cardStatus, 'photoUrl': photoUrl,
  };

  @override
  List<Object?> get props => [id, name, gender, cardStatus, photoUrl];
}