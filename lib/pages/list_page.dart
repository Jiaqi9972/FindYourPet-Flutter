import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import '../models/lost_pet_detail.dart';
import '../api/api_service.dart';
import 'pet_detail_page.dart';
import '../widgets/pet_item_widget.dart';

class ListPage extends StatefulWidget {
  final String searchQuery;
  final Map<String, dynamic> filters;
  final ScrollController scrollController;
  final Position? currentPosition;

  const ListPage({
    super.key,
    required this.searchQuery,
    required this.filters,
    required this.scrollController,
    required this.currentPosition,
  });

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final ApiService _apiService = ApiService();
  final List<LostPetDetail> _pets = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;
  Position? _currentPosition;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.currentPosition;
    _fetchPets();
  }

  @override
  void didUpdateWidget(covariant ListPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPosition != oldWidget.currentPosition ||
        widget.filters != oldWidget.filters) {
      _currentPosition = widget.currentPosition;
      _currentPage = 0;
      _pets.clear();
      _hasMore = true;
      _fetchPets();
    }
  }

  void _fetchPets() async {
    if (_isLoading || !_hasMore || _currentPosition == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      double latitude = _currentPosition!.latitude;
      double longitude = _currentPosition!.longitude;
      double radiusInMiles = widget.filters['radiusInMiles'] ?? 5.0;
      bool? lost = widget.filters['lost'];

      var pageData = await _apiService.fetchLostPetsWithPagination(
        latitude,
        longitude,
        radiusInMiles,
        _currentPage,
        10,
        lost,
      );

      if (mounted) {
        setState(() {
          _pets.addAll(pageData.items);
          _hasMore = pageData.hasMore;
          _currentPage++;
        });
      }
    } catch (e) {
      print('Error fetching pets: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _onScrollEnd() {
    if (!_isLoading && _hasMore) {
      _fetchPets();
    }
  }

  void _openPetDetailPage(String petId) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PetDetailPage(petId: petId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!_isLoading &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          _onScrollEnd();
        }
        return false;
      },
      child: CupertinoScrollbar(
        controller: widget.scrollController,
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: ListView.builder(
            controller: widget.scrollController,
            itemCount: _pets.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < _pets.length) {
                return PetItemWidget(
                  pet: _pets[index], // Using LostPetDetail
                  onTap: () => _openPetDetailPage(_pets[index].id),
                );
              } else if (_hasMore) {
                return const CupertinoActivityIndicator();
              } else {
                return Container();
              }
            },
          ),
        ),
      ),
    );
  }
}
