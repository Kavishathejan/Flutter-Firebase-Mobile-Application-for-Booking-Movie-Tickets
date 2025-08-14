import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/register_screen.dart';
import 'screens/seat_selection_screen.dart';
import 'screens/booking_history_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/logout_screen.dart'; // Add this import
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CinecApp());
}

class CinecApp extends StatelessWidget {
  const CinecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FirestoreService>(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'Cinec',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFF121212),
        ),
        initialRoute: '/splash',
        routes: {
          '/splash': (_) =>  SplashScreen(),
          '/entry': (_) =>  EntryPoint(),
          '/login': (_) =>  LoginScreen(),
          '/register': (_) =>  RegisterScreen(),
          '/home': (_) =>  HomeScreen(),
          '/bookingHistory': (_) => BookingHistoryScreen(),
          '/logout': (_) =>  LogoutScreen(), // Add this route
        },
        onGenerateRoute: (settings) {
          if (settings.name == SeatSelectionScreen.routeName) {
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => SeatSelectionScreen(
                movieId: args['movieId'],
                showtimeId: args['showtimeId'],
                movieTitle: args['movieTitle'],
              ),
            );
          }
          return null;
        },
      ),
    );
  }
}

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  _EntryPointState createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> {
  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return StreamBuilder(
      stream: auth.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF121212),
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFBB86FC),
              ),
            ),
          );
        }
        if (snapshot.hasData) {
          return  HomeScreen();
        } else {
          return  LoginScreen();
        }
      },
    );
  }
}