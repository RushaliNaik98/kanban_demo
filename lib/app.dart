import 'package:flutter/material.dart';
import 'package:kanban_demo/blocs/comment/comment_bloc.dart';
import 'package:kanban_demo/blocs/theme/theme_bloc.dart';
import 'package:kanban_demo/blocs/theme/theme_state.dart';
import 'package:kanban_demo/repositories/comment_repository.dart';
import 'blocs/task/task_bloc.dart';
import 'blocs/timer/timer_bloc.dart';
import 'repositories/task_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ui/screens/home_screen.dart';

class MyApp extends StatefulWidget {
  final TaskRepository taskRepository;
  final CommentRepository commentRepository;

  const MyApp({
    Key? key,
    required this.taskRepository,
    required this.commentRepository,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale(); // Load the saved locale when the app starts
  }

  // Load saved locale from SharedPreferences
  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'en';
    debugPrint('languageCode $languageCode');
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  // Save selected locale in SharedPreferences and reload the app
  Future<void> _changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);
    setState(() {
      _locale = Locale(languageCode);
    });
    _loadLocale();
    // This will trigger a rebuild of the entire app
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc(taskRepository: widget.taskRepository),
        ),
        BlocProvider<CommentBloc>(
          create: (context) =>
              CommentBloc(commentRepository: widget.commentRepository),
        ),
        BlocProvider<TimerBloc>(
          create: (context) => TimerBloc(),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Kanban Demo',
            theme: state.themeData, // Use the theme from ThemeBloc
            home: HomeScreen(
                onLanguageChange:
                    _changeLanguage,
                    locale: _locale ,
                    
                    ), // Pass the language change function
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate
            ],
            locale: _locale, // Use the loaded locale
            supportedLocales: const [
              Locale('en'),
              Locale('de'),
            ],
          );
        },
      ),
    );
  }
}
