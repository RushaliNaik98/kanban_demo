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