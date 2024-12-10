import 'package:flutter/material.dart';

import '../widgets/status_widget.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children:[ Padding(
        padding: EdgeInsets.all(16.0),
        child: StatusWidget(),
      )],
    );
  }
}
