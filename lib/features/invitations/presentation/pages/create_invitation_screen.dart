import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sca_members_clubs/core/theme/app_colors.dart';
import 'package:sca_members_clubs/core/widgets/primary_button.dart';
import 'package:sca_members_clubs/core/widgets/sca_app_bar.dart';
import 'package:sca_members_clubs/core/services/firebase_service.dart';

class CreateInvitationScreen extends StatefulWidget {
  const CreateInvitationScreen({super.key});

  @override
  State<CreateInvitationScreen> createState() => _CreateInvitationScreenState();
}

class _CreateInvitationScreenState extends State<CreateInvitationScreen> {
  // Invitation Options
  List<Map<String, dynamic>> _clubs = [];
  String? _selectedClubId;
  String? _selectedClubName;
  String _invitationType = "بدون عضو"; // "في وجود العضو" or "بدون عضو"

  // Current guest being entered
  DateTime? _currentDate;
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _phoneController = TextEditingController();
  final _guestCountController = TextEditingController(text: "1");
  bool _saveToFavorites = false;

  // List of guests added to the table
  final List<GuestData> _addedGuests = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadClubs();
  }

  Future<void> _loadClubs() async {
    final clubs = await FirebaseService().getClubs();
    setState(() {
      _clubs = clubs;
      if (_clubs.isNotEmpty) {
        _selectedClubId = _clubs.first['id'];
        _selectedClubName = _clubs.first['name'];
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    _guestCountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _currentDate) {
      setState(() {
        _currentDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const ScaAppBar(title: "دعوة جديدة"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("بيانات الدعوة"),
            const SizedBox(height: 16),

            _buildLabel("النادي المدعو له"),
            _buildClubDropdown(),

            const SizedBox(height: 20),

            _buildLabel("نوع الدعوة"),
            _buildTypeSelection(),

            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("بيانات الزائر"),
                if (_invitationType == "بدون عضو")
                  TextButton.icon(
                    onPressed: _showFrequentGuestsSheet,
                    icon: const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    label: Text(
                      "المفضلة",
                      style: GoogleFonts.cairo(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            if (_invitationType == "بدون عضو") ...[
              _buildLabel("اسم الزائر (رباعي)"),
              _buildTextField(
                hint: "أدخل الاسم كما في البطاقة",
                controller: _nameController,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _buildLabel("الرقم القومي للزائر"),
              _buildTextField(
                hint: "14 رقم قومي",
                keyboardType: TextInputType.number,
                controller: _idController,
                icon: Icons.badge_outlined,
              ),
              const SizedBox(height: 20),
              _buildLabel("رقم تليفون الزائر"),
              _buildTextField(
                hint: "01xxxxxxxxx",
                keyboardType: TextInputType.phone,
                controller: _phoneController,
                icon: Icons.phone_outlined,
              ),
            ] else ...[
              _buildLabel("عدد الأفراد"),
              _buildTextField(
                hint: "أدخل عدد الأفراد",
                keyboardType: TextInputType.number,
                controller: _guestCountController,
                icon: Icons.people_outline,
              ),
            ],

            const SizedBox(height: 12),

            if (_invitationType == "بدون عضو")
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _saveToFavorites,
                      onChanged: (val) =>
                          setState(() => _saveToFavorites = val ?? false),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "حفظ في قائمة الضيوف الدائمين",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("تاريخ الزيارة"),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _currentDate == null
                                    ? "اختر التاريخ"
                                    : "${_currentDate!.day}/${_currentDate!.month}/${_currentDate!.year}",
                                style: GoogleFonts.cairo(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _currentDate == null
                                      ? Colors.grey
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            PrimaryButton(
              text: "إضافة للقائمة",
              onPressed: _addGuestToList,
              icon: Icons.person_add_rounded,
              backgroundColor: AppColors.secondary,
            ),

            const SizedBox(height: 48),

            _buildSectionTitle("قائمة الانتظار (${_addedGuests.length})"),
            const SizedBox(height: 16),
            _buildGuestCards(),

            if (_addedGuests.isNotEmpty) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "سيتم خصم (${_addedGuests.fold<int>(0, (sum, g) => sum + g.guestCount)}) دعوات من رصيدك عند التأكيد.",
                        style: GoogleFonts.cairo(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              PrimaryButton(
                text: "تأكيد وإصدار التصاريح",
                onPressed: () => _issueAllInvitations(),
                suffixIcon: Icons.check_circle_rounded,
                isLoading: _isLoading,
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildClubDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedClubId,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
          ),
          style: GoogleFonts.cairo(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          onChanged: (String? newValue) {
            setState(() {
              _selectedClubId = newValue;
              _selectedClubName = _clubs.firstWhere(
                (c) => c['id'] == newValue,
              )['name'];
            });
          },
          items: _clubs.map<DropdownMenuItem<String>>((
            Map<String, dynamic> club,
          ) {
            return DropdownMenuItem<String>(
              value: club['id'],
              child: Text(club['name']),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Row(
      children: [
        Expanded(
          child: _buildTypeCard(
            "بدون عضو",
            Icons.person_pin_circle_outlined,
            _invitationType == "بدون عضو",
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildTypeCard(
            "في وجود العضو",
            Icons.people_alt_outlined,
            _invitationType == "في وجود العضو",
          ),
        ),
      ],
    );
  }

  Widget _buildTypeCard(String title, IconData icon, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _invitationType = title),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : Colors.grey.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showFrequentGuestsSheet() async {
    final favorites = await FirebaseService().getFrequentGuests();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "الضيوف الدائمين",
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (favorites.isEmpty)
              Center(
                child: Text("لا توجد أسماء محفوظة", style: GoogleFonts.cairo()),
              ),
            ...favorites.map(
              (guest) => ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: Text(guest['name'], style: GoogleFonts.cairo()),
                subtitle: Text(
                  guest['national_id'],
                  style: GoogleFonts.cairo(fontSize: 12),
                ),
                onTap: () {
                  setState(() {
                    _nameController.text = guest['name'];
                    _idController.text = guest['national_id'];
                  });
                  Navigator.pop(context);
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () async {
                    await FirebaseService().toggleFrequentGuest(guest);
                    Navigator.pop(context);
                    _showFrequentGuestsSheet();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addGuestToList() {
    if (_currentDate == null || _selectedClubId == null) {
      _showError("برجاء اختيار التاريخ والنادي");
      return;
    }

    if (_invitationType == "بدون عضو") {
      if (_nameController.text.isEmpty ||
          _idController.text.length < 14 ||
          _phoneController.text.isEmpty) {
        _showError("برجاء إكمال بيانات الزائر (الاسم، الرقم القومي، الهاتف)");
        return;
      }
    } else {
      if (_guestCountController.text.isEmpty ||
          int.tryParse(_guestCountController.text) == null ||
          int.parse(_guestCountController.text) <= 0) {
        _showError("برجاء إدخال عدد أفراد صحيح");
        return;
      }
    }

    if (_invitationType == "بدون عضو" && _saveToFavorites) {
      FirebaseService().toggleFrequentGuest({
        "name": _nameController.text,
        "national_id": _idController.text,
      });
    }

    setState(() {
      _addedGuests.add(
        GuestData(
          name: _invitationType == "بدون عضو" ? _nameController.text : null,
          id: _invitationType == "بدون عضو" ? _idController.text : null,
          phone: _invitationType == "بدون عضو" ? _phoneController.text : null,
          guestCount: _invitationType == "في وجود العضو"
              ? int.parse(_guestCountController.text)
              : 1,
          clubId: _selectedClubId!,
          clubName: _selectedClubName!,
          type: _invitationType,
          date: _currentDate!,
        ),
      );

      // Clear fields for next entry
      _nameController.clear();
      _idController.clear();
      _phoneController.clear();
      _guestCountController.text = "1";
      _saveToFavorites = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.cairo()),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _issueAllInvitations() async {
    setState(() => _isLoading = true);
    try {
      for (var guest in _addedGuests) {
        // Build visit dates
        final visitDate = DateTime(
          guest.date.year,
          guest.date.month,
          guest.date.day,
        );

        // Expiry is at the end of the selected day (11:59:59 PM)
        final expiryDate = DateTime(
          guest.date.year,
          guest.date.month,
          guest.date.day,
          23,
          59,
          59,
        );

        // Build invitation data according to Firestore schema
        final Map<String, dynamic> invitationData = {
          "type": guest.type, // "بدون عضو" or "في وجود العضو"
          "visit_date": visitDate,
          "visit_expiration_date": expiryDate,
        };

        // Add conditional fields based on invitation type
        if (guest.type == "بدون عضو") {
          invitationData["visitor_name"] = guest.name ?? "";
          invitationData["national_id"] = guest.id ?? "";
          invitationData["visitor_phone_number"] = guest.phone ?? "";
        } else {
          invitationData["number_of_visitors"] = guest.guestCount;
        }

        await FirebaseService().createInvitation(invitationData);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "تم إنشاء ${_addedGuests.length} دعوة بنجاح",
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError("حدث خطأ أثناء إنشاء الدعوات: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTextField({
    required String hint,
    TextInputType? keyboardType,
    TextEditingController? controller,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.primary, size: 20)
              : null,
          hintStyle: GoogleFonts.cairo(color: Colors.grey[400], fontSize: 13),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildGuestCards() {
    if (_addedGuests.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(Icons.person_add_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(
              "لم يتم إضافة زوار بعد",
              style: GoogleFonts.cairo(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _addedGuests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final guest = _addedGuests[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guest.type == "في وجود العضو"
                          ? "دعوة في وجود العضو (${guest.guestCount} أفراد)"
                          : guest.name ?? "زائر غير معروف",
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "${guest.clubName} • ${guest.date.day}/${guest.date.month}/${guest.date.year}",
                      style: GoogleFonts.cairo(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Colors.red,
                ),
                onPressed: () => setState(() => _addedGuests.remove(guest)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: AppColors.textPrimary.withOpacity(0.8),
        ),
      ),
    );
  }
}

class GuestData {
  final String? name;
  final String? id;
  final String? phone;
  final int guestCount;
  final String clubId;
  final String clubName;
  final String type;
  final DateTime date;

  GuestData({
    this.name,
    this.id,
    this.phone,
    required this.guestCount,
    required this.clubId,
    required this.clubName,
    required this.type,
    required this.date,
  });
}
