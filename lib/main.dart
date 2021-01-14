import 'package:flutter/material.dart';
import 'package:gif_finder_giphy_api/pages/home_page.dart';

void main() {
  runApp(MaterialApp(
    title: 'Gif Finder',
    home: HomePage(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(primaryColor: Colors.blueAccent, hintColor: Colors.blueAccent),
  ));
}
