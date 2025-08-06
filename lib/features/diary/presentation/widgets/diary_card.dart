import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dear_days/features/diary/data/diary_model.dart';
import 'package:dear_days/config/constants.dart';

class DiaryCard extends StatelessWidget {
  final DiaryModel entry;
  final VoidCallback? onTap;

  const DiaryCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  String _formattedDate(DateTime dateTime) {
    return DateFormat(AppConstants.fullDateTimeFormat).format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: const RoundedRectangleBorder(
        borderRadius: AppConstants.defaultBorderRadius,
      ),
      elevation: 3,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          entry.title.isEmpty ? AppConstants.defaultDiaryTitle : entry.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              entry.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 10),
            Text(
              _formattedDate(DateTime.parse(entry.dateTime)),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            if (entry.mood != null && entry.mood!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  "Mood: ${entry.mood}",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
