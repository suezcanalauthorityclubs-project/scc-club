import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'services/database_service.dart';
import 'logic/member_bloc.dart';
import 'logic/member_event.dart';
import 'logic/member_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SuezCanalClubApp());
}

class SuezCanalClubApp extends StatelessWidget {
  const SuezCanalClubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => DatabaseService(),
      child: BlocProvider(
        create: (context) => MemberBloc(context.read<DatabaseService>()),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
          home: const Scaffold(body: Center(child: Text("تم إعداد الهيكل بنجاح"))),
        ),
      ),
    );
  }
}