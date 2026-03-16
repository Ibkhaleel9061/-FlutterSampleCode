import 'package:fierbase/screen/formpage.dart';
import 'package:fierbase/screen/listpage.dart';
import 'package:flutter/material.dart';

class homeScreen extends StatefulWidget {
  const homeScreen({super.key});

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> {
   int _currentIndex = 0;

    // List of pages for navigation
  final List<Widget> _pages = [
    const FormPage(),
    const UsersListPage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:   _pages[_currentIndex],
      
        bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.edit),
            label: 'Form',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
        ],
      ),
    );
     
}}



