// lib/pages/main/pet_detail_page.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import '../../models/lost_pet_detail.dart';
import '../../api/api_service.dart';

class PetDetailPage extends StatefulWidget {
  final String petId;

  const PetDetailPage({super.key, required this.petId});

  @override
  _PetDetailPageState createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  final ApiService _apiService = ApiService();
  LostPetDetail? _petDetail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPetDetail();
  }

  void _fetchPetDetail() async {
    try {
      final petDetail = await _apiService.fetchLostPetDetail(widget.petId);
      setState(() {
        _petDetail = petDetail;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching pet detail: $e');
      _showAlert('Failed to get pet details.');
    }
  }

  void _showAlert(String message) {
    final theme = context.read<ThemeProvider>();

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Error',
          style: TextStyle(color: theme.colors.destructiveForeground),
        ),
        content: Text(
          message,
          style: TextStyle(color: theme.colors.primaryForeground),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(
              'OK',
              style: TextStyle(color: theme.colors.primaryForeground),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();
    final themeData = theme.getAppTheme();

    if (_isLoading) {
      return Center(
        child: CupertinoActivityIndicator(
          color: theme.colors.foreground,
        ),
      );
    }

    if (_petDetail == null) {
      return Center(
        child: Text(
          'No details available',
          style: themeData.textTheme.textStyle,
        ),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: themeData.scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          _petDetail!.name,
          style: themeData.textTheme.navTitleTextStyle,
        ),
        backgroundColor: themeData.barBackgroundColor,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _petDetail!.name,
                style: themeData.textTheme.navLargeTitleTextStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${_petDetail!.lost ? 'Lost' : 'Found'}',
                style: themeData.textTheme.textStyle,
              ),
              const SizedBox(height: 8),
              Text(
                _petDetail!.description,
                style: themeData.textTheme.textStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Contact: ${_petDetail!.posterContact}',
                style: themeData.textTheme.textStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${_petDetail!.date.toLocal()}',
                style: themeData.textTheme.textStyle,
              ),
              const SizedBox(height: 8),
              if (_petDetail!.petImageUrls.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image URLs:',
                      style: themeData.textTheme.textStyle,
                    ),
                    const SizedBox(height: 8),
                    ..._petDetail!.petImageUrls.map(
                      (url) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          url,
                          style: themeData.textTheme.textStyle.copyWith(
                            color: theme.colors.cardForeground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
