import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dear_days/features/diary/data/diary_model.dart';
import 'package:dear_days/features/diary/data/local_data_source.dart';

part 'diary_event.dart';
part 'diary_state.dart';

class DiaryBloc extends Bloc<DiaryEvent, DiaryState> {
  final DiaryRepository _repository = DiaryRepository();

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
    try {
      final entries = await _repository.getAllEntries();
      emit(DiaryLoaded(entries));
    } catch (e) {
      emit(DiaryError("Failed to load entries: $e"));
    }
  }

  Future<void> _onAddEntry(
      AddEntryEvent event, Emitter<DiaryState> emit) async {
    try {
      await _repository.insertEntry(event.entry);
      add(LoadEntriesEvent());
    } catch (e) {
      emit(DiaryError("Failed to add entry: $e"));
    }
  }

  Future<void> _onUpdateEntry(
      UpdateEntryEvent event, Emitter<DiaryState> emit) async {
    try {
      await _repository.updateEntry(event.entry);
      add(LoadEntriesEvent());
    } catch (e) {
      emit(DiaryError("Failed to update entry: $e"));
    }
  }

  Future<void> _onDeleteEntry(
      DeleteEntryEvent event, Emitter<DiaryState> emit) async {
    try {
      await _repository.deleteEntry(event.id);
      add(LoadEntriesEvent());
    } catch (e) {
      emit(DiaryError("Failed to delete entry: $e"));
    }
  }

  Future<void> _onFilterEntries(
      FilterEntriesEvent event, Emitter<DiaryState> emit) async {
    emit(DiaryLoading());
    try {
      final filteredEntries = await _repository.getFilteredEntries(
          mood: event.mood, date: event.selectedDate);
      emit(DiaryLoaded(filteredEntries));
    } catch (e) {
      emit(DiaryError("Failed to filter entries: $e"));
    }
  }
}
