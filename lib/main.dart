// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_strings.dart';
import 'core/router/app_router.dart';
import 'core/services/market_preference_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/cart/presentation/bloc/cart_bloc.dart';
import 'features/cart/presentation/bloc/cart_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF171717),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await Supabase.initialize(
    url: AppStrings.supabaseUrl,
    anonKey: AppStrings.supabaseAnonKey,
    debug: false,
  );

  await MarketPreferenceService.load();

  runApp(const AthimartApp());
}

class AthimartApp extends StatelessWidget {
  const AthimartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc()..add(const AuthCheckStatus()),
        ),
        BlocProvider<CartBloc>(
          create: (_) => CartBloc()..add(const CartLoadRequested()),
        ),
      ],
      child: MaterialApp.router(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}