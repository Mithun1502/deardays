import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dear_days/features/diary/data/diary_model.dart';
import 'package:dear_days/features/diary/data/local_data_source.dart';

part 'diary_event.dart';
part 'diary_state.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  final LocalDataSource _dataSource = LocalDataSource();

  DiaryBloc() : super(DiaryLoading()) {
    on<LoadEntriesEvent>(_onLoadEntries);
    on<AddEntryEvent>(_onAddEntry);
    on<UpdateEntryEvent>(_onUpdateEntry);
    on<DeleteEntryEvent>(_onDeleteEntry);
    on<FilterEntriesEvent>(_onFilterEntries);
  }

  Future<void> _onLoadEntries(
      LoadEntriesEvent event, Emitter<DiaryState> emit) async {
    emit(DiaryLoading());
    final entries = await _dataSource.getAllEntries();
    emit(DiaryLoaded(entries));
  }

  Future<void> _onAddEntry(
      AddEntryEvent event, Emitter<DiaryState> emit) async {
    await _dataSource.insertEntry(event.entry);
    add(LoadEntriesEvent());
  }

  Future<void> _onUpdateEntry(
      UpdateEntryEvent event, Emitter<DiaryState> emit) async {
    await _dataSource.updateEntry(event.entry);
    add(LoadEntriesEvent());
  }

  Future<void> _onDeleteEntry(
      DeleteEntryEvent event, Emitter<DiaryState> emit) async {
    await _dataSource.deleteEntry(event.id);
    add(LoadEntriesEvent());
  }

  Future<void> _onFilterEntries(
      FilterEntriesEvent event, Emitter<DiaryState> emit) async {
    emit(DiaryLoading());
    final allEntries = await _dataSource.getAllEntries();

    List<DiaryModel> filtered = allEntries;

    if (event.mood != null && event.mood!.isNotEmpty) {
      filtered = filtered.where((e) => e.mood == event.mood).toList();
    }

    if (event.selectedDate != null && event.selectedDate!.isNotEmpty) {
      filtered = filtered
          .where((e) => e.dateTime.startsWith(event.selectedDate!))
          .toList();
    }

    emit(DiaryLoaded(filtered));
  }
}
