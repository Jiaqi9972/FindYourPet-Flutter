// lib/widgets/main/pet_list_view.dart
import 'package:find_your_pet/api/api_service.dart';
import 'package:find_your_pet/models/list_location_info.dart';
import 'package:find_your_pet/models/lost_pet_detail.dart';
import 'package:find_your_pet/pages/find/pet_detail_page.dart';
import 'package:find_your_pet/styles/color/app_colors_config.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PetListView extends StatefulWidget {
  final Map<String, dynamic> filters;
  final ListLocationInfo? listlocationInfo;

  const PetListView({
    super.key,
    required this.filters,
    required this.listlocationInfo,
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
    if (widget.listlocationInfo != null) {
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
        widget.listlocationInfo != oldWidget.listlocationInfo) {
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
    if (_isLoading || !_hasMore || widget.listlocationInfo == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      var pageData = await _apiService.fetchLostPetsWithPagination(
        widget.listlocationInfo!.latitude,
        widget.listlocationInfo!.longitude,
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
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final colors = AppColorsConfig.getTheme(isDarkMode);

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Error',
          style: TextStyle(color: colors.destructive),
        ),
        content: Text(
          message,
          style: TextStyle(color: colors.foreground),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'OK',
              style: TextStyle(color: colors.foreground),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _openPetDetail(String petId) {
    PetDetailPage.show(context, petId);
  }

  Widget _buildLoadingIndicator() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final colors = AppColorsConfig.getTheme(isDarkMode);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: CupertinoActivityIndicator(
          color: colors.accentForeground,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final colors = AppColorsConfig.getTheme(isDarkMode);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.paw,
            size: 48,
            color: colors.foreground,
          ),
          const SizedBox(height: 16),
          Text(
            'No pets found nearby',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.foreground,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or location',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colors.foreground,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final colors = AppColorsConfig.getTheme(isDarkMode);

    if (widget.listlocationInfo == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.location_slash,
              size: 48,
              color: colors.foreground,
            ),
            const SizedBox(height: 16),
            Text(
              'Location Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please select a location to find pets',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: colors.foreground,
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
      controller: _scrollController, // 绑定 ScrollController
      thumbVisibility: true, // 可选：显示滚动条
      child: RefreshIndicator(
        onRefresh: () async {
          _resetAndRefetch();
        },
        child: ListView.builder(
          controller: _scrollController, // 绑定相同的 ScrollController
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _pets.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _pets.length) {
              final pet = _pets[index];
              final imageUrl =
                  pet.petImageUrls.isNotEmpty ? pet.petImageUrls.first : null;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: colors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _openPetDetail(pet.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display the first image or a placeholder
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: imageUrl != null
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                height: 200,
                                width: double.infinity,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildImagePlaceholder();
                                },
                              )
                            : _buildImagePlaceholder(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Name aligned to the left
                                Expanded(
                                  child: Text(
                                    pet.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colors.foreground,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Spacer to push the badge to the right
                                const Spacer(),
                                // Badge aligned to the right
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: pet.lost
                                        ? colors.destructive
                                        : colors.primary,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    pet.lost ? 'Lost' : 'Found',
                                    style: TextStyle(
                                      color: pet.lost
                                          ? colors.destructiveForeground
                                          : colors.primaryForeground,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              pet.description,
                              style: TextStyle(
                                fontSize: 14,
                                color: colors.secondaryForeground,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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

  Widget _buildImagePlaceholder() {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final colors = AppColorsConfig.getTheme(isDarkMode);

    return Container(
      height: 200,
      color: colors.muted,
      child: Icon(
        CupertinoIcons.photo,
        size: 48,
        color: colors.mutedForeground,
      ),
    );
  }
}
