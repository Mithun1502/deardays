import 'package:dear_days/features/settings/theme/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:dear_days/features/diary/data/local_data_source.dart';
import 'package:dear_days/features/diary/data/diary_model.dart';
import 'package:dear_days/config/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEditPage extends StatefulWidget {
  final DiaryModel? entry;

  const AddEditPage({super.key, this.entry});

  @override
  State<AddEditPage> createState() => _AddEditPageState();
}

class _AddEditPageState extends State<AddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String? _mood;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _titleController.text = widget.entry!.title;
      _contentController.text = widget.entry!.content;
      _mood = widget.entry!.mood;
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
      );

      if (widget.entry == null) {
        await LocalDataSource().insertEntry(newEntry);
      } else {
        await LocalDataSource().updateEntry(newEntry);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDarkMode
        ? [Colors.black, const Color.fromARGB(255, 3, 0, 22)]
        : [const Color(0xFF4D96FF), const Color.fromARGB(255, 37, 16, 227)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            widget.entry == null ? "Add Entry" : "Edit Entry",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildNeuromorphicTextField(
                  controller: _titleController,
                  label: 'Title',
                  validatorMsg: 'Enter a title',
                ),
                const SizedBox(height: 16),
                _buildNeuromorphicContentField(),
                const SizedBox(height: 16),
                _buildMoodDropdown(),
                const SizedBox(height: 24),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeuromorphicTextField({
    required TextEditingController controller,
    required String label,
    required String validatorMsg,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor =
        isDark ? const Color(0xFF2C2F48) : const Color(0xFFEDF4FF);

    return TextFormField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? validatorMsg : null,
    );
  }

  Widget _buildNeuromorphicContentField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor =
        isDark ? const Color(0xFF2C2F48) : const Color(0xFFEDF4FF);

    return TextFormField(
      controller: _contentController,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      minLines: 6,
      maxLines: null,
      decoration: InputDecoration(
        labelText: 'Content',
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        filled: true,
        fillColor: fillColor,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Write something...' : null,
    );
  }

  Widget _buildMoodDropdown() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor =
        isDark ? const Color(0xFF2C2F48) : const Color(0xFFEDF4FF);

    return DropdownButtonFormField<String>(
      value: _mood,
      dropdownColor: isDark ? const Color(0xFF2C2F48) : Colors.white,
      style: TextStyle(color: isDark ? Colors.white : Colors.black),
      decoration: InputDecoration(
        labelText: 'Mood',
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? Colors.white24 : Colors.black12,
            width: 1,
          ),
        ),
      ),
      items: ['Happy 😊', 'Sad 😢', 'Angry 😠', 'Excited 🤩', 'Calm 😌']
          .map((m) => DropdownMenuItem(value: m, child: Text(m)))
          .toList(),
      onChanged: (value) {
        setState(() {
          _mood = value;
        });
      },
    );
  }

  Widget _buildSaveButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.white : const Color(0xFF4D96FF),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: isDark ? Colors.black54 : Colors.blueAccent,
        ),
        onPressed: _saveEntry,
        child: Text(
          widget.entry == null ? 'Save' : 'Update',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
