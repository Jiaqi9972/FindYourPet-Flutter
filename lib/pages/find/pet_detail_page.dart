import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import '../../models/lost_pet_detail.dart';
import '../../api/api_service.dart';

class PetDetailPage {
  static void show(BuildContext context, String petId) {
    showCupertinoModalPopup(
      context: context,
      barrierColor: CupertinoColors.black.withOpacity(0.5),
      builder: (context) => _PetDetailSheet(petId: petId),
    );
  }
}

class _PetDetailSheet extends StatefulWidget {
  final String petId;

  const _PetDetailSheet({required this.petId});

  @override
  _PetDetailSheetState createState() => _PetDetailSheetState();
}

class _PetDetailSheetState extends State<_PetDetailSheet> {
  final ApiService _apiService = ApiService();
  LostPetDetail? _petDetail;
  bool _isLoading = true;
  final _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPetDetail();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchPetDetail() async {
    try {
      final petDetail = await _apiService.fetchLostPetDetail(widget.petId);
      if (mounted) {
        setState(() {
          _petDetail = petDetail;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching pet detail: $e');
      if (mounted) {
        _showAlert('Failed to get pet details');
      }
    }
  }

  void _showAlert(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(ThemeProvider theme) {
    final urls = _petDetail?.petImageUrls ?? [];

    if (urls.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: theme.colors.muted,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.photo,
              size: 48,
              color: theme.colors.mutedForeground,
            ),
            const SizedBox(height: 8),
            Text(
              'No images available',
              style: TextStyle(
                color: theme.colors.mutedForeground,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentImageIndex = index;
              });
            },
            itemCount: urls.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colors.border),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  urls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: theme.colors.muted,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.exclamationmark_circle,
                            color: theme.colors.mutedForeground,
                            size: 40,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Failed to load image',
                            style: TextStyle(
                              color: theme.colors.mutedForeground,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        if (urls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                urls.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentImageIndex
                        ? theme.colors.primary
                        : theme.colors.muted,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection(String title, String content, ThemeProvider theme) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.colors.mutedForeground,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: theme.colors.foreground,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildStatusBadge(ThemeProvider theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            _petDetail!.lost ? theme.colors.destructive : theme.colors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _petDetail!.lost ? 'Lost' : 'Found',
        style: TextStyle(
          color: _petDetail!.lost
              ? theme.colors.destructiveForeground
              : theme.colors.primaryForeground,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final colors = theme.colors;
    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 300) {
          Navigator.of(context).pop();
        }
      },
      child: Container(
        margin: EdgeInsets.only(top: size.height * 0.1),
        constraints: BoxConstraints(
          maxHeight: size.height * 0.85,
          minHeight: size.height * 0.3,
        ),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.of(context).pop(),
                    child: Icon(
                      CupertinoIcons.xmark,
                      color: colors.mutedForeground,
                      size: 24,
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.muted,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CupertinoActivityIndicator(
                    color: colors.foreground,
                  ),
                ),
              )
            else if (_petDetail == null)
              Expanded(
                child: Center(
                  child: Text(
                    'No details available',
                    style: TextStyle(color: colors.foreground),
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageGallery(theme),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _petDetail!.name,
                              style: TextStyle(
                                color: colors.foreground,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildStatusBadge(theme),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _formatDate(_petDetail!.date),
                        style: TextStyle(
                          color: colors.mutedForeground,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoSection(
                        'Description',
                        _petDetail!.description,
                        theme,
                      ),
                      _buildInfoSection(
                        'Location',
                        _petDetail!.address,
                        theme,
                      ),
                      _buildInfoSection(
                        'Contact',
                        _petDetail!.posterContact,
                        theme,
                      ),
                      SizedBox(height: bottomPadding + 16),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
