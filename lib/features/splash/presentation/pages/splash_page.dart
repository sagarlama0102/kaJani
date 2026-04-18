import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: 
                  AssetImage('assets/kajanilogo.png'),
                  fit: BoxFit.contain
                ),
                )
              )
            ],
          ),
        )),
    );
  }
}
