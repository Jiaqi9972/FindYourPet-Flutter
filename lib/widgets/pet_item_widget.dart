import 'package:flutter/cupertino.dart';
import '../models/lost_pet_detail.dart'; // Import the correct model

class PetItemWidget extends StatelessWidget {
  final LostPetDetail pet; // Use LostPetDetail model
  final VoidCallback onTap;

  const PetItemWidget({super.key, required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Display the first pet image or a placeholder icon
            const Icon(CupertinoIcons.photo),
            const SizedBox(width: 16),
            // Display the pet's name, status, and address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: CupertinoTheme.of(context).textTheme.textStyle,
                  ),
                  Text(
                    'Status: ${pet.lost ? 'Lost' : 'Found'}',
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .copyWith(color: CupertinoColors.systemGrey),
                  ),
                  const SizedBox(height: 8),
                  // Display the address instead of latitude and longitude
                  Text(
                    'Location: ${pet.address}', // Show the address now
                    style: CupertinoTheme.of(context)
                        .textTheme
                        .textStyle
                        .copyWith(color: CupertinoColors.systemGrey2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
