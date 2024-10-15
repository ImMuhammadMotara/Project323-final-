import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../models/surah.dart';

Widget SurahCustomListtile({
  required Surah surah,
  required BuildContext context,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3.0,
          ),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Surah Number Circle
              Container(
                alignment: Alignment.center,
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: Text(
                  (surah.number ?? '-').toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 20),

              // Surah English Name and Translation
              Expanded( // Ensure text does not overflow
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      surah.englishName ?? 'Unknown',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      surah.englishNameTranslation ?? 'Translation not available',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: 20),

              // Surah Arabic Name
              Flexible(
                child: Text(
                  surah.name ?? 'N/A',
                  style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
