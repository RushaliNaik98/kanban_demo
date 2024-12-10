import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:kanban_demo/blocs/task/task_bloc.dart';
import 'package:kanban_demo/blocs/task/task_event.dart';
import 'package:kanban_demo/blocs/task/task_state.dart';
import 'package:kanban_demo/blocs/theme/theme_bloc.dart';
import 'package:kanban_demo/blocs/theme/theme_event.dart';
import 'package:kanban_demo/blocs/theme/theme_state.dart';
import 'package:kanban_demo/ui/widgets/kanban_column.dart';
import 'package:kanban_demo/utils/colors.dart';
import 'package:kanban_demo/utils/responsive.dart';

import '../../utils/helpers.dart';
import '../widgets/task_progress_bar.dart';
import 'analytics_screen.dart';

class HomeScreen extends StatefulWidget {
  final Function(String) onLanguageChange; // Add this line
  final Locale? locale;

  const HomeScreen({Key? key, required this.onLanguageChange, this.locale})
      : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  // late Locale _locale = const Locale('en');

  // Tabs mapping to statuses
  final List<String> _statuses = [
    "Home",
    "To Do",
    "In Progress",
    "Completed",
    "Analytics"
  ];

  @override
  void initState() {
    super.initState();
    // _loadLocale();
    // Dispatch FetchTasksEvent to load tasks
    context.read<TaskBloc>().add(FetchTasksEvent());
  }

