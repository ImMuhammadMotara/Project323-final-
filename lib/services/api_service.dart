import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:muslim_app_4/models/aya_of_the_day.dart';
import 'package:muslim_app_4/models/juz.dart';
import 'package:muslim_app_4/models/surah.dart';

class ApiServices {

  final String endPointUrl = "https://api.alquran.cloud/v1/surah"; // Changed to HTTPS
  List<Surah> list = [];

  // Random Ayah of the Day
  Future<AyaOfTheDay> getAyaOfTheDay() async {
    // Get a random Ayah number between 1 and 6236 (there are 6236 Ayahs in the Quran)
    String url = "https://api.alquran.cloud/v1/ayah/${random(1, 6236)}/editions/quran-uthmani,en.asad,en.pickthall"; // Changed to HTTPS
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return AyaOfTheDay.fromJSON(jsonDecode(response.body));
    } else {
      print("Failed to load Aya of the Day. Status code: ${response.statusCode}");
      throw Exception("Failed to load Aya of the Day");
    }
  }

  // Helper function to generate a random number
  int random(int min, int max) {
    var rn = Random();
    return min + rn.nextInt(max - min);
  }

  // Fetch Surah List from API
  Future<List<Surah>> getSurah() async {
    final response = await http.get(Uri.parse(endPointUrl));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);
      list.clear(); // Clear the list to avoid duplication

      json['data'].forEach((element) {
        list.add(Surah.fromJson(element));
      });

      print('Loaded ${list.length} Surahs'); // Debug print for list length
      return list;
    } else {
      print('Failed to load Surahs. Status code: ${response.statusCode}');
      throw Exception("Failed to load Surahs");
    }
  }

  // Fetch Juz based on the index
  Future<JuzModel> getJuz(int juzIndex) async {
    String url = "https://api.alquran.cloud/v1/juz/$juzIndex/quran-uthmani"; // Changed to HTTPS
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return JuzModel.fromJSON(json.decode(response.body));
    } else {
      print("Failed to load Juz. Status code: ${response.statusCode}");
      throw Exception("Failed to load Juz");
    }
  }
}
