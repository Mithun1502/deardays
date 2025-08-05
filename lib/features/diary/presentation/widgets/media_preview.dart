import 'dart:io';
import 'package:flutter/material.dart';

class MediaPreview extends StatelessWidget {
  final List<String> mediaPaths;

  const MediaPreview({Key? key, required this.mediaPaths}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (mediaPaths.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: mediaPaths.length,
        itemBuilder: (context, index) {
          final path = mediaPaths[index];
          return Container(
            margin: const EdgeInsets.all(6),
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(path),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
          );
        },
      ),
    );
  }
}
