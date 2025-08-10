import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:dear_days/features/diary/data/diary_model.dart';
import 'package:dear_days/features/diary/data/local_data_source.dart';
import 'package:dear_days/features/diary/presentation/widgets/diary_card.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final ValueNotifier<List<DiaryModel>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final Map<DateTime, List<DiaryModel>> _eventsMap = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
    _loadEvents();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    final localData = LocalDataSource();
    final entries = await localData.getAllEntries(userId: '');

    for (var entry in entries) {
      DateTime date = DateTime.parse(entry.dateTime);
      DateTime cleanDate = DateTime(date.year, date.month, date.day);
      _eventsMap.putIfAbsent(cleanDate, () => []).add(entry);
    }

    setState(() {
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }

  List<DiaryModel> _getEventsForDay(DateTime day) {
    final cleanDay = DateTime(day.year, day.month, day.day);
    return _eventsMap[cleanDay] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar View'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar<DiaryModel>(
            firstDay: DateTime(2000),
            lastDay: DateTime(2100),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                _selectedEvents.value = _getEventsForDay(selectedDay);
              });
            },
            onFormatChanged: (format) {
              setState(() => _calendarFormat = format);
            },
            eventLoader: _getEventsForDay,
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<DiaryModel>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(child: Text("No diary entries."));
                }
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return DiaryCard(entry: value[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
