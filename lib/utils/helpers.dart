import 'package:intl/intl.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1).toLowerCase();

String formatDate(String? dateString) {
  if (dateString == null) {
    return '';
  }

  final DateTime dateTime = DateTime.parse(dateString); // Parse the ISO 8601 string
  final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss'); // Define the format
  return formatter.format(dateTime); // Return the formatted date
}

String getPriorityLabel(int priority) {
  switch (priority) {
    case 1:
      return "Normal";
    case 2:
      return "High";
    case 3:
      return "Very High";
    case 4:
      return "Urgent";
    default:
      return "Unknown"; 
  }
}

