import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sca_members_clubs/features/booking/domain/entities/service.dart';
import 'package:sca_members_clubs/features/booking/domain/repositories/booking_repository.dart';
import 'booking_state.dart';

class BookingCubit extends Cubit<BookingState> {
  final BookingRepository _bookingRepository;

  StreamSubscription? _bookingsSubscription;

  BookingCubit(this._bookingRepository) : super(BookingInitial());

  Future<void> loadBookingData() async {
    emit(BookingLoading());
    try {
      // Load static data first
      final membershipTypes = await _bookingRepository.getMembershipTypes();
      final services = await _bookingRepository.getServices();

      // Subscribe to bookings stream
      _bookingsSubscription?.cancel();
      _bookingsSubscription = _bookingRepository.getBookingsStream().listen(
        (bookings) {
          emit(
            BookingLoaded(
              myBookings: bookings,
              membershipTypes: membershipTypes,
              currentMembership: membershipTypes.isNotEmpty
                  ? membershipTypes.first
                  : "عضو عامل",
              services: services,
            ),
          );
        },
        onError: (e) {
          emit(BookingError(e.toString()));
        },
      );
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    return super.close();
  }

  void selectService(Service? service) {
    if (state is BookingLoaded) {
      emit(
        (state as BookingLoaded).copyWith(
          selectedService: service,
          clearSelectedService: service == null,
        ),
      );
    }
  }

  void updateMembership(String type) {
    if (state is BookingLoaded) {
      emit((state as BookingLoaded).copyWith(currentMembership: type));
    }
  }

  Future<void> addBooking(Map<String, dynamic> booking) async {
    try {
      await _bookingRepository.addBooking(booking);
      loadBookingData(); // Reload
    } catch (e) {
      emit(BookingError(e.toString()));
    }
  }
}
