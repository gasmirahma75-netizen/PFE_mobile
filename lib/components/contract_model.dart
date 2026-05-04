class Contract {
  final int id;
  final String objet;
  final double montant;
  final String dateEffet;

  Contract({required this.id, required this.objet, required this.montant, required this.dateEffet});

  // Transforme le JSON du backend en objet Dart
  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'],
      objet: json['objet'] ?? 'Sans objet',
      montant: double.tryParse(json['montant'].toString()) ?? 0.0,
      dateEffet: json['date_effet'] ?? '',
    );
  }
}