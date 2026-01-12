import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/firestore_service.dart';
import 'cubits/membership_cubit.dart';
import 'screens/lookup_screen.dart';

// --- THE SAMPLE DATA ---
// Defined as a global constant Map to avoid syntax errors in main()
final Map<String, dynamic> mySampleData = {
  "main_membership": {
    "1036711": {
      "membership_id": "1036711",
      "membership_type": "هيئة",
      "name": "أحمد بدر خميس أحمد",
      "job": "مهندس مساعد مدير أعمال",
      "mobile_number": "01280017104",
      "marital_status": "متزوج",
      "national_id": "29001260100691",
      "membership_status": "سارية",
      "card_expiry_date": "2026-12-31",
      "dependents": 3,
      "photoUrl": "https://placehold.co/300x300.png?text=Main+Member",
      "memberships": {
        "beach": true,
        "golf": true,
        "yacht": true,
        "tennis": true,
        "knighthood": true,
        "rowing": true,
      },
      "wives": {
        "1": {
          "wife_id": "1",
          "name": "منة الله أشرف",
          "gender": "أنثى",
          "card_status": "يصدر",
          "photoUrl": "https://placehold.co/300x300.png?text=Wife",
        },
      },
      "children": {
        "1": {
          "child_id": "1",
          "name": "بدر الدين أحمد بدر خميس",
          "gender": "ذكر",
          "card_status": "يصدر",
          "photoUrl": "https://placehold.co/300x300.png?text=Child",
        },
        "2": {
          "child_id": "2",
          "name": "عبدالرحمن أحمد بدر خميس",
          "gender": "ذكر",
          "card_status": "يصدر",
          "photoUrl": "https://placehold.co/300x300.png?text=Child",
        },
      },
    },
  },
};

void main() async {
  // Ensure Flutter engine is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("--- [DEBUG]: Firebase Connected Successfully ---");

  // TRIGGER DATA UPLOAD (Uncomment the line below to seed Firestore)
  try {
    final firestoreService = FirestoreService();
    // await firestoreService.uploadSampleData(mySampleData);
    debugPrint("--- [SUCCESS]: Sample data uploaded to Firestore! ---");
  } catch (e) {
    debugPrint("--- [ERROR]: Failed to upload data: $e ---");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide the Cubit globally so it's accessible from LookupScreen
        BlocProvider(create: (context) => MembershipCubit(FirestoreService())),
      ],
      child: MaterialApp(
        title: 'النادي العام - نظام العضوية',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LookupScreen(),
      ),
    );
  }
}
