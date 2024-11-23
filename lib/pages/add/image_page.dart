import 'dart:io';
import 'package:find_your_pet/styles/color/color.dart';
import 'package:find_your_pet/styles/color/color_dark.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/styles/ui/button.dart';
import 'package:find_your_pet/utils/storage_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ImagePage extends StatefulWidget {
  final List<String> petImageUrls;
  final ValueChanged<List<String>> onImageUrlsEntered;
  final VoidCallback onBack;

  const ImagePage({
    super.key,
    required this.petImageUrls,
    required this.onImageUrlsEntered,
    required this.onBack,
  });

  @override
  _ImagePageState createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  List<String> _existingUrls = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _existingUrls = List.from(widget.petImageUrls);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920, // 最大宽度
        maxHeight: 1080, // 最大高度
        imageQuality: 85, // 压缩质量
      );

      if (image == null) return;

      setState(() {
        _selectedImages.add(File(image.path));
      });
    } catch (e) {
      print('Error picking image: $e');
      _showErrorDialog('Failed to pick image');
    }
  }

  String _getContentType(String filepath) {
    String ext = path.extension(filepath).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.heic':
        return 'image/heic';
      default:
        return 'image/jpeg'; // 默认类型
    }
  }

  Future<void> _handleNext() async {
    if (_selectedImages.isEmpty && _existingUrls.isEmpty) {
      _showErrorDialog('Please select at least one image');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      List<String> newUrls = [];

      // 上传新选择的图片
      for (File imageFile in _selectedImages) {
        final String ext = path.extension(imageFile.path);
        final String fileName = 'pets/${const Uuid().v4()}$ext';

        final String downloadUrl = await StorageService.uploadFile(
          path: fileName,
          data: await imageFile.readAsBytes(),
          contentType: _getContentType(imageFile.path),
          metadata: {
            'uploadTime': DateTime.now().toIso8601String(),
            'originalName': path.basename(imageFile.path),
          },
        );

        newUrls.add(downloadUrl);
      }

      // 合并现有URL和新URL
      final List<String> allUrls = [..._existingUrls, ...newUrls];
      widget.onImageUrlsEntered(allUrls);
    } catch (e) {
      print('Upload error: $e');
      _showErrorDialog('Failed to upload images: $e');
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _removeImage(int index, bool isExisting) {
    setState(() {
      if (isExisting) {
        _existingUrls.removeAt(index);
      } else {
        _selectedImages.removeAt(index - _existingUrls.length);
      }
    });
  }

  void _showErrorDialog(String message) {
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
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Add Pet Images',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColorsDark.foreground : AppColors.foreground,
          ),
        ),
        const SizedBox(height: 20),
        AppButton(
          text: 'Select Image',
          variant: ButtonVariant.primary,
          isDarkMode: isDarkMode,
          onPressed: _isUploading ? null : _pickImage,
        ),
        const SizedBox(height: 20),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1, // 添加这个确保子项是正方形
            ),
            itemCount: _existingUrls.length + _selectedImages.length,
            itemBuilder: (context, index) {
              final bool isExisting = index < _existingUrls.length;
              return Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColorsDark.muted : AppColors.muted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: isExisting
                            ? Image.network(
                                _existingUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Icon(
                                  CupertinoIcons.photo,
                                  color: isDarkMode
                                      ? AppColorsDark.mutedForeground
                                      : AppColors.mutedForeground,
                                ),
                              )
                            : Image.file(
                                _selectedImages[index - _existingUrls.length],
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                    if (!_isUploading)
                      Positioned(
                        top: 5,
                        right: 5,
                        child: AppButton(
                          text: '',
                          variant: ButtonVariant.destructive,
                          isDarkMode: isDarkMode,
                          icon: CupertinoIcons.delete,
                          onPressed: () => _removeImage(index, isExisting),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        if (_isUploading)
          Padding(
            padding: const EdgeInsets.all(16),
            child: CupertinoActivityIndicator(
              color: isDarkMode ? AppColorsDark.primary : AppColors.primary,
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppButton(
              text: 'Back',
              variant: ButtonVariant.outline,
              isDarkMode: isDarkMode,
              onPressed: _isUploading ? null : widget.onBack,
            ),
            AppButton(
              text: 'Next',
              variant: ButtonVariant.primary,
              isDarkMode: isDarkMode,
              onPressed: (_selectedImages.isEmpty && _existingUrls.isEmpty) ||
                      _isUploading
                  ? null
                  : _handleNext,
            ),
          ],
        ),
      ],
    );
  }
}
