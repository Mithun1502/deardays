import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dear_days/core/utils/shared_prefs_helper.dart';

// Event
abstract class ThemeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadThemeEvent extends ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

// State
class ThemeState extends Equatable {
  final bool isDarkMode;
  const ThemeState({required this.isDarkMode});

  @override
  List<Object?> get props => [isDarkMode];
}

// BLoC
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const ThemeState(isDarkMode: false)) {
    on<LoadThemeEvent>((event, emit) {
      final isDark = SharedPrefsHelper.isDarkMode;
      emit(ThemeState(isDarkMode: isDark));
    });

    on<ToggleThemeEvent>((event, emit) {
      final newMode = !state.isDarkMode;
      SharedPrefsHelper.setDarkMode(newMode);
      emit(ThemeState(isDarkMode: newMode));
    });
  }
}
