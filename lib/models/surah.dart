class Surah {
  final int? number;
  final String? name;
  final String? englishName;
  final String? englishNameTranslation;
  final List<String>? ayahs; // Assuming this holds the actual ayah text

  Surah({
    this.number,
    this.name,
    this.englishName,
    this.englishNameTranslation,
    this.ayahs,
  });

  // Getter to return the count of ayahs
  int get ayahCount => ayahs?.length ?? 0;

  // Add a fromJson factory if needed
  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      englishNameTranslation: json['englishNameTranslation'],
      ayahs: List<String>.from(json['ayahs'] ?? []),
    );
  }
}
