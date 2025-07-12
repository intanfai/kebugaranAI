// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'dart:async';

// import 'welcome_page.dart'; // pastikan ini ada nanti

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Timer ke halaman berikutnya
//     Timer(const Duration(seconds: 2), () {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const WelcomePage()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFDEE7FF),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Ganti dengan logo/animasi kamu
//             Image.asset('assets/logo.png', width: 140),
//             const SizedBox(height: 24),
//             Text(
//               "AI Prediksi Kebugaran",
//               style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF66BB6A),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
