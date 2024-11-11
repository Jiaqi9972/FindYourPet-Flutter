// filter_page.dart

import 'package:flutter/cupertino.dart';

enum PetStatus { all, lost, found }

class FilterPage extends StatefulWidget {
  final Map<String, dynamic> filters;

  const FilterPage({Key? key, required this.filters}) : super(key: key);

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  PetStatus _petStatus = PetStatus.all;

  @override
  void initState() {
    super.initState();
    bool? lost = widget.filters['lost'];
    if (lost == true) {
      _petStatus = PetStatus.lost;
    } else if (lost == false) {
      _petStatus = PetStatus.found;
    } else {
      _petStatus = PetStatus.all;
    }
  }

  void _applyFilters() {
    bool? lost;
    if (_petStatus == PetStatus.lost) {
      lost = true;
    } else if (_petStatus == PetStatus.found) {
      lost = false;
    } else {
      lost = null;
    }

    Navigator.pop(context, {
      'lost': lost,
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Filters'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Text('Apply'),
          onPressed: _applyFilters,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Pet Status Segmented Control
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSlidingSegmentedControl<PetStatus>(
                groupValue: _petStatus,
                children: const {
                  PetStatus.all: Text('All'),
                  PetStatus.lost: Text('Lost'),
                  PetStatus.found: Text('Found'),
                },
                onValueChanged: (PetStatus? value) {
                  if (value != null) {
                    setState(() {
                      _petStatus = value;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
