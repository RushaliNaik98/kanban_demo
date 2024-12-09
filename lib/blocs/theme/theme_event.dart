import 'package:equatable/equatable.dart';

abstract class ThemeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ToggleThemeEvent extends ThemeEvent {
  final bool isDarkMode;

  ToggleThemeEvent(this.isDarkMode);

  @override
  List<Object?> get props => [isDarkMode];
}
