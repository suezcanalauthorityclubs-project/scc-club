import 'package:flutter/material.dart';
import 'package:sca_members_clubs/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("سجل المدفوعات"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            // List
            ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: payments.length,
  itemBuilder: (context, index) {
    final payment = payments[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            payment.isPaid ? Icons.check_circle : Icons.hourglass_top,
            color: payment.isPaid ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.title),
                Text(payment.date),
              ],
            ),
          ),
          Text("${payment.amount} ج.م"),
        ],
      ),
    );
  },
)
          ],
        ),
      ),
    );
  }
}


class PaymentModel {
  final String title;
  final String date;
  final double amount;
  final bool isPaid;

  PaymentModel({
    required this.title,
    required this.date,
    required this.amount,
    required this.isPaid,
  });
}

final List<PaymentModel> payments = [
  PaymentModel(
    title: "تجديد اشتراك سنوي ",
    date: "01/01/2026",
    amount: 240,
    isPaid: true,
  )
  , PaymentModel(
    title: "  حجز فوتو سيشن",
    date: "15/12/2025",
    amount: 500,
    isPaid: true,
  ),

  PaymentModel(
    title: "  حجز قاعة مناسبات - الدنفاه",
    date: "01/12/2025",
    amount: 2000,
    isPaid: false,
  ),
  PaymentModel(
    title: " تجديد اشتراك سنوي ",
    date: "1/1/2025",
    amount: 240,
    isPaid: true,
  ),
  PaymentModel(
    title: " حجز قاعة مناسبات - اليخت",
    date: "13/6/2024",
    amount: 2000,
    isPaid: true,
  ),
];
