import 'package:find_your_pet/pages/add/cupertino_autocomplete_address.dart';
import 'package:find_your_pet/styles/color/app_colors_config.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/styles/ui/button.dart';
import 'package:find_your_pet/styles/ui/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

// TODO: move api to env
const googleApiKey = "AIzaSyDn7prRSwmECvKMeo_3HhYZYNBNahcd5oo";

class DetailsPage extends StatefulWidget {
  final String name;
  final String description;
  final String posterContact;
  final DateTime? date;
  final double? latitude;
  final double? longitude;
  final Function(
    String,
    String,
    String,
    DateTime?,
    double?,
    double?,
    String,
  ) onSave;
  final VoidCallback onBack;

  const DetailsPage({
    super.key,
    required this.name,
    required this.description,
    required this.posterContact,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.onSave,
    required this.onBack,
  });

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController contactController;
  late TextEditingController locationController;
  DateTime? selectedDate;
  double? selectedLatitude;
  double? selectedLongitude;
  bool isLocationSelected = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.name);
    descriptionController = TextEditingController(text: widget.description);
    contactController = TextEditingController(text: widget.posterContact);
    locationController = TextEditingController(
      text: (widget.latitude != null && widget.longitude != null)
          ? 'Lat: ${widget.latitude}, Lng: ${widget.longitude}'
          : '',
    );
    selectedDate = widget.date ?? DateTime.now();
    selectedLatitude = widget.latitude;
    selectedLongitude = widget.longitude;
    isLocationSelected = widget.latitude != null && widget.longitude != null;
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    contactController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context) {
    final DateTime initialDateTime = selectedDate ?? DateTime.now();

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        color: CupertinoTheme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoButton(
                  child: const Text('Done'),
                  onPressed: () {
                    setState(() {
                      selectedDate ??= initialDateTime;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.dateAndTime,
                initialDateTime: initialDateTime,
                onDateTimeChanged: (DateTime newDate) {
                  setState(() {
                    selectedDate = newDate;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    widget.onSave(
      nameController.text.trim(),
      descriptionController.text.trim(),
      contactController.text.trim(),
      selectedDate,
      selectedLatitude,
      selectedLongitude,
      locationController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final colors = AppColorsConfig.getTheme(isDarkMode);

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pet Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colors.foreground,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextInput(
                  controller: nameController,
                  placeholder: 'Pet Name',
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                AppTextInput(
                  controller: descriptionController,
                  placeholder: 'Description',
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                AppTextInput(
                  controller: contactController,
                  placeholder: 'Contact Information',
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 16),
                AppButton(
                  text: selectedDate != null
                      ? 'Date: ${selectedDate!.toLocal().toString().split('.')[0]}'
                      : 'Select Date',
                  variant: ButtonVariant.outline,
                  isDarkMode: isDarkMode,
                  onPressed: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                CupertinoAddressAutocomplete(
                  apiKey: googleApiKey,
                  controller: locationController,
                  isDarkMode: isDarkMode,
                  onLocationSelected: (lat, lng, address) {
                    setState(() {
                      selectedLatitude = lat;
                      selectedLongitude = lng;
                      locationController.text = address;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              AppButton(
                text: 'Back',
                variant: ButtonVariant.outline,
                isDarkMode: isDarkMode,
                onPressed: widget.onBack,
              ),
              AppButton(
                text: 'Submit',
                variant: ButtonVariant.primary,
                isDarkMode: isDarkMode,
                onPressed: () => widget.onSave(
                  nameController.text,
                  descriptionController.text,
                  contactController.text,
                  selectedDate,
                  selectedLatitude,
                  selectedLongitude,
                  locationController.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
