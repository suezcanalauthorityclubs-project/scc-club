import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sca_members_clubs/core/theme/app_colors.dart';
import 'package:sca_members_clubs/core/widgets/sca_app_bar.dart';
import 'package:sca_members_clubs/core/services/firebase_service.dart';

class SecurityInvitationsScreen extends StatefulWidget {
  const SecurityInvitationsScreen({super.key});

  @override
  State<SecurityInvitationsScreen> createState() =>
      _SecurityInvitationsScreenState();
}

class _SecurityInvitationsScreenState extends State<SecurityInvitationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Stream<List<Map<String, dynamic>>> _invitationsStream;
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _invitationsStream = FirebaseService().getAllInvitationsStream();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScaAppBar(title: "التحقق من الدعوات"),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "بحث بالرقم القومي...",
                hintStyle: GoogleFonts.cairo(fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _invitationsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "حدث خطأ في تحميل البيانات",
                      style: GoogleFonts.cairo(color: Colors.red),
                    ),
                  );
                }

                final allInvitations = snapshot.data ?? [];

                // improved search logic:
                // 1. If query is empty -> show all
                // 2. If query is not empty -> filter by national_id string match
                final filteredInvitations = _searchQuery.isEmpty
                    ? allInvitations
                    : allInvitations.where((inv) {
                        return inv['national_id'].toString().contains(
                          _searchQuery,
                        );
                      }).toList();

                if (filteredInvitations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "لا توجد نتائج مطابقة",
                          style: GoogleFonts.cairo(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredInvitations.length,
                  itemBuilder: (context, index) {
                    final inv = filteredInvitations[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFE3F2FD),
                          child: Icon(
                            inv['source'] == 'static'
                                ? Icons.security_rounded
                                : Icons.person,
                            color: Colors.blue,
                          ),
                        ),
                        title: Text(
                          inv['guest_name'],
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "التاريخ: ${inv['date']}\nالرقم القومي: ${inv['national_id']}",
                          style: GoogleFonts.cairo(fontSize: 12),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: inv['status'] == 'active'
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            inv['status'] == 'active' ? "نشطة" : "منتهية",
                            style: GoogleFonts.cairo(
                              color: inv['status'] == 'active'
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
