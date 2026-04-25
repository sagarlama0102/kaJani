import 'package:flutter/material.dart';
import 'package:kajani/features/onbording/presentation/pages/onbording_page.dart';

class OnbordingContent extends StatelessWidget {
  final OnboardingPageData item;

  const OnbordingContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Image Section (Top Half)
        Expanded(
          flex: 5, // Adjust this to control image height
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              image: DecorationImage(
                image: AssetImage(item.imagePath),
                fit: BoxFit.contain, // Keeps the illustration proportions
              ),
            ),
          ),
        ),

        SizedBox(height: 20),

        // 2. Icon and Text Section
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                // Circular Icon (matches the screenshot)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffE9F4EE), // Light green circle
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: const Color(0xff537E67),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 25),

                // Title
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff142725),
                  ),
                ),
                const SizedBox(height: 15),

                // Description
                Text(
                  item.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
