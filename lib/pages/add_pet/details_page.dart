import 'package:find_your_pet/pages/add_pet/cupertino_autocomplete_address.dart';
import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:find_your_pet/utils/color.dart';
import 'package:find_your_pet/utils/color_dark.dart';
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
    final theme = context.watch<ThemeProvider>();
    final textStyle = theme.getAppTheme().textTheme.textStyle;
    final isDark = theme.isDarkMode;
    final cardColor = isDark ? AppColorsDark.card : AppColors.card;
    final primaryColor = isDark ? AppColorsDark.primary : AppColors.primary;
    final primaryForegroundColor =
        isDark ? AppColorsDark.primaryForeground : AppColors.primaryForeground;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pet Details',
                  style: textStyle.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                CupertinoTextField(
                  controller: nameController,
                  placeholder: 'Pet Name',
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  style: textStyle,
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: descriptionController,
                  placeholder: 'Description',
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  maxLines: 3,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  style: textStyle,
                ),
                const SizedBox(height: 16),
                CupertinoTextField(
                  controller: contactController,
                  placeholder: 'Contact Information',
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  style: textStyle,
                ),
                const SizedBox(height: 16),
                CupertinoButton(
                  color: cardColor,
                  child: Text(
                    selectedDate != null
                        ? 'Selected Date: ${selectedDate!.toLocal().toString().split('.')[0]}'
                        : 'Select Date and Time',
                    style: textStyle,
                  ),
                  onPressed: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: CupertinoAddressAutocomplete(
                    apiKey: googleApiKey,
                    controller: locationController,
                    onLocationSelected: (lat, lng, address) {
                      setState(() {
                        selectedLatitude = lat;
                        selectedLongitude = lng;
                        locationController.text = address;
                        isLocationSelected = true;
                      });
                    },
                    textStyle: textStyle,
                    backgroundColor: cardColor,
                    clearButtonColor: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CupertinoButton(
                color: primaryColor.withOpacity(0.8),
                onPressed: widget.onBack,
                child: Text(
                  'Back',
                  style: TextStyle(color: primaryForegroundColor),
                ),
              ),
              CupertinoButton(
                color: primaryColor,
                onPressed: _handleSubmit,
                child: Text(
                  'Submit',
                  style: TextStyle(color: primaryForegroundColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
