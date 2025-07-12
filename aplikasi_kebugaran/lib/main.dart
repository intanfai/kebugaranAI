import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'welcome_page.dart';

void main() {
  runApp(const KebugaranApp());
}

class KebugaranApp extends StatelessWidget {
  const KebugaranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Prediksi Kebugaran',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFE0F2F1),
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF66BB6A)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFF66BB6A), // warna hijau sesuai tema
              width: 2,
            ),
          ),
        ),

        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF66BB6A),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 6,
            shadowColor: Colors.greenAccent,
          ),
        ),
      ),
      home: const WelcomePage(),
    );
  }
}

class PrediksiPage extends StatefulWidget {
  const PrediksiPage({super.key});

  @override
  State<PrediksiPage> createState() => _PrediksiPageState();
}

class _PrediksiPageState extends State<PrediksiPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController olahragaController = TextEditingController();
  final TextEditingController tidurController = TextEditingController();
  final TextEditingController airController = TextEditingController();

  String hasil = '';
  String saran = '';
  String rekomendasi = '';

  List<Map<String, dynamic>> grafikMingguan = List.generate(
    7,
    (i) => {
      'hari': ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][i],
      'nilai': 60,
    },
  );

  @override
  void initState() {
    super.initState();
    _loadGrafik();
  }

  Future<void> _loadGrafik() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('grafik') ?? '';
    if (data.isNotEmpty) {
      final List list = jsonDecode(data);
      setState(() {
        grafikMingguan = List<Map<String, dynamic>>.from(list);
      });
    }
  }

  Future<void> _saveGrafik() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('grafik', jsonEncode(grafikMingguan));
  }

  Future<void> kirimData() async {
    if (!_formKey.currentState!.validate()) return;

    final url = Uri.parse('http://172.20.10.4:5000/predict');
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "Olahraga (menit)": int.tryParse(olahragaController.text) ?? 0,
        "Jam Tidur": double.tryParse(tidurController.text) ?? 0,
        "Minum Air (liter)": double.tryParse(airController.text) ?? 0,
      }),
    );

    if (response.statusCode == 200) {
      print("Status 200 OK");
      print("Body response: ${response.body}");

      try {
        final result = jsonDecode(response.body);
        print("Parsed result: $result");

        setState(() {
          hasil = result['prediksi'] ?? '-';
          saran = result['saran'] ?? '-';
          rekomendasi = _generateRekomendasi(hasil);
        });

        _updateGrafik(hasil);
      } catch (e) {
        print("Gagal parsing response: $e");
        setState(() {
          hasil = "Terjadi kesalahan parsing data.";
          saran = "";
          rekomendasi = "";
        });
      }
    } else {
      setState(() {
        hasil = "Gagal prediksi";
        saran = "Periksa koneksi ke server Flask";
        rekomendasi = '';
      });
    }
  }

  void _updateGrafik(String hasil) {
    int nilai;
    switch (hasil.toLowerCase()) {
      case 'bugar':
        nilai = 90;
        break;
      case 'cukup':
        nilai = 70;
        break;
      case 'kurang bugar':
        nilai = 50;
        break;
      default:
        nilai = 60;
    }
    final now = DateTime.now();
    final int index = (now.weekday % 7);
    setState(() {
      grafikMingguan[index]['nilai'] = nilai;
    });
    _saveGrafik();
  }

  Color _getColorHasil(String hasil) {
    switch (hasil.toLowerCase()) {
      case 'bugar':
        return Colors.green;
      case 'cukup':
        return Colors.orange;
      case 'kurang bugar':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _generateRekomendasi(String hasil) {
    switch (hasil.toLowerCase()) {
      case 'bugar':
        return "Keren! Kamu berada dalam kondisi bugar. Terus jaga konsistensi gaya hidup sehat ini. "
            "Tetap aktif secara fisik, cukupi kebutuhan air harian, dan pertahankan pola tidur berkualitas. "
            "Jangan lupa kelola stres agar kebugaran tetap optimal jangka panjang. Kamu di jalur yang tepat! 🚀";
      case 'cukup':
        return "Kebugaranmu tergolong cukup, namun masih ada ruang untuk perbaikan. "
            "Pertahankan rutinitas sehat yang sudah kamu lakukan. Coba tidur lebih teratur dan konsisten, "
            "serta tingkatkan intensitas olahraga secara bertahap. Keseimbangan antara aktivitas dan istirahat "
            "akan membantu menjaga performa tubuh.";
      case 'kurang bugar':
        return "Kondisi tubuhmu menunjukkan tanda-tanda kurang bugar. Coba tingkatkan aktivitas fisik secara bertahap, "
            "seperti menambahkan 10–15 menit olahraga ringan setiap hari, memperbanyak konsumsi air putih, dan tidur cukup minimal 7 jam. "
            "Jaga pola makan dengan nutrisi seimbang untuk mendukung kebugaranmu.";
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFF66BB6A)),
                child: Center(
                  child: Text(
                    "Prediksi Kebugaran AI",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "✍️ Catat Aktivitas Harianmu",
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Bantu AI mengenali pola hidupmu dengan mengisi data berikut.",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 24),
                      TextFormField(
                        controller: olahragaController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Olahraga (menit)",
                          prefixIcon: Icon(Icons.directions_run),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null) {
                            return 'Harus angka!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: tidurController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Jam Tidur",
                          prefixIcon: Icon(Icons.bedtime),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              double.tryParse(value) == null) {
                            return 'Harus angka!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: airController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Minum Air (liter)",
                          prefixIcon: Icon(Icons.local_drink),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              double.tryParse(value) == null) {
                            return 'Harus angka!';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: kirimData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF66BB6A),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(
                            Icons.analytics_outlined,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Prediksi Sekarang",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (hasil.isNotEmpty) ...[
                        Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: _getColorHasil(hasil),
                              width: 2,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.insights,
                                      color: _getColorHasil(hasil),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Hasil Prediksi",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  hasil,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: _getColorHasil(hasil),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.lightbulb_outline,
                                      color: Colors.orange,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Saran",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(saran),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.recommend,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Rekomendasi Lengkap",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(rekomendasi),
                              ],
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                      Text(
                        "📊 Perkembangan Kebugaran Kamu",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Pantau seberapa bugar kamu setiap hari selama seminggu terakhir berdasarkan hasil prediksi.",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 12),
                      SizedBox(
                        height: 240,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: LineChart(
                            LineChartData(
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 32,
                                    interval: 1,
                                    getTitlesWidget: (value, _) {
                                      final hari = [
                                        'Sen',
                                        'Sel',
                                        'Rab',
                                        'Kam',
                                        'Jum',
                                        'Sab',
                                        'Min',
                                      ];
                                      if (value.toInt() >= 0 &&
                                          value.toInt() < hari.length) {
                                        return Text(hari[value.toInt()]);
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 20,
                                    reservedSize: 32,
                                    getTitlesWidget: (value, _) =>
                                        Text('${value.toInt()}'),
                                  ),
                                ),
                              ),
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: true),
                              minX: 0,
                              maxX: 6,
                              minY: 0,
                              maxY: 100,
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  color: Color(0xFF66BB6A),
                                  dotData: FlDotData(show: true),
                                  belowBarData: BarAreaData(show: false),
                                  spots: List.generate(
                                    grafikMingguan.length,
                                    (i) => FlSpot(
                                      i.toDouble(),
                                      grafikMingguan[i]['nilai'].toDouble(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
