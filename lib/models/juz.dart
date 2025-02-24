
class JuzModel{
  final int juzNumber;
  final List<JuzAyahs>juzAyahs;

  JuzModel({required this.juzAyahs, required this.juzNumber});

  factory JuzModel.fromJSON(Map<String, dynamic> json)
  {
    Iterable juzAyahs = json['data']['ayahs'];
    List<JuzAyahs> juzAyahsList =
    juzAyahs.map((e) => JuzAyahs.fromJson(e)).toList();

    return JuzModel(juzAyahs: juzAyahsList, juzNumber: json['data']['number']);

  }


}

class JuzAyahs{
  final String ayahsText;
  final int ayahNumber;
  final String surahName;

  JuzAyahs({required this.ayahsText, required this.surahName, required this.ayahNumber});

  factory JuzAyahs.fromJson(Map<String, dynamic> json){
    return JuzAyahs(
        ayahsText: json['text'],
        surahName: json['surah']['name'],
        ayahNumber: json['number']
    );
  }
}
