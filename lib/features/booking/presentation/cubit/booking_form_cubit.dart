import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sca_members_clubs/core/services/firebase_service.dart';
import 'booking_form_state.dart';

class BookingFormCubit extends Cubit<BookingFormState> {
  final FirebaseService _firebaseService;

  BookingFormCubit(this._firebaseService)
    : super(
        BookingFormInitial(
          selectedDate: DateTime.now().add(const Duration(days: 1)),
        ),
      );

  void updateDate(DateTime date) {
    if (state is BookingFormInitial) {
      emit((state as BookingFormInitial).copyWith(selectedDate: date));
    }
  }

  void updateTime(String time) {
    if (state is BookingFormInitial) {
      emit((state as BookingFormInitial).copyWith(selectedTime: time));
    }
  }

  Future<void> submitBooking(
    Map<String, dynamic> service,
    String? notes,
  ) async {
    if (state is BookingFormInitial) {
      final currentState = state as BookingFormInitial;

      if (currentState.selectedTime == null) {
        emit(const BookingFormError("يرجى اختيار الوقت المفضل"));
        // Re-emit initial to allow form interaction after error
        emit(currentState);
        return;
      }

      emit(BookingFormSubmitting());

      try {
        // Calculate price
        // 1. If total_price is passed (from UI calculation e.g. Photo Session with extras), use it.
        // 2. Otherwise calculate based on booking type (300/500).
        final num finalPrice =
            service['total_price'] ??
            ((service['is_self_booking'] ?? true) ? 300 : 500);

        // Prepare service data for insertion
        final serviceData = {
          'id': service['id'] ?? service['title'] ?? 'unknown_service',
          'title': service['title'],
          'date': DateFormat('yyyy-MM-dd').format(currentState.selectedDate),
          'time': currentState.selectedTime,
          'is_self_booking': service['is_self_booking'] ?? true,
          'guest_name': service['guest_name'],
          'guest_national_id': service['guest_national_id'],
          'guest_phone': service['guest_phone'],
          'notes': notes,
          'price': finalPrice, // Use the finalized numeric price
        };

        // Save to services collection
        await _firebaseService.addService(serviceData);
        emit(BookingFormSuccess());
      } catch (e) {
        emit(BookingFormError(e.toString()));
        emit(currentState);
      }
    }
  }
}
