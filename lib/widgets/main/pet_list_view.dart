// lib/widgets/main/pet_list_view.dart
import 'package:find_your_pet/api/api_service.dart';
import 'package:find_your_pet/models/location_info.dart';
import 'package:find_your_pet/models/lost_pet_detail.dart';
import 'package:find_your_pet/pages/main/pet_detail_page.dart';
import 'package:find_your_pet/widgets/pet_item_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';

class PetListView extends StatefulWidget {
  final Map<String, dynamic> filters;
  final LocationInfo? locationInfo;

  const PetListView({
    super.key,
    required this.filters,
    required this.locationInfo,
  });

  @override
  _PetListViewState createState() => _PetListViewState();
}

class _PetListViewState extends State<PetListView> {
  final ApiService _apiService = ApiService();
  final List<LostPetDetail> _pets = [];
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.locationInfo != null) {
      _fetchPets();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(PetListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.filters != oldWidget.filters ||
        widget.locationInfo != oldWidget.locationInfo) {
      _resetAndRefetch();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _fetchPets();
    }
  }

  void _resetAndRefetch() {
    setState(() {
      _pets.clear();
      _currentPage = 0;
      _hasMore = true;
    });
    _fetchPets();
  }

  Future<void> _fetchPets() async {
    if (_isLoading || !_hasMore || widget.locationInfo == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var pageData = await _apiService.fetchLostPetsWithPagination(
        widget.locationInfo!.latitude,
        widget.locationInfo!.longitude,
        widget.filters['radiusInMiles'],
        _currentPage,
        10,
        widget.filters['lost'],
      );

      if (mounted) {
        setState(() {
          _pets.addAll(pageData.items);
          _hasMore = pageData.hasMore;
          _currentPage++;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching pets: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      _showError('Failed to load pets');
    }
  }

  void _showError(String message) {
    final theme = context.read<ThemeProvider>();
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Error',
          style: TextStyle(color: theme.colors.destructive),
        ),
        content: Text(
          message,
          style: TextStyle(color: theme.colors.foreground),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'OK',
              style: TextStyle(color: theme.colors.foreground),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _openPetDetail(String petId) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => PetDetailPage(petId: petId),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    final theme = context.read<ThemeProvider>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CupertinoActivityIndicator(
          color: theme.colors.accentForeground,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = context.watch<ThemeProvider>();
    final themeData = theme.getAppTheme();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.paw,
            size: 48,
            color: theme.colors.foreground,
          ),
          const SizedBox(height: 16),
          Text(
            'No pets found nearby',
            style: themeData.textTheme.navTitleTextStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or location',
            style: themeData.textTheme.textStyle.copyWith(
              color: theme.colors.secondaryForeground,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    if (widget.locationInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.location_slash,
              size: 48,
              color: theme.colors.foreground,
            ),
            const SizedBox(height: 16),
            Text(
              'Location Required',
              style: theme.getAppTheme().textTheme.navTitleTextStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Please select a location to find pets',
              style: theme.getAppTheme().textTheme.textStyle.copyWith(
                    color: theme.colors.secondaryForeground,
                  ),
            ),
          ],
        ),
      );
    }

    if (_pets.isEmpty && !_isLoading) {
      return _buildEmptyState();
    }

    return CupertinoScrollbar(
      child: RefreshIndicator(
        onRefresh: () async {
          _resetAndRefetch();
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _pets.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _pets.length) {
              return PetItemWidget(
                pet: _pets[index],
                onTap: () => _openPetDetail(_pets[index].id),
              );
            } else if (_hasMore) {
              return _buildLoadingIndicator();
            }
            return null;
          },
        ),
      ),
    );
  }
}
