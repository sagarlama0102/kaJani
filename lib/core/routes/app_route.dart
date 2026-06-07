// import 'package:flutter/material.dart';
// import 'package:rentease/features/dashboard/presentation/pages/property_details_screen.dart';

// class AppRoute {
//   // Define route name constants to prevent typos
//   static const String propertyDetailRoute = '/property_details';

//   static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
//     switch (settings.name) {
      
//       case propertyDetailRoute:
//         final String propertyId = settings.arguments as String;
//         return MaterialPageRoute(
//           builder: (context) => PropertyDetailScreen(propertyId: propertyId),
//         );

//       // Add future routes here (e.g., login, profile, etc.)
//       // case loginRoute: ...

//       default:
//         return _errorRoute();
//     }
//   }

//   static Route<dynamic> _errorRoute() {
//     return MaterialPageRoute(
//       builder: (context) => const Scaffold(
//         body: Center(child: Text("Route not found!")),
//       ),
//     );
//   }
// }