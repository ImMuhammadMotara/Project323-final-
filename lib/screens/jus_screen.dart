import 'package:flutter/material.dart';
import 'package:muslim_app_4/constants/constants.dart';

import '../models/juz.dart';
import '../services/api_service.dart';
import '../widgets/juz_custom_tile.dart';

class JuzScreen extends StatelessWidget {
  static const String id = 'juz_screen';

  ApiServices apiServices = ApiServices();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder<JuzModel>(
          future: apiServices.getJuz(Constants.juzIndex!),
          builder: (context, AsyncSnapshot<JuzModel> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasData) {
              print('${snapshot.data!.juzAyahs.length} Length');
              return ListView.builder(
                itemCount: snapshot.data!.juzAyahs.length,
                itemBuilder: (context, index) {
                  return JuzCustomTile(
                    list: snapshot.data!.juzAyahs,
                    index: index,
                  );
                },
              ); // Removed extra semicolon here
            } else if (snapshot.hasError) {
              // In case of error, handle error scenario
              return Center(
                child: Text('An error occurred: ${snapshot.error}'),
              );
            } else {
              return Center(
                child: Text('Data not found'),
              );
            }
          },
        ),
      ),
    );
  }
}
