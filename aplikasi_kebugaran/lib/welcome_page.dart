import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart'; // Tambahkan di pubspec.yaml
import 'main.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDEE7FF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animasi masuk ikon
              const Icon(
                Icons.fitness_center,
                size: 120,
                color: Color(0xFF66BB6A),
              ).animate().fadeIn(duration: 500.ms).scale(),

              const SizedBox(height: 36),

              Text(
                "Selamat Datang di Aplikasi AI Prediksi Kebugaran!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF66BB6A),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 20),

              Text(
                "Dapatkan prediksi kebugaran harian dan saran gaya hidup sehat hanya dalam satu klik!",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrediksiPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF66BB6A),
                    elevation: 6,
                    shadowColor: Color(0xFF66BB6A).withOpacity(0.4),
                    padding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 32,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "Mulai Sekarang",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
