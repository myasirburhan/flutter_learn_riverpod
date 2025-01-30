import 'package:flutter_learn_riverpod/core/route/route_name.dart';
import 'package:flutter_learn_riverpod/features/login/presentation/ui/login_screen.dart';
import 'package:flutter_learn_riverpod/features/signup/presentation/ui/signup_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final goRouterProvider = Provider<GoRouter>(
  (ref) {
    return GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          name: loginRoute,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          name: signUpRoute,
          builder: (context, state) => const SignupScreen(),
        ),
      ],
    );
  },
);