  // Save selected locale in SharedPreferences
  Future<void> _changeLanguage(String languageCode) async {
    widget.onLanguageChange(languageCode);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (context, themeState) {
      final isDarkMode = themeState is DarkThemeState;
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          backgroundColor: AppColors.backgroundColor(isDarkMode),
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                const CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      AssetImage('assets/images/profile_image.png'),
                ),
                const SizedBox(width: 16),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rushali\'s Kanban',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.appNameColor(isDarkMode),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.active,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: AppColors.appNameColor(isDarkMode)),
              onPressed: () {
                context.read<ThemeBloc>().add(ToggleThemeEvent(!isDarkMode));
              },
            ),
            IconButton(
              icon: Icon(
                  widget.locale?.languageCode == 'en'
                      ? Icons.language
                      : Icons.language_outlined,
                  color: AppColors.appNameColor(isDarkMode)),
              onPressed: () {
                final newLanguage =
                    widget.locale?.languageCode == 'en' ? 'de' : 'en';
                _changeLanguage(newLanguage);
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.backgroundBodyGradientHigh(isDarkMode),
                AppColors.backgroundBodyGradientLow(isDarkMode),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: _selectedIndex == 4
              ? const AnalyticsPage()
              : BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    if (_selectedIndex == 0) {
                      // Show Kanban columns for "Home" tab
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                  AppLocalizations.of(context)!.projectName,
                                  style: TextStyle(
                                      color: AppColors.innerScreenTextColor(
                                          isDarkMode),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20))),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                  AppLocalizations.of(context)!.projectDetails,
                                  style: TextStyle(
                                      color: AppColors.innerScreenTextColor(
                                          isDarkMode),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14))),
                          const TaskProgressBar(),
                          Expanded(
                              child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: Responsive.isDesktop(context) ? MainAxisAlignment.center: MainAxisAlignment.center,
                                crossAxisAlignment:Responsive.isDesktop(context) ?CrossAxisAlignment.center : CrossAxisAlignment.start,
                                children: [
                                  KanbanColumn(
                                    columnTitle:
                                        AppLocalizations.of(context)!.toDo,
                                    status: "To Do",
                                    color: AppColors.todoColor(isDarkMode),
                                    icon: Icons.task,
                                    titleColor:
                                        AppColors.statusTextColor(isDarkMode),
                                    iconColor:
                                        AppColors.statusTextColor(isDarkMode),
                                    locale: widget.locale,
                                  ),
                                  const SizedBox(width: 16),
                                  KanbanColumn(
                                    columnTitle: AppLocalizations.of(context)!
                                        .inProgress,
                                    status: "In Progress",
                                    color:
                                        AppColors.inProgressColor(isDarkMode),
                                    icon: Icons.sync,
                                    titleColor:
                                        AppColors.statusTextColor(isDarkMode),
                                    iconColor:
                                        AppColors.statusTextColor(isDarkMode),
                                    locale: widget.locale,
                                  ),
                                  const SizedBox(width: 16),
                                  KanbanColumn(
                                    columnTitle:
                                        AppLocalizations.of(context)!.done,
                                    status: "Completed",
                                    color: AppColors.completedColor(isDarkMode),
                                    icon: Icons.check_circle,
                                    titleColor:
                                        AppColors.statusTextColor(isDarkMode),
                                    iconColor:
                                        AppColors.statusTextColor(isDarkMode),
                                    locale: widget.locale,
                                  ),
                                ],
                              ),
                            ),
                          )),
                        ],
                      );
                    } else if (state is TaskLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TaskLoaded) {
                      final filteredTasks = state.tasks
                          .where((task) =>
                              task.description == _statuses[_selectedIndex])
                          .toList();

                      return ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return Card(
                            color: AppColors.tileColor(isDarkMode),
                            child: ListTile(
                              title: Text(
                                task.content,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black),
                              ),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  task.description == 'Completed'
                                      ? Text(
                                          '${AppLocalizations.of(context)!.timeTaken}: ${task.duration!.amount.toString()} Min',
                                          style: const TextStyle(
                                              color: Colors.black))
                                      : Text(task.description ?? '',
                                          style: const TextStyle(
                                              color: Colors.black)),
                                  Text(
                                      '${AppLocalizations.of(context)!.createOn}: ${formatDate(task.createdAt)}',
                                      style:
                                          const TextStyle(color: Colors.black)),
                                  Text(
                                      '${AppLocalizations.of(context)!.priority}: ${getPriorityLabel(task.priority ?? 0)}',
                                      style:
                                          const TextStyle(color: Colors.black))
                                ],
                              ),
                              leading: Icon(
                                _selectedIndex == 1
                                    ? Icons.task
                                    : _selectedIndex == 2
                                        ? Icons.sync
                                        : Icons.check_circle,
                                color: AppColors.tileIconColor(isDarkMode),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      return const Center(child: Text('Failed to load tasks'));
                    }
                  },
                ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onTabSelected,
          backgroundColor: AppColors.backgroundColor(isDarkMode),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildGradientIcon(
                    Icons.home, _selectedIndex == 0, isDarkMode),
              ),
              label: AppLocalizations.of(context)!.home,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildGradientIcon(
                    Icons.task, _selectedIndex == 1, isDarkMode),
              ),
              label: AppLocalizations.of(context)!.toDo,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildGradientIcon(
                    Icons.sync, _selectedIndex == 2, isDarkMode),
              ),
              label: AppLocalizations.of(context)!.inProgress,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildGradientIcon(
                    Icons.check_circle, _selectedIndex == 3, isDarkMode),
              ),
              label: AppLocalizations.of(context)!.done,
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: _buildGradientIcon(Icons.analytics, _selectedIndex == 4,
                    isDarkMode), // Analytics icon
              ),
              label: AppLocalizations.of(context)!.analytics,
            ),
          ],
        ),
      );
    });
  }
}

Widget _buildGradientIcon(IconData icon, bool isSelected, bool isDarkTheme) {
  return ShaderMask(
    shaderCallback: (bounds) {
      return LinearGradient(
        colors: isSelected
            ? (isDarkTheme
                ? [Colors.deepPurpleAccent, Colors.blueAccent]
                : [Colors.white, Colors.white])
            : (isDarkTheme
                ? [Colors.grey, Colors.white54]
                : [Colors.white, Colors.white]),
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bounds);
    },
    child: Icon(
      icon,
      size: 24,
      color: Colors.white,
    ),
  );
}
