import 'package:find_your_pet/provider/theme_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:find_your_pet/api/api_service.dart';
import 'package:find_your_pet/layout/main_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'status_page.dart';
import 'image_page.dart';
import 'details_page.dart';

class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  String name = '';
  String description = '';
  String posterContact = '';
  List<String> petImageUrls = [];
  DateTime? date;
  bool lost = true;
  double? longitude;
  double? latitude;
  int currentStep = 0;

  void _nextStep() {
    setState(() {
      currentStep += 1;
    });
  }

  void _prevStep() {
    setState(() {
      currentStep -= 1;
    });
  }

  Future<void> _submitForm() async {
    // Validate all required fields
    List<String> missingFields = [];
    if (name.trim().isEmpty) missingFields.add('Pet Name');
    if (description.trim().isEmpty) missingFields.add('Description');
    if (posterContact.trim().isEmpty) missingFields.add('Contact Information');
    if (petImageUrls.isEmpty) missingFields.add('Pet Images');
    if (date == null) missingFields.add('Date');
    if (longitude == null || latitude == null)
      missingFields.add('Location (please select from suggestions)');

    if (missingFields.isNotEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Missing Information'),
          content: Column(
            children: [
              const Text('Please complete the following:'),
              const SizedBox(height: 8),
              Text(missingFields.join('\n')),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
      return;
    }

    try {
      String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (idToken == null) throw Exception('User not logged in');

      Map<String, dynamic> data = {
        'name': name,
        'description': description,
        'posterContact': posterContact,
        'petImageUrls': petImageUrls,
        'date': date?.toUtc().toIso8601String(),
        'lost': lost,
        'longitude': longitude,
        'latitude': latitude,
      };

      await ApiService().saveLostPet(idToken, data);

      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Success'),
          content: const Text('Your submission was successful.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(
                    builder: (context) => const MainLayout(currentIndex: 1),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } catch (e) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text('Submission Failed'),
          content: Text('Error: $e'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return CupertinoPageScaffold(
      backgroundColor: theme.getAppTheme().scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Report Pet Information'),
        backgroundColor: theme.getAppTheme().barBackgroundColor,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: IndexedStack(
            index: currentStep,
            children: [
              StatusPage(
                lost: lost,
                onStatusSelected: (selectedStatus) {
                  setState(() => lost = selectedStatus);
                  _nextStep();
                },
              ),
              ImagePage(
                petImageUrls: petImageUrls,
                onImageUrlsEntered: (urls) {
                  setState(() => petImageUrls = urls);
                  _nextStep();
                },
                onBack: _prevStep,
              ),
              DetailsPage(
                name: name,
                description: description,
                posterContact: posterContact,
                date: date,
                latitude: latitude,
                longitude: longitude,
                onSave: (newName, newDescription, newContact, newDate,
                    newLatitude, newLongitude, _) {
                  setState(() {
                    name = newName;
                    description = newDescription;
                    posterContact = newContact;
                    date = newDate;
                    latitude = newLatitude;
                    longitude = newLongitude;
                  });
                  _submitForm();
                },
                onBack: _prevStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
