import 'package:flutter/material.dart';

class ParkingCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String location;
  final String price;
  final VoidCallback onTap; // Callback for navigation

  const ParkingCard({
    Key? key,
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.price,
    required this.onTap, // Accept the onTap callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Trigger the onTap callback when tapped
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12.0), // Add padding to make it feel larger
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parking Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  imageUrl,
                  width: 80, // Increased size
                  height: 80, // Increased size
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),

              // Parking Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18, // Slightly larger font
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Price
                    Text(
                      price,
                      style: const TextStyle(
                        fontSize: 18, // Larger font size
                        fontWeight: FontWeight.bold,
                        color: Colors.blue, // Blue for emphasis
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
