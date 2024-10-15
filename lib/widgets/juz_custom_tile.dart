import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muslim_app_4/models/juz.dart';

class JuzCustomTile extends StatelessWidget {
  final List<JuzAyahs> list;
  final int index;

  JuzCustomTile({required this.list, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 3.0,
            ),
          ],
          borderRadius: BorderRadius.circular(8.0) // Added rounded corners
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            list[index].ayahNumber.toString(),
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            list[index].ayahsText,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            textAlign: TextAlign.end,
            softWrap: true,
          ),
          SizedBox(height: 4),
          Text(
            list[index].surahName,
            textAlign: TextAlign.end,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
