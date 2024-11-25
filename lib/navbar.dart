import 'package:flutter/material.dart';
import 'package:parkvision/announcement.dart';
import 'package:parkvision/homepage.dart';
import 'package:parkvision/violation.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NavigationRailPage(),
    );
  }
}

class NavigationRailPage extends StatefulWidget {
  const NavigationRailPage({super.key});

  @override
  State<NavigationRailPage> createState() => _NavigationRailPageState();
}

const _navBarItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.campaign),
    label: 'Announcement',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.car_crash),
    label: 'Violation',
  ),
];

class _NavigationRailPageState extends State<NavigationRailPage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.reset();
    _controller.forward();
  }

  Widget _getPage() {
    switch (_selectedIndex) {
      case 0:
        return const LandingPage(); // Menggunakan LandingPage
      case 1:
        return const AnnouncementPage();
      case 2:
        return const ViolationPage();
      default:
        return const LandingPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;
    final bool isLargeScreen = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      bottomNavigationBar: isSmallScreen
          ? BottomNavigationBar(
              backgroundColor: const Color(0xFFff3c3c),
              items: _navBarItems.map((item) {
                final int itemIndex = _navBarItems.indexOf(item);
                final bool isSelected = _selectedIndex == itemIndex;

                return BottomNavigationBarItem(
                  icon: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return IconTheme(
                        data: IconThemeData(
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                        child: item.icon,
                      );
                    },
                  ),
                  label: item.label,
                );
              }).toList(),
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.black,
              unselectedItemColor: Colors.white,
              onTap: _onItemTapped,
            )
          : null,
      body: Row(
        children: <Widget>[
          if (!isSmallScreen)
            NavigationRail(
              selectedIndex: _selectedIndex,
              onDestinationSelected: _onItemTapped,
              extended: isLargeScreen,
              backgroundColor: const Color(0xFFff3c3c),
              destinations: _navBarItems.map((item) {
                final int itemIndex = _navBarItems.indexOf(item);
                final bool isSelected = _selectedIndex == itemIndex;

                return NavigationRailDestination(
                  icon: IconTheme(
                    data: IconThemeData(
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                    child: item.icon,
                  ),
                  selectedIcon: IconTheme(
                    data: const IconThemeData(
                      color: Colors.black,
                    ),
                    child: item.icon,
                  ),
                  label: Text(
                    item.label!,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.white,
                    ), // Menambahkan font tebal
                  ),
                );
              }).toList(),
            ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _getPage(),
          ),
        ],
      ),
    );
  }
}
