import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sca_members_clubs/core/theme/app_colors.dart';
import 'package:sca_members_clubs/core/widgets/sca_app_bar.dart';
import 'package:sca_members_clubs/core/services/firebase_service.dart';

class SecurityScannerScreen extends StatefulWidget {
  const SecurityScannerScreen({super.key});

  @override
  State<SecurityScannerScreen> createState() => _SecurityScannerScreenState();
}

class _SecurityScannerScreenState extends State<SecurityScannerScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isProcessing = false;

  @override
  void dispose() {
    super.dispose();
  }

  /// Process scanned QR code
  Future<void> _processScanResult(String qrCode) async {
    if (_isProcessing) return; // Prevent multiple scans
    setState(() => _isProcessing = true);

    try {
      Map<String, dynamic> result = await _firebaseService.scanInvitation(qrCode);

      // If invitation not found, try as membership ID
      if (!result['success'] &&
          result['type'] == 'error' &&
          result['message']?.contains('غير موجودة') == true) {
        result = await _firebaseService.recordClubVisit(qrCode);
      }

      if (!mounted) return;
      _showResultDialog(result);
    } catch (e) {
      if (!mounted) return;
      _showResultDialog({
        'success': false,
        'message': 'حدث خطأ: $e',
        'type': 'error',
      });
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showResultDialog(Map<String, dynamic> result) {
    final success = result['success'] == true;
    final message = result['message'] ?? 'خطأ غير معروف';
    final type = result['type'] ?? 'error';

    String title = message;
    String subtitle = '';

    if (type == 'invitation' && success) {
      subtitle =
          "الزائر: ${result['visitor_name'] ?? 'زائر'}\nالعضوية: ${result['membership_id'] ?? 'N/A'}";
    } else if (type == 'membership' && success) {
      subtitle =
          "العضو: ${result['member_name'] ?? 'عضو'}\nرقم العضوية: ${result['membership_id'] ?? 'N/A'}";
    } else if (type == 'expired') {
      subtitle = 'انتهت صلاحية هذه الدعوة';
    } else if (type == 'already_scanned') {
      subtitle = 'تم مسح هذه الدعوة مسبقاً';
    } else if (!success) {
      subtitle = message;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: success ? Colors.green[50] : Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: success ? Colors.green[800] : Colors.red[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: success ? Colors.green : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  "تم",
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: const ScaAppBar(
        title: "ماسح بوابة الدخول",
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (barcode) {
              if (!_isProcessing && barcode.barcodes.isNotEmpty) {
                final rawValue = barcode.barcodes.first.rawValue;
                if (rawValue != null) {
                  _processScanResult(rawValue);
                }
              }
            },
          ),
          if (_isProcessing)
            Center(
              child: CircularProgressIndicator(
                color: Colors.greenAccent,
              ),
            ),
        ],
      ),
    );
  }
}
