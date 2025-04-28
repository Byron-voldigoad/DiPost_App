// App bar 
import 'package:flutter/material.dart';

class CustomAppBar extends AppBar {
  CustomAppBar(({String title}) param0, {
    super.key,
    required String title,
    List<Widget>? actions,
  }) : super(
          title: Text(title),
          actions: actions,
          elevation: 0,
        );
}