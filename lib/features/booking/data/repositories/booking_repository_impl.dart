import 'package:sca_members_clubs/core/services/firebase_service.dart';
import 'package:sca_members_clubs/features/booking/data/models/booking_model.dart';
import 'package:sca_members_clubs/features/booking/data/models/service_model.dart';
import 'package:sca_members_clubs/features/booking/domain/entities/booking.dart';
import 'package:sca_members_clubs/features/booking/domain/entities/service.dart';
import 'package:sca_members_clubs/features/booking/domain/repositories/booking_repository.dart';

class BookingRepositoryImpl implements BookingRepository {
  final FirebaseService _firebaseService;

  BookingRepositoryImpl(this._firebaseService);

  @override
  Future<List<Booking>> getBookings({String? clubId}) async {
    try {
      // Fetch from the services collection (real bookings)
      final servicesResult = await _firebaseService.getMyServices();
      print(
        'DEBUG [Repository]: getMyServices returned ${servicesResult.length} items',
      );

      final serviceBookings = servicesResult.map((e) {
        print(
          'DEBUG [Repository]: Mapping service: ${e['service_name']} (ID: ${e['id']})',
        );
        return BookingModel.fromMap(e);
      }).toList();

      // Fetch legacy bookings (static list)
      final legacyResult = await _firebaseService.getBookings(clubId: clubId);
      print(
        'DEBUG [Repository]: getBookings (legacy) returned ${legacyResult.length} items',
      );

      final legacyBookings = legacyResult
          .map((e) => BookingModel.fromMap(e))
          .toList();

      // Combine: Services on top, then legacy bookings
      final combinedBookings = [...serviceBookings, ...legacyBookings];
      print(
        'DEBUG [Repository]: Combined total: ${combinedBookings.length} bookings',
      );

      // Remove duplicates if any (based on booking ID)
      final seen = <String>{};
      final uniqueBookings = <Booking>[];
      for (final booking in combinedBookings) {
        if (seen.add(booking.id)) {
          uniqueBookings.add(booking);
        }
      }

      print(
        'DEBUG [Repository]: After dedup: ${uniqueBookings.length} unique bookings',
      );
      return uniqueBookings;
    } catch (e) {
      print('ERROR [Repository]: Exception in getBookings: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Booking>> getBookingsStream({String? clubId}) {
    // 1. Stream from services collection (real-time)
    final servicesStream = _firebaseService.getMyServicesStream().map((list) {
      return list.map((e) => BookingModel.fromMap(e)).toList();
    });

    // 2. Combine with legacy bookings (static)
    // Map the stream events to async calls that fetch legacy data
    return servicesStream.asyncMap((serviceBookings) async {
      try {
        final legacyResult = await _firebaseService.getBookings(clubId: clubId);
        final legacyBookings = legacyResult
            .map((e) => BookingModel.fromMap(e))
            .toList();

        final combinedBookings = [...serviceBookings, ...legacyBookings];

        // Deduplicate bookings
        final seen = <String>{};
        final uniqueBookings = <Booking>[];
        for (final booking in combinedBookings) {
          if (seen.add(booking.id)) {
            uniqueBookings.add(booking);
          }
        }
        return uniqueBookings;
      } catch (e) {
        print('Error combining booking streams: $e');
        // Return at least the streamed bookings on error
        return serviceBookings.map((e) => e as Booking).toList();
      }
    });
  }

  @override
  Future<List<String>> getMembershipTypes() async {
    return _firebaseService.getMembershipTypes();
  }

  @override
  Future<List<Service>> getServices({String? clubId}) async {
    // Simulating Local Data Source for Services until moved to Backend
    final List<Map<String, dynamic>> servicesData = [
      {
        "id": "s1",
        "title": "فوتو سيشن",
        "price": "500 ج.م",
        "type": "photo_session",
      },
      {
        "id": "s2",
        "title": "كرة قدم خماسي",
        "price": "150 ج.م/ساعة",
        "type": "football",
      },
      {
        "id": "s3",
        "title": "حمام السباحة",
        "price": "50 ج.م/فرد",
        "type": "pool",
      },
      {
        "id": "s4",
        "title": "قاعة المناسبات",
        "price": "من 2000 ج.م",
        "type": "events_hall",
      },
      {
        "id": "s5",
        "title": "تنس طاولة",
        "price": "30 ج.م/ساعة",
        "type": "table_tennis",
      },
      {
        "id": "s6",
        "title": "اسكواش",
        "price": "100 ج.م/ساعة",
        "type": "squash",
      },
      {
        "id": "s7",
        "title": "النشاط الرياضي",
        "price": "جدول الحصص",
        "type": "activities_schedule",
      },
      {
        "id": "s8",
        "title": "المطاعم والكافيهات",
        "price": "قائمة الطعام",
        "type": "dining",
      },
    ];

    return servicesData.map((e) => ServiceModel.fromMap(e)).toList();
  }

  @override
  Future<void> addBooking(Map<String, dynamic> bookingData) async {
    await _firebaseService.addBooking(bookingData);
  }
}
