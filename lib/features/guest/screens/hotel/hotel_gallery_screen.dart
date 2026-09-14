import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';

class HotelGalleryScreen extends StatelessWidget {
  const HotelGalleryScreen({super.key});

  static const _images = [
    'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
    'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
    'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800',
    'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
    'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800',
    'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800',
    'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
    'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800',
    'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('Hotel Gallery')),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.2,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  child: InteractiveViewer(
                    child: CachedNetworkImage(imageUrl: _images[index], fit: BoxFit.contain),
                  ),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: _images[index],
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: AppColors.lightGrey),
              ),
            ),
          );
        },
      ),
    );
  }
}
