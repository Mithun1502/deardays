import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:dear_days/app_theme.dart';
import 'package:dear_days/config/constants.dart';
import 'package:dear_days/features/diary/data/diary_model.dart';
import 'package:dear_days/features/diary/data/local_data_source.dart';
import 'package:dear_days/features/settings/theme/theme_bloc.dart';
import 'package:dear_days/features/diary/presentation/widgets/media_preview.dart';

class AddEditPage extends StatefulWidget {
  final DiaryModel? entry;

  const AddEditPage({super.key, this.entry});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _mood;
  List<String> _mediaPaths = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _mood = widget.entry!.mood;
      _mediaPaths = List.from(widget.entry!.mediaPaths);
    }
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final newEntry = DiaryModel(
        id: widget.entry?.id,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        dateTime: DateTime.now().toIso8601String(),
        mood: _mood,
        mediaPaths: _mediaPaths,
      );

      if (widget.entry == null) {
        await LocalDataSource().insertEntry(newEntry);
      } else {
        await LocalDataSource().updateEntry(newEntry);
      }

      Navigator.pop(context, true);
    }
  }

  Future<void> _pickMedia() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isNotEmpty) {
      setState(() {
        _mediaPaths.addAll(picked.map((e) => e.path));
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaPaths.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ThemeBloc, ThemeState>(
      listener: (context, state) => setState(() {}),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final isDark = state.isDarkMode;
          final gradient = isDark ? darkGradient : lightGradient;

          return Container(
            decoration: BoxDecoration(gradient: gradient),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                title: Text(
                  widget.entry == null ? "Add Entry" : "Edit Entry",
                  style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : const Color.fromARGB(255, 0, 16, 45),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                iconTheme: IconThemeData(
                  color: isDark
                      ? Colors.white
                      : const Color.fromARGB(255, 0, 16, 45),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isDark ? Icons.wb_sunny : Icons.nightlight_round,
                      color: isDark
                          ? const Color.fromARGB(255, 244, 244, 244)
                          : const Color.fromARGB(255, 0, 16, 45),
                    ),
                    onPressed: () =>
                        context.read<ThemeBloc>().add(ToggleThemeEvent()),
                  ),
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _titleController,
                        label: 'Title',
                        validatorMsg: 'Enter a title',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 16),
                      _buildContentField(isDark),
                      const SizedBox(height: 16),
                      _buildMoodDropdown(isDark),
                      const SizedBox(height: 16),
                      _buildMediaSection(isDark),
                      const SizedBox(height: 24),
                      _buildSaveButton(isDark),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String validatorMsg,
    required bool isDark,
  }) {
    return TextFormField(
      controller: controller,
      style: TextStyle(
        color: isDark ? Colors.white : const Color.fromARGB(255, 0, 16, 45),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black),
        filled: true,
        fillColor: isDark
            ? Colors.black.withOpacity(0.2)
            : Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? validatorMsg : null,
    );
  }

  Widget _buildContentField(bool isDark) {
    return Container(
      constraints: const BoxConstraints(minHeight: 150),
      child: TextFormField(
        controller: _contentController,
        style: TextStyle(color: isDark ? Colors.white : Colors.black),
        decoration: InputDecoration(
          labelText: 'Content',
          labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black),
          alignLabelWithHint: true,
          filled: true,
          fillColor: isDark
              ? Colors.black.withOpacity(0.2)
              : Colors.white.withOpacity(0.9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: TextInputType.multiline,
        maxLines: null,
        minLines: 6,
        validator: (value) =>
            value == null || value.isEmpty ? 'Write something...' : null,
      ),
    );
  }

  Widget _buildMoodDropdown(bool isDark) {
    return DropdownButtonFormField<String>(
      value: _mood,
      dropdownColor: isDark ? Colors.grey[900] : Colors.white,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: 'Mood',
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black),
        filled: true,
        fillColor: isDark
            ? Colors.black.withOpacity(0.2)
            : Colors.white.withOpacity(0.9),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: ['Happy 😊', 'Sad 😢', 'Angry 😠', 'Excited 🤩', 'Calm 😌']
          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
          .toList(),
      onChanged: (value) => setState(() => _mood = value),
    );
  }

  Widget _buildMediaSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Attached Media',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(height: 8),
        MediaPreview(
          mediaPaths: _mediaPaths,
          onMediaChanged: (newList) {
            setState(() => _mediaPaths = newList);
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickMedia,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text("Add Media"),
            ),
            const SizedBox(width: 12),
            if (_mediaPaths.isNotEmpty)
              ElevatedButton.icon(
                onPressed: () => setState(() => _mediaPaths.clear()),
                icon: const Icon(Icons.delete_outline),
                label: const Text("Clear All"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSaveButton(bool isDark) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? Colors.white : const Color.fromARGB(255, 0, 16, 45),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: _saveEntry,
        child: Text(
          widget.entry == null ? 'Save' : 'Update',
          style: TextStyle(color: isDark ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}
