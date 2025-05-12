class Dashbord {
  final String totalPrixTTC;
  final String totalTTcVente;
  final String sumTva;
  Dashbord({
    required this.totalPrixTTC,
    required this.totalTTcVente,
    required this.sumTva,
  });

  factory Dashbord.fromJson(Map<dynamic, dynamic> json) {
    return Dashbord(
      totalPrixTTC: json['totalPrixTTC'],
      totalTTcVente: json['totalTTcVente'],
      sumTva: json['sumTva'],
    );
  }
}
