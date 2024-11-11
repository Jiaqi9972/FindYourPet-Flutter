import 'package:flutter/cupertino.dart';
import '../models/lost_pet_detail.dart';
import '../api/api_service.dart';

class PetDetailPage extends StatefulWidget {
  final String petId;

  const PetDetailPage({super.key, required this.petId});

  @override
  // ignore: library_private_types_in_public_api
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CupertinoActivityIndicator(),
      );
    }

    if (_petDetail == null) {
      return const Center(
        child: Text('No details available'),
      );
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(_petDetail!.name),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _petDetail!.name,
                style:
                    CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Status: ${_petDetail!.lost ? 'Lost' : 'Found'}',
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
              const SizedBox(height: 8),
              Text(
                _petDetail!.description,
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Contact: ${_petDetail!.posterContact}',
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
              const SizedBox(height: 8),
              Text(
                'Date: ${_petDetail!.date.toLocal()}',
                style: CupertinoTheme.of(context).textTheme.textStyle,
              ),
              const SizedBox(height: 8),
              if (_petDetail!.petImageUrls.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image URLs:',
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    ),
                    const SizedBox(height: 8),
                    ..._petDetail!.petImageUrls.map(
                      (url) => Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          url,
                          style: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .copyWith(
                                color: CupertinoColors.activeBlue,
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
