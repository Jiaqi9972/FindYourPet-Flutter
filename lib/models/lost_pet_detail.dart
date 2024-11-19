// lib/models/lost_pet_detail.dart
class LostPetDetail {
  final String id;
  final String name;
  final String description;
  final String posterContact;
  final double latitude;
  final double longitude;
  final String address;
  final bool lost;
  final List<String> petImageUrls;
  final DateTime date;

  LostPetDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.posterContact,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.lost,
    required this.petImageUrls,
    required this.date,
  });

  factory LostPetDetail.fromJson(Map<String, dynamic> json) {
    return LostPetDetail(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      posterContact: json['posterContact'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
      lost: json['lost'],
      petImageUrls: List<String>.from(json['petImageUrls'] ?? []),
      date: DateTime.parse(json['date']),
    );
  }
}
