import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/product_viewmodel.dart';
import 'views/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiService();

    // We create ApiService once and inject it into both ViewModels.
    // Provider makes the ViewModels available to every screen below.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel(api)),
        ChangeNotifierProvider(create: (_) => ProductViewModel(api)),
      ],
      child: MaterialApp(
        title: 'DarazClone',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: const Color(0xFFE4572E),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
