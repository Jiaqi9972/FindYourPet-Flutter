// For map summary view
class LostPet {
  final String id;
  final String name;
  final String? petImageUrl;
  final double latitude;
  final double longitude;
  final bool lost;

  LostPet({
    required this.id,
    required this.name,
    this.petImageUrl,
    required this.latitude,
    required this.longitude,
    required this.lost,
  });

  factory LostPet.fromJson(Map<String, dynamic> json) {
    return LostPet(
      id: json['id'],
      name: json['name'],
      petImageUrl: json['petImageUrl'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      lost: json['lost'],
    );
  }
}
