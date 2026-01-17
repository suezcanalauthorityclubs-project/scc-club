import 'dart:async';
import 'mock_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'session_manager.dart';
import 'package:sca_members_clubs/core/di/injection_container.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  SessionManager? _sessionManager;

  Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  static Map<String, dynamic>? _currentUser;

  // --- Auth ---
  Future<Map<String, dynamic>?> login(
    String identifier,
    String password,
  ) async {
    await _simulateDelay();
    try {
      final user = MockData.registeredUsers.firstWhere(
        (u) => u['identifier'] == identifier && u['password'] == password,
      );
      _currentUser = user['profile'];
      return _currentUser;
    } catch (_) {
      return null;
    }
  }

  Future<void> register(Map<String, dynamic> userData) async {
    await _simulateDelay();
    MockData.registeredUsers.add({
      "identifier": userData['email'] ?? userData['membership_id'],
      "password": userData['password'],
      "profile": {
        ...MockData.memberProfile,
        "name": userData['name'],
        "role": "member",
      },
    });
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    await _simulateDelay();
    return _currentUser ?? MockData.memberProfile;
  }

  // --- Data Fetching with Club Filtering ---
  Future<List<Map<String, dynamic>>> getClubs({
    String? governorate,
    String? clubId,
  }) async {
    await _simulateDelay();
    var list = MockData.clubs;
    if (governorate != null) {
      list = list.where((c) => c['governorate'] == governorate).toList();
    }
    if (clubId != null && clubId != "global") {
      list = list.where((c) => c['id'] == clubId).toList();
    }
    return list;
  }

  Future<List<Map<String, dynamic>>> getNews({String? clubId}) async {
    await _simulateDelay();
    if (clubId != null && clubId != "global") {
      return MockData.news.where((n) => n['club_id'] == clubId).toList();
    }
    return MockData.news;
  }

  Future<List<Map<String, dynamic>>> getEvents({String? clubId}) async {
    await _simulateDelay();
    if (clubId != null && clubId != "global") {
      return MockData.events.where((e) => e['club_id'] == clubId).toList();
    }
    return MockData.events;
  }

  Future<List<Map<String, dynamic>>> getBookings({String? clubId}) async {
    await _simulateDelay();
    if (clubId != null && clubId != "global") {
      return MockData.bookings.where((b) => b['club_id'] == clubId).toList();
    }
    return MockData.bookings;
  }

  Future<List<Map<String, dynamic>>> getInvitationRequests({
    String? clubId,
  }) async {
    await _simulateDelay();
    if (clubId != null && clubId != "global") {
      return MockData.invitationRequests
          .where((r) => r['club_id'] == clubId)
          .toList();
    }
    return MockData.invitationRequests;
  }

  Future<List<Map<String, dynamic>>> getComplaints({String? clubId}) async {
    await _simulateDelay();
    if (clubId != null && clubId != "global") {
      return MockData.complaints.where((c) => c['club_id'] == clubId).toList();
    }
    return MockData.complaints;
  }

  Future<List<Map<String, dynamic>>> getCourts({String? clubId}) async {
    await _simulateDelay();
    return MockData.courts;
  }

  // --- Advanced Admin: Broadcasting & Analytics ---
  Future<void> sendBroadcastNotification(
    String title,
    String message, {
    String? targetClubId,
  }) async {
    await _simulateDelay();
    MockData.notifications.insert(0, {
      "id": "not_${DateTime.now().millisecondsSinceEpoch}",
      "title": title,
      "message": message,
      "time": "الآن",
      "type": "general",
      "is_read": false,
      "club_id": targetClubId,
    });
  }

  Future<Map<String, dynamic>> getAnalyticsData({String? clubId}) async {
    await _simulateDelay();
    return {
      "visitors_today": clubId == "c2" ? 45 : 124,
      "active_bookings": clubId == "c2" ? 8 : 22,
      "revenue_this_month": clubId == "c2" ? "45,000 ج.م" : "154,200 ج.م",
      "membership_distribution": [
        {"label": "عامل", "value": 65},
        {"label": "تابع", "value": 25},
        {"label": "خارجي", "value": 10},
      ],
      "monthly_activity": [30, 45, 60, 40, 80, 95, 120],
    };
  }

  Future<List<Map<String, dynamic>>> getAdminLogs({String? clubId}) async {
    await _simulateDelay();
    if (clubId != null && clubId != "global") {
      return MockData.adminLogs.where((l) => l['club_id'] == clubId).toList();
    }
    return MockData.adminLogs;
  }

  Future<List<Map<String, dynamic>>> getStaffMembers({String? clubId}) async {
    await _simulateDelay();
    if (clubId != null && clubId != "global") {
      return MockData.staffMembers
          .where((s) => s['club_id'] == clubId)
          .toList();
    }
    return MockData.staffMembers;
  }

  Future<List<Map<String, dynamic>>> getPendingVerifications({
    String? clubId,
  }) async {
    await _simulateDelay();
    if (clubId != null && clubId != "global") {
      return MockData.pendingVerifications
          .where((v) => v['club_id'] == clubId)
          .toList();
    }
    return MockData.pendingVerifications;
  }

  // --- Club Operations: Security & Official Guests ---
  Future<List<Map<String, dynamic>>> getSecurityStaff({String? clubId}) async {
    await _simulateDelay();
    if (clubId != null && clubId != "global") {
      return MockData.securityStaff
          .where((s) => s['club_id'] == clubId)
          .toList();
    }
    return MockData.securityStaff;
  }

  Future<void> updateSecurityShift(
    String id,
    String newShift,
    String newGate,
  ) async {
    await _simulateDelay();
    final i = MockData.securityStaff.indexWhere((s) => s['id'] == id);
    if (i != -1) {
      MockData.securityStaff[i]['shift'] = newShift;
      MockData.securityStaff[i]['gate'] = newGate;
    }
  }

  Future<void> addSecurityStaff(Map<String, dynamic> staffData) async {
    await _simulateDelay();
    MockData.securityStaff.add({
      ...staffData,
      "id": "sec_${DateTime.now().millisecondsSinceEpoch}",
    });
  }

  Future<List<Map<String, dynamic>>> getOfficialGuests({String? clubId}) async {
    await _simulateDelay();
    if (clubId != null && clubId != "global") {
      return MockData.officialGuests
          .where((g) => g['club_id'] == clubId)
          .toList();
    }
    return MockData.officialGuests;
  }

  Future<void> createOfficialInvitation(Map<String, dynamic> guest) async {
    await _simulateDelay();
    MockData.officialGuests.insert(0, {
      ...guest,
      "id": "vip_${DateTime.now().millisecondsSinceEpoch}",
      "entry_code":
          "VIP-${(1000 + DateTime.now().millisecond % 9000).toString()}",
    });
  }

  // --- Other Methods ---
  Future<int> getCurrentVisitorsCount() async {
    try {
      // Initialize session manager from DI if not already done
      _sessionManager ??= sl<SessionManager>();

      final membershipId =
          _sessionManager?.getSavedMembershipId() ?? _currentUser?['id'];

      if (membershipId == null || membershipId.isEmpty) {
        return 0;
      }

      // Query invitations where isScanned = true
      final snapshot = await _db
          .collection('invitations')
          .where('membership_id', isEqualTo: membershipId)
          .where('isScanned', isEqualTo: true)
          .get();

      // Filter by expiry date - only count non-expired invitations
      final now = DateTime.now();
      final activeCount = snapshot.docs.where((doc) {
        final data = doc.data();
        final expiryDate = data['visit_expiration_date'];

        if (expiryDate is Timestamp) {
          return expiryDate.toDate().isAfter(now);
        }
        return false;
      }).length;

      return activeCount;
    } catch (e) {
      print('ERROR: Error fetching current visitors count: $e');
      return 0;
    }
  }

  Future<void> requestAdditionalInvitations() async {
    await _simulateDelay();
    // Simulate request submission - in real app would create a request record
  }

  // --- User Management ---
  Future<void> createUser(Map<String, dynamic> userData) async {
    await _simulateDelay();
    MockData.registeredUsers.add({
      "identifier": userData['email'] ?? userData['membership_id'],
      "password": userData['password'] ?? "123456", // Default password
      "profile": userData,
    });
  }

  Future<List<Map<String, dynamic>>> getUsers({String? clubId}) async {
    await _simulateDelay();
    var users = MockData.registeredUsers
        .map((u) => u['profile'] as Map<String, dynamic>)
        .toList();
    if (clubId != null && clubId != "global") {
      users = users
          .where((u) => u['club_id'] == clubId || u['role'] == 'member')
          .toList();
    }
    return users;
  }

  Future<List<Map<String, dynamic>>> getInvitations() async {
    try {
      // Initialize session manager from DI if not already done
      _sessionManager ??= sl<SessionManager>();

      final membershipId =
          _sessionManager?.getSavedMembershipId() ?? _currentUser?['id'];
      print('DEBUG: Fetching invitations for membershipId: $membershipId');

      if (membershipId == null || membershipId.isEmpty) {
        print('ERROR: No membership ID found in session or current user');
        return [];
      }

      // Query invitations by membership_id field
      final snapshot = await _db
          .collection('invitations')
          .where('membership_id', isEqualTo: membershipId)
          .get();

      final invitations = snapshot.docs.map((doc) {
        final data = doc.data();
        // Handle Timestamp to String conversion for UI compatibility
        String formattedDate = "";
        if (data['visit_date'] is Timestamp) {
          final date = (data['visit_date'] as Timestamp).toDate();
          formattedDate = "${date.day}/${date.month}/${date.year}";
        }

        return {
          ...data,
          'id': doc.id,
          'guest_name': data['type'] == 'بدون عضو'
              ? (data['visitor_name'] ?? "")
              : "في وجود العضو",
          'guest_count': data['number_of_visitors'] ?? 1,
          'status': data['status'] ?? "active",
          'date': formattedDate,
        };
      }).toList();

      // Sort in memory to avoid needing a composite index in Firestore
      invitations.sort((a, b) {
        final aTime = a['created_at'] as Timestamp?;
        final bTime = b['created_at'] as Timestamp?;
        if (aTime == null || bTime == null) return 0;
        return bTime.compareTo(aTime);
      });

      return invitations;
    } catch (e) {
      print('❌ Error fetching invitations: $e');
      return [];
    }
  }

  /// Fetch ALL invitations (Firestore + Mock) for Security Screen
  Future<List<Map<String, dynamic>>> getAllInvitations() async {
    try {
      // 1. Fetch from Firestore
      final snapshot = await _db.collection('invitations').get();

      final firestoreInvitations = snapshot.docs.map((doc) {
        final data = doc.data();
        String formattedDate = "";
        if (data['visit_date'] is Timestamp) {
          final date = (data['visit_date'] as Timestamp).toDate();
          formattedDate = "${date.day}/${date.month}/${date.year}";
        }

        return {
          ...data,
          'id': doc.id,
          'guest_name': data['type'] == 'بدون عضو'
              ? (data['visitor_name'] ?? "زائر")
              : "في وجود العضو",
          'national_id': data['national_id'] ?? "N/A", // Important for search
          'guest_count': data['number_of_visitors'] ?? 1,
          'status': data['status'] ?? "active",
          'date': formattedDate,
          'source': 'app', // To distinguish if needed
        };
      }).toList();

      // 2. Fetch from Mock Data (Static)
      final staticInvitations = MockData.invitations
          .map((inv) => {...inv, 'source': 'static'})
          .toList();

      // 3. Merge Lists
      final allInvitations = [...firestoreInvitations, ...staticInvitations];

      // 4. Sort by date (descending)
      // Note: Static dates are strings "DD/MM/YYYY", Firestore formatted dates are also strings "D/M/YYYY"
      // Ideally should sort by actual date object, but simple reverse order might suffice for now
      // or just keep them appended.
      // Let's rely on list order for now or try basic string sort if needed

      return allInvitations;
    } catch (e) {
      print('❌ Error fetching all invitations: $e');
      // Fallback to just mock data if firestore fails
      return MockData.invitations;
    }
  }

  /// Stream of ALL invitations (Firestore + Mock) for Security Screen
  Stream<List<Map<String, dynamic>>> getAllInvitationsStream() {
    return _db.collection('invitations').snapshots().map((snapshot) {
      try {
        final firestoreInvitations = snapshot.docs.map((doc) {
          final data = doc.data();
          String formattedDate = "";
          if (data['visit_date'] is Timestamp) {
            final date = (data['visit_date'] as Timestamp).toDate();
            formattedDate = "${date.day}/${date.month}/${date.year}";
          }

          return {
            ...data,
            'id': doc.id,
            'guest_name': data['type'] == 'بدون عضو'
                ? (data['visitor_name'] ?? "زائر")
                : "في وجود العضو",
            'national_id': data['national_id'] ?? "N/A", // Important for search
            'guest_count': data['number_of_visitors'] ?? 1,
            'status': data['status'] ?? "active",
            'date': formattedDate,
            'source': 'app',
          };
        }).toList();

        // Fetch from Mock Data (Static)
        final staticInvitations = MockData.invitations
            .map((inv) => {...inv, 'source': 'static'})
            .toList();

        // Merge Lists
        final allInvitations = [...firestoreInvitations, ...staticInvitations];

        // Sort by created_at desc if available (newest first)
        allInvitations.sort((a, b) {
          final aTime = a['created_at'];
          final bTime = b['created_at'];
          if (aTime is Timestamp && bTime is Timestamp) {
            return bTime.compareTo(aTime);
          }
          return 0; // Keep existing order for non-timestamped items (like mock data)
        });

        return allInvitations;
      } catch (e) {
        print('❌ Error in getAllInvitationsStream mapping: $e');
        return MockData.invitations;
      }
    });
  }

  Future<List<Map<String, dynamic>>> getInvitationCards() async {
    try {
      // Initialize session manager from DI if not already done
      _sessionManager ??= sl<SessionManager>();

      final membershipId =
          _sessionManager?.getSavedMembershipId() ?? _currentUser?['id'];
      print('DEBUG: Fetching cards for membershipId: $membershipId');

      if (membershipId == null || membershipId.isEmpty) {
        print('ERROR: No membership ID found for cards');
        return [];
      }

      // Fetch membership balance from main_membership collection
      final membershipDoc = await _db
          .collection('main_membership')
          .where('membership_id', isEqualTo: membershipId)
          .limit(1)
          .get();

      int remaining = 0;
      int used = 0;

      if (membershipDoc.docs.isNotEmpty) {
        final doc = membershipDoc.docs.first;
        remaining = (doc['Remaining_invitations'] as num?)?.toInt() ?? 0;
        used = (doc['Used_invitations'] as num?)?.toInt() ?? 0;
      }

      final int total = remaining + used;

      print(
        'DEBUG: Invitation cards - remaining: $remaining, used: $used, total: $total',
      );

      // Build annual balance card
      final annualCard = {
        "id": "card_001",
        "type": "الرصيد السنوي",
        "total": total,
        "Remaining_invitations": remaining,
        "Used_invitations": used,
        "expiry": "2026-12-31",
        "color": "0xFF003A8F",
      };

      // Fetch additional cards from mock data (static)
      final additionalCards = MockData.invitationCards
          .where((c) => c['type'].toString().contains('إضافي'))
          .toList();

      return [annualCard, ...additionalCards];
    } catch (e) {
      print('❌ Error fetching invitation cards: $e');
      return [];
    }
  }

  Future<void> createInvitation(Map<String, dynamic> inv) async {
    try {
      // Initialize session manager from DI if not already done
      _sessionManager ??= sl<SessionManager>();

      final membershipId =
          _sessionManager?.getSavedMembershipId() ?? _currentUser?['id'];
      print('DEBUG: Creating invitation for membershipId: $membershipId');

      if (membershipId == null || membershipId.isEmpty) {
        throw Exception(
          'No membership ID found in session or current user profile',
        );
      }

      // Build Firestore document structure based on invitation type
      final invitationData = {
        "membership_id": membershipId,
        "type": inv['type'],
        "visit_date": inv['visit_date'], // DateTime/Timestamp
        "visit_expiration_date":
            inv['visit_expiration_date'], // DateTime/Timestamp
        "isScanned": false,
        "status": "active",
        "created_at": FieldValue.serverTimestamp(),
      };

      // Determine number of invitations to deduct
      int invitationsToDeduct = 1;
      if (inv['type'] == 'بدون عضو') {
        invitationData['visitor_name'] = inv['visitor_name'] ?? '';
        invitationData['national_id'] = inv['national_id'] ?? '';
        invitationData['visitor_phone_number'] =
            inv['visitor_phone_number'] ?? '';
      } else {
        // For "في وجود العضو"
        invitationsToDeduct = inv['number_of_visitors'] ?? 1;
        invitationData['number_of_visitors'] = invitationsToDeduct;
      }

      // Create document with auto-generated ID
      print(
        'DEBUG: Inserting invitation into Firestore collection: invitations',
      );
      final docRef = await _db.collection('invitations').add(invitationData);
      print('✅ Invitation created with ID: ${docRef.id}');

      // Update remaining and used invitations in main_membership
      // First, find the document by membership_id field
      final membershipQuery = await _db
          .collection('main_membership')
          .where('membership_id', isEqualTo: membershipId)
          .limit(1)
          .get();

      if (membershipQuery.docs.isEmpty) {
        print('ERROR: Membership document not found for: $membershipId');
        return;
      }

      final mainMembershipRef = membershipQuery.docs.first.reference;

      await _db.runTransaction((transaction) async {
        final mainMembershipDoc = await transaction.get(mainMembershipRef);

        int currentRemaining = 0;
        int currentUsed = 0;

        if (mainMembershipDoc.exists) {
          currentRemaining =
              (mainMembershipDoc['Remaining_invitations'] as num?)?.toInt() ??
              0;
          currentUsed =
              (mainMembershipDoc['Used_invitations'] as num?)?.toInt() ?? 0;
        }

        // Calculate new values
        final newRemaining = (currentRemaining - invitationsToDeduct)
            .clamp(0, double.infinity)
            .toInt();
        final newUsed = currentUsed + invitationsToDeduct;

        // Update the found document
        transaction.set(mainMembershipRef, {
          'Remaining_invitations': newRemaining,
          'Used_invitations': newUsed,
          'last_updated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print(
          '✅ Updated main_membership: remaining=$newRemaining, used=$newUsed',
        );
      });
    } catch (e) {
      print('❌ Error creating invitation: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getActiveVisitors() async {
    await _simulateDelay();
    return MockData.activeVisitors;
  }

  Future<List<Map<String, dynamic>>> getRestaurants({String? clubId}) async {
    await _simulateDelay();
    return (clubId != null)
        ? MockData.restaurants.where((r) => r['club_id'] == clubId).toList()
        : MockData.restaurants;
  }

  Future<List<Map<String, dynamic>>> getMenu(String rid) async {
    await _simulateDelay();
    return MockData.menuItems.where((m) => m['restaurant_id'] == rid).toList();
  }

  Future<List<Map<String, dynamic>>> getFamilyMembers() async {
    await _simulateDelay();
    return MockData.familyMembers;
  }

  Future<void> addFamilyMember(Map<String, dynamic> m) async {
    await _simulateDelay();
    MockData.familyMembers.add(m);
  }

  Future<List<String>> getMembershipTypes() async {
    await _simulateDelay();
    return MockData.membershipTypes;
  }

  Future<List<Map<String, dynamic>>> getMapLocations() async {
    await _simulateDelay();
    return MockData.mapLocations;
  }

  Future<List<Map<String, dynamic>>> getActivities({String? clubId}) async {
    await _simulateDelay();
    if (clubId != null) {
      return MockData.activities.where((a) => a['club_id'] == clubId).toList();
    }
    return MockData.activities;
  }

  Future<void> addBooking(Map<String, dynamic> b) async {
    await _simulateDelay();
    MockData.bookings.insert(0, b);
  }

  /// Add a service booking to the services collection
  Future<void> addService(Map<String, dynamic> serviceData) async {
    try {
      // Initialize session manager from DI if not already done
      _sessionManager ??= sl<SessionManager>();

      final membershipId =
          _sessionManager?.getSavedMembershipId() ?? _currentUser?['id'];

      if (membershipId == null || membershipId.isEmpty) {
        throw Exception('No membership ID found in session');
      }

      // Build the service document structure
      final documentData = {
        'service_id': serviceData['id'] ?? serviceData['title'] ?? 'unknown',
        'service_date': serviceData['date'] != null
            ? Timestamp.fromDate(DateTime.parse(serviceData['date']))
            : FieldValue.serverTimestamp(),
        'service_timeslot':
            serviceData['time'] ?? serviceData['selectedTime'] ?? '',
        'service_cost': _parsePriceToNum(
          serviceData['price'] ?? serviceData['total_price'] ?? 0,
        ),
        'membership_id': membershipId,
        'beneficiary_name': !serviceData['is_self_booking']
            ? serviceData['guest_name']
            : null,
        'beneficiary_national_id': !serviceData['is_self_booking']
            ? serviceData['guest_national_id']
            : null,
        'created_at': FieldValue.serverTimestamp(),
      };

      // Remove null values for optional fields
      documentData.removeWhere((key, value) => value == null);

      // Add to services collection
      await _db.collection('services').add(documentData);

      print('✅ Service booking created successfully');
    } catch (e) {
      print('❌ Error creating service booking: $e');
      rethrow;
    }
  }

  /// Listen to user's service bookings from the services collection
  Stream<List<Map<String, dynamic>>> getMyServicesStream() {
    // Initialize session manager from DI if not already done
    _sessionManager ??= sl<SessionManager>();

    final membershipId =
        _sessionManager?.getSavedMembershipId() ?? _currentUser?['id'];

    if (membershipId == null || membershipId.isEmpty) {
      print('ERROR: No membership ID found for fetching services stream');
      return const Stream.empty();
    }

    return _db
        .collection('services')
        .where('membership_id', isEqualTo: membershipId)
        .snapshots()
        .map((snapshot) {
          print(
            'DEBUG: Stream Update - ${snapshot.docs.length} services found',
          );
          final services = _parseServicesSnapshot(snapshot);

          // Sort by created_at in memory
          services.sort((a, b) {
            final aDate = a['created_at'] as Timestamp?;
            final bDate = b['created_at'] as Timestamp?;
            if (aDate == null || bDate == null) return 0;
            return bDate.compareTo(aDate);
          });

          return services;
        });
  }

  /// Fetch user's service bookings from the services collection
  Future<List<Map<String, dynamic>>> getMyServices() async {
    try {
      // Initialize session manager from DI if not already done
      _sessionManager ??= sl<SessionManager>();

      final membershipId =
          _sessionManager?.getSavedMembershipId() ?? _currentUser?['id'];

      print(
        'DEBUG [FirebaseService]: SessionManager membership_id: $membershipId',
      );

      if (membershipId == null || membershipId.isEmpty) {
        print('ERROR: No membership ID found for fetching services');
        // Try to get all services as fallback for debugging
        print('DEBUG: Fetching ALL services as fallback...');
        return await _getAllServices();
      }

      print('DEBUG: Fetching services for membershipId: $membershipId');

      // Query services by membership_id (no orderBy to avoid index requirement)
      final snapshot = await _db
          .collection('services')
          .where('membership_id', isEqualTo: membershipId)
          .get();

      print('DEBUG: Query returned ${snapshot.docs.length} documents');

      if (snapshot.docs.isEmpty) {
        print(
          'DEBUG: No services found for this membership_id, trying fallback...',
        );
        return await _getAllServices();
      }

      final services = _parseServicesSnapshot(snapshot);

      // Sort by created_at in memory
      services.sort((a, b) {
        final aDate = a['created_at'] as Timestamp?;
        final bDate = b['created_at'] as Timestamp?;
        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate);
      });

      return services;
    } catch (e) {
      print('❌ Error in getMyServices: $e');
      print('ERROR Stack: ${e.toString()}');
      return [];
    }
  }

  /// Get ALL services from collection (for debugging)
  Future<List<Map<String, dynamic>>> _getAllServices() async {
    try {
      final snapshot = await _db.collection('services').get();
      print(
        'DEBUG: _getAllServices found ${snapshot.docs.length} total services',
      );

      for (var doc in snapshot.docs) {
        print(
          'DEBUG: Service doc - ID: ${doc.id}, membership_id: ${doc.data()['membership_id']}',
        );
      }

      final services = _parseServicesSnapshot(snapshot);
      return services;
    } catch (e) {
      print('❌ Error in _getAllServices: $e');
      return [];
    }
  }

  num _parsePriceToNum(dynamic price) {
    if (price == null) return 0;
    if (price is num) return price;
    if (price is String) {
      // Remove any non-numeric characters except decimal points
      final cleaned = price.replaceAll(RegExp(r'[^0-9.]'), '');
      return num.tryParse(cleaned) ?? 0;
    }
    return 0;
  }

  /// Map service IDs to Arabic service names
  String _mapServiceIdToName(String serviceId) {
    const serviceMap = {
      's1': 'حجز فوتوسيشن',
      's2': 'كرة قدم خماسي',
      's3': 'حمام السباحة',
      's4': 'قاعة المناسبات',
      's5': 'تنس طاولة',
      's6': 'اسكواش',
      's7': 'النشاط الرياضي',
      's8': 'المطاعم والكافيهات',
    };
    return serviceMap[serviceId] ?? serviceId;
  }

  List<Map<String, dynamic>> _parseServicesSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final services = snapshot.docs.map((doc) {
      final data = doc.data();

      // Convert Timestamp to formatted string for UI
      String formattedDate = "";
      if (data['service_date'] is Timestamp) {
        final date = (data['service_date'] as Timestamp).toDate();
        formattedDate = "${date.day}/${date.month}/${date.year}";
      }

      // Map service_id to Arabic name
      final serviceId = data['service_id'] ?? 'خدمة';
      final serviceName = _mapServiceIdToName(serviceId);

      return {
        ...data,
        'id': doc.id,
        'date': formattedDate,
        'service_name': serviceName,
        'time': data['service_timeslot'] ?? '',
        'price': data['service_cost'] ?? 0,
        'total_price': data['service_cost'] ?? 0,
        'status': 'قيد المراجعة', // Default status
        'created_at': data['created_at'],
      };
    }).toList();

    print('✅ Parsed ${services.length} services');
    return services;
  }

  Future<List<Map<String, dynamic>>> getPromos() async {
    await _simulateDelay();
    return MockData.promos;
  }

  Future<List<Map<String, dynamic>>> getNotifications() async {
    await _simulateDelay();
    return MockData.notifications;
  }

  Future<int> getUnreadNotificationsCount() async {
    await _simulateDelay();
    return MockData.notifications.where((n) => !(n['is_read'] as bool)).length;
  }

  Future<void> markNotificationAsRead(String id) async {
    await _simulateDelay();
    final i = MockData.notifications.indexWhere((n) => n['id'] == id);
    if (i != -1) MockData.notifications[i]['is_read'] = true;
  }

  Future<List<Map<String, dynamic>>> getFrequentGuests() async {
    await _simulateDelay();
    return MockData.frequentGuests;
  }

  Future<void> toggleFrequentGuest(Map<String, dynamic> g) async {
    await _simulateDelay();
    final i = MockData.frequentGuests.indexWhere(
      (fg) => fg['national_id'] == g['national_id'],
    );
    if (i != -1) {
      MockData.frequentGuests.removeAt(i);
    } else {
      MockData.frequentGuests.add({
        ...g,
        "id": "fg_${DateTime.now().millisecondsSinceEpoch}",
      });
    }
  }

  Future<List<Map<String, dynamic>>> getBookingSlots(String cid) async {
    await _simulateDelay();
    return MockData.bookingSlots[cid] ?? [];
  }

  Future<void> updateInvitationRequestStatus(
    String reqId,
    String status,
  ) async {
    await _simulateDelay();
    final i = MockData.invitationRequests.indexWhere((r) => r['id'] == reqId);
    if (i != -1) MockData.invitationRequests[i]['status'] = status;
  }

  /// Scan an invitation QR code and mark it as scanned if not expired
  Future<Map<String, dynamic>> scanInvitation(String invitationId) async {
    try {
      // Get the invitation document
      final invDoc = await _db
          .collection('invitations')
          .doc(invitationId)
          .get();

      if (!invDoc.exists) {
        return {
          'success': false,
          'message': 'الدعوة غير موجودة',
          'type': 'error',
        };
      }

      final invData = invDoc.data() ?? {};

      // Check if invitation is expired
      final expirationDate = invData['visit_expiration_date'] as Timestamp?;
      if (expirationDate == null) {
        return {
          'success': false,
          'message': 'بيانات الدعوة غير صحيحة',
          'type': 'error',
        };
      }

      if (expirationDate.toDate().isBefore(DateTime.now())) {
        return {
          'success': false,
          'message': 'الدعوة منتهية الصلاحية',
          'type': 'expired',
        };
      }

      // Check if already scanned
      if (invData['isScanned'] == true) {
        return {
          'success': false,
          'message': 'تم مسح هذه الدعوة مسبقاً',
          'type': 'already_scanned',
        };
      }

      // Update invitation to mark as scanned
      await _db.collection('invitations').doc(invitationId).update({
        'isScanned': true,
        'scanned_at': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'تم قبول الدعوة بنجاح',
        'type': 'invitation',
        'visitor_name': invData['visitor_name'] ?? 'زائر',
        'membership_id': invData['membership_id'],
        'visit_date': invData['visit_date'],
      };
    } catch (e) {
      print('Error scanning invitation: $e');
      return {
        'success': false,
        'message': 'حدث خطأ أثناء معالجة الدعوة',
        'type': 'error',
      };
    }
  }

  /// Record a club visit from membership QR code
  Future<Map<String, dynamic>> recordClubVisit(String membershipId) async {
    try {
      // Verify membership exists
      var membershipDoc = await _db
          .collection('main_membership')
          .doc(membershipId)
          .get();

      if (!membershipDoc.exists) {
        // Try querying by membership_id field
        final query = await _db
            .collection('main_membership')
            .where('membership_id', isEqualTo: membershipId)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          return {
            'success': false,
            'message': 'العضوية غير موجودة',
            'type': 'error',
          };
        }
        membershipDoc = query.docs.first;
      }

      final membershipData = membershipDoc.data() ?? {};
      final membershipName = membershipData['name'] ?? 'عضو';

      // Create a new visit record in club_visits collection
      final visitId = _db.collection('club_visits').doc().id;
      final now = DateTime.now();

      // Set visit expiration to 24 hours from now
      final expirationDate = now.add(const Duration(days: 1));

      await _db.collection('club_visits').doc(visitId).set({
        'membership_id': membershipId,
        'visit_date': FieldValue.serverTimestamp(),
        'visit_expiration_date': Timestamp.fromDate(expirationDate),
      });

      return {
        'success': true,
        'message': 'تم تسجيل الدخول بنجاح',
        'type': 'membership',
        'member_name': membershipName,
        'membership_id': membershipId,
        'visit_date': Timestamp.now(),
      };
    } catch (e) {
      print('Error recording club visit: $e');
      return {
        'success': false,
        'message': 'حدث خطأ أثناء تسجيل الدخول',
        'type': 'error',
      };
    }
  }
}
