import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text('Login Screen'),
            // IconButton.filledTonal(onPressed: onPressed, icon: icon),
            IconButton.filled(
              onPressed: () {
                context.push('/signup');
              },
              icon: const Icon(Icons.app_registration),
            ),
          ],
        ),
      ),
    );
  }
}
