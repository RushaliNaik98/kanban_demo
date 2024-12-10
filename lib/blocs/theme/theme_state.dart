import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class ThemeState extends Equatable {
  final ThemeData themeData;

  const ThemeState(this.themeData);

  @override
  List<Object?> get props => [themeData];
}

class LightThemeState extends ThemeState {
  const LightThemeState(super.themeData);
}

class DarkThemeState extends ThemeState {
  const DarkThemeState(super.themeData);
}
