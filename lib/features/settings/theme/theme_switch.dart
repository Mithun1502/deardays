import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dear_days/features/settings/theme/theme_bloc.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return IconButton(
          icon: Icon(state.isDarkMode ? Icons.dark_mode : Icons.light_mode),
          onPressed: () {
            context.read<ThemeBloc>().add(ToggleThemeEvent());
          },
          tooltip: state.isDarkMode
              ? "Switch to Light Mode"
              : "Switch to Dark Mode",
        );
      },
    );
  }
}
