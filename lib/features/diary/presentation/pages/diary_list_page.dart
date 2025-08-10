import 'dart:io';
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
import 'package:dear_days/features/auth/bloc/auth_bloc.dart';

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
    final entries = await _dataSource.getAllEntries(userId: '');
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
    setState(() {
      _entries.removeWhere((e) => e.id == id);
      _filteredEntries.removeWhere((e) => e.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeBloc>().state.isDarkMode;
    final textColor = isDark ? Colors.white : Colors.black87;
    final gradient = isDark ? darkGradient : lightGradient;

    final authState = context.watch<AuthBloc>().state;
    String? userEmail;
    if (authState is AuthSuccess) {
      userEmail = authState.user?.email;
    }

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: Text(
            'Dear Days',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 26,
            ),
          ),
          iconTheme: IconThemeData(color: textColor),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode,
                  color: textColor),
              onPressed: () {
                context.read<ThemeBloc>().add(ToggleThemeEvent());
              },
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: isDark
              ? const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3)
              : const Color.fromARGB(255, 116, 180, 209).withOpacity(0.3),
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text(''),
                accountEmail: Text(
                  userEmail ?? 'No Email',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.person, size: 40),
                ),
                decoration: BoxDecoration(gradient: gradient),
              ),
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: isDark
                      ? Colors.white
                      : const Color.fromARGB(221, 190, 191, 195),
                ),
                title: Text(
                  'Sign Out',
                  style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : const Color.fromARGB(221, 190, 191, 195),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  context.read<AuthBloc>().add(SignOutEvent());
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (route) => false);
                },
              ),
            ],
          ),
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
                      borderRadius: BorderRadius.circular(12)),
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
                        child: Text(
                          'Start your Journey here..!',
                          style: TextStyle(color: textColor),
                        ),
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
                                          child: const Text('Cancel')),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(true),
                                          child: const Text('Delete')),
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
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          DiaryCard(
                                            entry: entry,
                                            onTap: () async {
                                              final result =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (_) => AddEditPage(
                                                        entry: entry)),
                                              );
                                              if (result == true) {
                                                _loadEntries();
                                              }
                                            },
                                          ),
                                          if (entry.mediaPaths.isNotEmpty)
                                            SizedBox(
                                              height: 100,
                                              child: ListView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                children: entry.mediaPaths
                                                    .map((path) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 8.0, top: 8),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      child: Image.file(
                                                        File(path),
                                                        width: 100,
                                                        height: 100,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context,
                                                                error,
                                                                stackTrace) =>
                                                            Container(
                                                          width: 100,
                                                          height: 100,
                                                          color: Colors
                                                              .grey.shade300,
                                                          child: const Icon(Icons
                                                              .broken_image),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                        ],
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
          child: Icon(
            Icons.add,
            color: isDark ? Colors.black : const Color.fromARGB(255, 15, 0, 14),
          ),
        ),
      ),
    );
  }
}
