import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({Key? key}) : super(key: key);

void _navigateToPage(int index, BuildContext context) {
    // Navigation logic based on index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/main');
        break;
      case 1:
        Navigator.pushNamed(context, '/maps');
        break;
      case 2:
        Navigator.pushNamed(context, '/booking');
        break;
      case 3:
        Navigator.pushNamed(context, '/user_info');
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Maps'),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Reservation'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      selectedItemColor: Colors.lightBlue,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        _navigateToPage(index, context);
      },
    );
  }
}
