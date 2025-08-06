import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class MediaPreview extends StatefulWidget {
  final List<String> mediaPaths;
  final void Function(List<String>) onMediaChanged;

  const MediaPreview({
    super.key,
    required this.mediaPaths,
    required this.onMediaChanged,
  });

  @override
  State<MediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<MediaPreview> {
  final ImagePicker _picker = ImagePicker();

  void _pickImage({required bool fromCamera}) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        widget.mediaPaths.add(pickedFile.path);
        widget.onMediaChanged(widget.mediaPaths);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      widget.mediaPaths.removeAt(index);
      widget.onMediaChanged(widget.mediaPaths);
    });
  }

  void _showFullImage(String path) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: Image.file(File(path)),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(widget.mediaPaths.length, (index) {
            final path = widget.mediaPaths[index];
            return Stack(
              alignment: Alignment.topRight,
              children: [
                GestureDetector(
                  onTap: () => _showFullImage(path),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(path),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => _removeImage(index),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _pickImage(fromCamera: false),
              icon: const Icon(Icons.photo),
              label: const Text("Gallery"),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () => _pickImage(fromCamera: true),
              icon: const Icon(Icons.camera_alt),
              label: const Text("Camera"),
            ),
          ],
        ),
      ],
    );
  }
}
