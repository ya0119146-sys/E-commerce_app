import 'package:flutter/material.dart';

/// Simple branded splash while checking auth status.
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Labella',
              style: TextStyle(
                fontFamily: 'GreatVibes',
                fontSize: 48,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            // const SizedBox(height: 24),
            // SizedBox(
            //   width: 28,
            //   height: 28,
            //   child: CircularProgressIndicator(
            //     strokeWidth: 2.5,
            //     valueColor: AlwaysStoppedAnimation(
            //       Theme.of(context).colorScheme.primary,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
