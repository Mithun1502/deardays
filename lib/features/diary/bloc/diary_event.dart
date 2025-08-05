// 📁 diary_event.dart
part of 'diary_bloc.dart';

abstract class DiaryEvent extends Equatable {
  const DiaryEvent();

  @override
  List<Object?> get props => [];
}

class LoadEntriesEvent extends DiaryEvent {}

class AddEntryEvent extends DiaryEvent {
  final DiaryModel entry;
  const AddEntryEvent(this.entry);

  @override
  List<Object?> get props => [entry];
}

class UpdateEntryEvent extends DiaryEvent {
  final DiaryModel entry;
  const UpdateEntryEvent(this.entry);

  @override
  List<Object?> get props => [entry];
}

class DeleteEntryEvent extends DiaryEvent {
  final int id;
  const DeleteEntryEvent(this.id);

  @override
  List<Object?> get props => [id];
}

// 🆕 New Event for Filtering Entries
class FilterEntriesEvent extends DiaryEvent {
  final String? mood;
  final String? selectedDate;
  const FilterEntriesEvent({this.mood, this.selectedDate});

  @override
  List<Object?> get props => [mood, selectedDate];
}
