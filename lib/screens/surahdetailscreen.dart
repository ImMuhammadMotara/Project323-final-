import 'package:flutter/material.dart';
import 'package:muslim_app_4/models/surah.dart';

class SurahDetailScreen extends StatelessWidget {
  final Surah surah;

  const SurahDetailScreen({Key? key, required this.surah}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(surah.englishName ?? 'Surah Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              surah.name ?? 'N/A',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Translation: ${surah.englishNameTranslation ?? 'N/A'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 8),
            Text(
              'Number of Ayahs: ${surah.ayahCount.toString()}', // Using the new ayahCount getter
              style: TextStyle(fontSize: 18),
            ),
            // Add more details as needed
          ],
        ),
      ),
    );
  }
}
