import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gdg_solution/buyer/HomePage_buy.dart';
import 'package:gdg_solution/farmer/farmer_awareness.dart';
// import 'package:gdg_solution/farmer/home_page.dart' as farmer;
import 'package:gdg_solution/farmer/listing_page.dart';
import 'package:gdg_solution/farmer/mainNav.dart' as nav;
import 'package:gdg_solution/farmer/profile.dart';
import 'package:gdg_solution/farmer/seeds_and_tools.dart';
import 'package:gdg_solution/farmer/weather.dart';
import 'package:gdg_solution/firebase_options.dart';
import 'package:gdg_solution/theme/theme.dart';
import 'package:gdg_solution/utils/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      // darkTheme: ,
      // home: HomepageBuy(username: 'sam', uniqueID: "a"),
      home: LoginPage(),
      // home: nav.MainNavigation(username: 'sam', UniqueId: "sa"),
      routes: {
        '/home_page': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, String>?;
          return nav.MainNavigation(
            username: args?['username'] ?? 'Guest',
            UniqueId: args?['role'] ?? 'Guest',
            selectedIndex: 0,
          );
        },
        '/listing_page': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, String>?;
          return ListingPage(
            username: args?['username'] ?? 'Guest',
            UniqueId: args?['UniqueId'] ?? 'Guest',
          );
        },
        '/Seeds_and_tools': (context) => SeedsAndTools(),
        '/farmer_awareness_page': (context) => FarmerAwareness(),
        '/weather_page': (context) => Weather(),
      },
    );
  }
}
