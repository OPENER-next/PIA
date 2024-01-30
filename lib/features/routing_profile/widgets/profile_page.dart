import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final String title;

  final List<Widget> children;

  final List<Widget>? actions;

  const ProfilePage({
    required this.title,
    this.children = const [],
    this.actions,
    super.key,
  });

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: ListView(
        shrinkWrap: true,
        children: children,
      ),
    );
  }
}
