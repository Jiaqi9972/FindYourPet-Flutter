import 'package:dio/dio.dart';
import 'package:find_your_pet/models/lost_pet.dart';
import 'package:find_your_pet/models/lost_pet_detail.dart';
import 'package:find_your_pet/models/pagination.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = "http://165.1.64.212/api/v1";

  // Fetch pets for map (returns LostPet for summary)
  Future<List<LostPet>> fetchLostPetsForMap(double latitude, double longitude,
      double radiusInMiles, bool? lost) async {
    final queryParameters = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radiusInMiles': radiusInMiles.toString(),
    };

    if (lost != null) {
      queryParameters['lost'] = lost.toString();
    }

    final url = '$baseUrl/search/lost-pets/map';

    try {
      final response = await _dio.get(url, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is List) {
          return data.map((item) => LostPet.fromJson(item)).toList();
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        throw Exception('Failed to load pets for map');
      }
    } catch (e) {
      print('Error fetching pets for map: $e');
      throw Exception('Error fetching pets for map');
    }
  }

  // Fetch pets with pagination (List view returns LostPetDetail)
  Future<Pagination<LostPetDetail>> fetchLostPetsWithPagination(
      double latitude,
      double longitude,
      double radiusInMiles,
      int page,
      int size,
      bool? lost) async {
    final queryParameters = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radiusInMiles': radiusInMiles.toString(),
      'page': page.toString(),
      'size': size.toString(),
    };

    if (lost != null) {
      queryParameters['lost'] = lost.toString();
    }

    final url = '$baseUrl/search/lost-pets/list';

    print(queryParameters);

    try {
      final response = await _dio.get(url, queryParameters: queryParameters);

      if (response.statusCode == 200) {
        final responseData = response.data;
        final data = responseData['data'];

        if (data != null && data is Map<String, dynamic>) {
          final List<dynamic> content = data['content'] ?? [];

          // Use LostPetDetail for the detailed information in the list view
          List<LostPetDetail> items =
              content.map((item) => LostPetDetail.fromJson(item)).toList();

          // Determine if there are more pages
          bool hasMore = !(data['last'] as bool? ?? true);

          return Pagination<LostPetDetail>(
            items: items,
            hasMore: hasMore,
          );
        } else {
          throw Exception('Unexpected data format');
        }
      } else {
        throw Exception('Failed to load pets for list');
      }
    } catch (e) {
      print('Error fetching pets for list: $e');
      throw Exception('Error fetching pets for list');
    }
  }

  // Fetch pet details
  Future<LostPetDetail> fetchLostPetDetail(String id) async {
    final url = '$baseUrl/search/lost-pets/detail/$id';

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data['data'];
        return LostPetDetail.fromJson(data);
      } else {
        throw Exception('Failed to load pet detail');
      }
    } catch (e) {
      print('Error fetching pet detail: $e');
      throw Exception('Error fetching pet detail');
    }
  }

  // Save lost pet
  Future<void> saveLostPet(String idToken, Map<String, dynamic> data) async {
    final url = '$baseUrl/pets/lost';

    try {
      final response = await _dio.post(
        url,
        data: data,
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Pet saved successfully");
      } else {
        throw Exception('Failed to submit data: ${response.statusMessage}');
      }
    } catch (e) {
      print('Error submitting data: $e');
      throw Exception('Error submitting data');
    }
  }

  // Login user
  Future<Map<String, dynamic>> loginUser(String idToken) async {
    final url = '$baseUrl/users/login';

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        print("User logged in successfully");
        return response.data['data'];
      } else {
        print("Failed to log in user: ${response.data}");
        throw Exception("Failed to log in user");
      }
    } catch (e) {
      print("Error during login API call: $e");
      throw Exception("Failed to log in user");
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(String idToken) async {
    final url = '$baseUrl/users/login';

    try {
      final response = await _dio.post(
        url,
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode == 200 && response.data['data'] != null) {
        return response.data['data'];
      } else {
        throw Exception("Failed to load user profile");
      }
    } catch (e) {
      print("Error during profile API call: $e");
      throw Exception("Failed to load user profile");
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      String name, String avatarUrl, String idToken) async {
    final url = '$baseUrl/users/updateInfo';

    try {
      final response = await _dio.post(
        url,
        data: {
          'name': name,
          'avatarUrl': avatarUrl,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );

      if (response.statusCode == 200) {
        print("User profile updated successfully");
      } else {
        print("Failed to update profile: ${response.data}");
        throw Exception("Failed to update profile");
      }
    } catch (e) {
      print("Error during update profile API call: $e");
      throw Exception("Failed to update profile");
    }
  }
}
