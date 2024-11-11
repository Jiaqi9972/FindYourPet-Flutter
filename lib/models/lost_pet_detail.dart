// For list view and detail view
class LostPetDetail {
  final String id;
  final String name;
  final String description;
  final String posterContact;
  final List<String> petImageUrls;
  final DateTime date;
  final double latitude;
  final double longitude;
  final bool lost;
  final String address; // New field for address

  LostPetDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.posterContact,
    required this.petImageUrls,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.lost,
    required this.address, // Add address to constructor
  });

  factory LostPetDetail.fromJson(Map<String, dynamic> json) {
    return LostPetDetail(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      posterContact: json['posterContact'],
      petImageUrls: List<String>.from(json['petImageUrls'] ?? []),
      date: DateTime.parse(json['date']),
      latitude: json['latitude'],
      longitude: json['longitude'],
      lost: json['lost'],
      address: json['address'] ??
          'No address available', // Safely handle missing address
    );
  }
}
