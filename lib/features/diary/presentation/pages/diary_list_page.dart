import 'package:dear_days/features/diary/data/local_data_source.dart';
import 'package:dear_days/features/diary/data/diary_model.dart';
import 'package:dear_days/features/diary/presentation/pages/add_edit_page.dart';
import 'package:dear_days/features/diary/presentation/widgets/diary_card.dart';
import 'package:dear_days/features/settings/theme/theme_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:dear_days/app_theme.dart';

class DiaryListPage extends StatefulWidget {
  const DiaryListPage({super.key});

  @override
  State<DiaryListPage> createState() => _DiaryListPageState();
}

class _DiaryListPageState extends State<DiaryListPage> {
  final LocalDataSource _dataSource = LocalDataSource();
  List<DiaryModel> _entries = [];
  List<DiaryModel> _filteredEntries = [];

  String _searchQuery = '';
  String? _selectedMood;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await _dataSource.getAllEntries();
    setState(() {
      _entries = entries;
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredEntries = _entries.where((entry) {
        final matchesSearch = entry.title
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            entry.content.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesMood =
            _selectedMood == null || entry.mood == _selectedMood;
        final matchesDate = _selectedDate == null ||
            DateFormat('yyyy-MM-dd').format(DateTime.parse(entry.dateTime)) ==
                DateFormat('yyyy-MM-dd').format(_selectedDate!);

        return matchesSearch && matchesMood && matchesDate;
      }).toList();
    });
  }

  void _showDatePicker() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _applyFilters();
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedMood = null;
      _selectedDate = null;
      _applyFilters();
    });
  }

  void _deleteEntry(int id) async {
    await _dataSource.deleteEntry(id);
    _loadEntries();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final gradient = isDark ? darkGradient : lightGradient;

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text('Dear Days',
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold, fontSize: 26)),
          iconTheme: IconThemeData(color: textColor),
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
              tooltip: 'Toggle Dark Mode',
            ),
          ],
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                  prefixIcon: Icon(Icons.search, color: textColor),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: textColor),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _applyFilters();
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor:
                      isDark ? Colors.black54 : Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _applyFilters();
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      dropdownColor: isDark ? Colors.grey[900] : Colors.white,
                      value: _selectedMood,
                      hint: Text('Filter by Mood',
                          style: TextStyle(color: textColor)),
                      isExpanded: true,
                      items: [
                        'Happy 😊',
                        'Sad 😢',
                        'Angry 😠',
                        'Excited 🤩',
                        'Calm 😌'
                      ]
                          .map((mood) => DropdownMenuItem(
                                value: mood,
                                child: Text(mood,
                                    style: TextStyle(color: textColor)),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedMood = value;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isDark ? Colors.white10 : Colors.blueAccent,
                    ),
                    onPressed: _showDatePicker,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_selectedDate == null
                        ? 'Pick Date'
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!)),
                  ),
                  IconButton(
                    onPressed: _clearFilters,
                    icon: Icon(Icons.clear, color: textColor),
                    tooltip: 'Clear Filters',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _filteredEntries.isEmpty
                    ? Center(
                        child: Text('No entries found.',
                            style: TextStyle(color: textColor)),
                      )
                    : AnimationLimiter(
                        child: ListView.builder(
                          itemCount: _filteredEntries.length,
                          itemBuilder: (context, index) {
                            final entry = _filteredEntries[index];
                            return Dismissible(
                              key: Key(entry.id.toString()),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: const Icon(Icons.delete,
                                    color: Colors.white),
                              ),
                              confirmDismiss: (direction) async {
                                return await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete Entry'),
                                    content: const Text(
                                        'Are you sure you want to delete this diary entry?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              onDismissed: (direction) =>
                                  _deleteEntry(entry.id!),
                              child: AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 400),
                                child: SlideAnimation(
                                  verticalOffset: 50.0,
                                  child: FadeInAnimation(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 16.0),
                                      child: DiaryCard(
                                        entry: entry,
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  AddEditPage(entry: entry),
                                            ),
                                          );
                                          if (result == true) _loadEntries();
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: isDark ? Colors.white : null,
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditPage()),
            );
            if (result == true) _loadEntries();
          },
          child: Icon(Icons.add, color: isDark ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}
