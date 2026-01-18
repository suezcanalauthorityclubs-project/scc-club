import 'package:sca_members_clubs/features/booking/domain/entities/booking.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.id,
    required super.serviceName,
    required super.date,
    required super.time,
    required super.status,
    required super.price,
    required super.clubId,
    required super.clubName,
    required super.type,
    required super.totalPrice,
    required super.attendeesCount,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map) {
    // Determine the numeric value of the cost
    double costValue = 0.0;
    final rawCost = map['service_cost'] ?? map['total_price'] ?? 0;

    if (rawCost is num) {
      costValue = rawCost.toDouble();
    } else if (rawCost is String) {
      // Handle legacy string data (e.g., "500 ج.م")
      costValue =
          double.tryParse(rawCost.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
    }

    // Format price for UI (e.g., "500 ج.م")
    // If it's a whole number, remove .0
    final displayPrice = costValue == costValue.toInt()
        ? "${costValue.toInt()} ج.م"
        : "$costValue ج.م";

    return BookingModel(
      id: map['id'] ?? '',
      serviceName: map['service_name'] ?? map['title'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      status: map['status'] ?? '',
      price: displayPrice,
      clubId: map['club_id'] ?? '',
      clubName: map['club_name'] ?? '',
      type: map['type'] ?? '',
      totalPrice: costValue,
      attendeesCount: map['attendees_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'service_name': serviceName,
      'date': date,
      'time': time,
      'status': status,
      'price': price,
      'club_id': clubId,
      'club_name': clubName,
      'type': type,
      'total_price': totalPrice,
      'attendees_count': attendeesCount,
    };
  }
}
