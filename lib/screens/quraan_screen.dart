import 'package:flutter/material.dart';
import 'package:muslim_app_4/constants/constants.dart';
import 'package:muslim_app_4/services/api_service.dart';
import 'package:muslim_app_4/widgets/juz_custom_tile.dart';
import 'package:muslim_app_4/widgets/surah_custom_tile.dart';
import '../models/juz.dart';
import '../models/surah.dart';
import '../screens/surahdetailscreen.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:get/get.dart';

class QuraanScreen extends StatefulWidget {
  const QuraanScreen({Key? key}) : super(key: key);

  @override
  _QuraanScreenState createState() => _QuraanScreenState();
}

class _QuraanScreenState extends State<QuraanScreen> with SingleTickerProviderStateMixin {
  final ApiServices apiServices = ApiServices();
  late TabController _tabController;
  int _selectedIndex = 1; // Default index for Quran tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedIndex = _tabController.index; // Sync the selected index
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose(); // Dispose the TabController when no longer needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quran'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController, // Set the TabController
            tabs: const [
              Tab(text: 'Surah'),
              Tab(text: 'Juz'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController, // Set the TabController
          children: [
            const SurahTab(),
            const JuzTab(),
          ],
        ),
        bottomNavigationBar: ConvexAppBar(
          items: const [
            TabItem(icon: Icons.home, title: 'Home'),
            TabItem(icon: Icons.book, title: 'Quran'),
            TabItem(icon: Icons.access_time, title: 'Prayer Times'),
            TabItem(icon: Icons.location_on, title: 'Map'),
          ],
          initialActiveIndex: _selectedIndex, // This can be used now
          onTap: (index) {
            _onTabTapped(index); // Navigate to the selected tab
          },
          backgroundColor: Colors.blue,
          activeColor: Colors.white,
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    switch (index) {
      case 0:
        Get.offNamed('/home'); // Navigate to Home screen
        break;
      case 1:
        Get.offNamed('/quran'); // Stay on Quran screen
        break;
      case 2:
        Get.offNamed('/prayer'); // Navigate to Prayer Times screen
        break;
      case 3:
        Get.offNamed('/map'); // Navigate to Map screen
        break;
    }
  }
}

// SurahTab Implementation remains the same
class SurahTab extends StatelessWidget {
  const SurahTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ApiServices apiServices = ApiServices();

    return FutureBuilder<List<Surah>>(
      future: apiServices.getSurah(),
      builder: (BuildContext context, AsyncSnapshot<List<Surah>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data != null) {
          final List<Surah> surahList = snapshot.data!;
          return ListView.builder(
            itemCount: surahList.length,
            itemBuilder: (context, index) {
              return SurahCustomListtile(
                surah: surahList[index],
                context: context,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SurahDetailScreen(surah: surahList[index]),
                    ),
                  );
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return const Center(child: Text('No data found'));
        }
      },
    );
  }
}

// JuzTab Implementation remains the same
class JuzTab extends StatelessWidget {
  const JuzTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ApiServices apiServices = ApiServices();

    return FutureBuilder<JuzModel>(
      future: apiServices.getJuz(Constants.juzIndex ?? 1),
      builder: (BuildContext context, AsyncSnapshot<JuzModel> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData && snapshot.data != null) {
          final List<JuzAyahs> juzAyahs = snapshot.data!.juzAyahs;
          return ListView.builder(
            itemCount: juzAyahs.length,
            itemBuilder: (context, index) {
              return JuzCustomTile(
                list: juzAyahs,
                index: index,
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return const Center(child: Text('No data found'));
        }
      },
    );
  }
}
