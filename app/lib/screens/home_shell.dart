import 'package:flutter/material.dart';
import 'route_search_screen.dart';
import 'station_access_screen.dart';
import 'data_info_screen.dart';

/// 하단 탭 3개로 구성된 앱 셸.
/// 탭: 지름길 찾기 / 역 접근성 / 데이터 정보.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const List<Widget> _pages = [
    RouteSearchScreen(),
    StationAccessScreen(),
    DataInfoScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: '지름길 찾기',
          ),
          NavigationDestination(
            icon: Icon(Icons.elevator_outlined),
            selectedIcon: Icon(Icons.elevator),
            label: '역 접근성',
          ),
          NavigationDestination(
            icon: Icon(Icons.dataset_outlined),
            selectedIcon: Icon(Icons.dataset),
            label: '데이터 정보',
          ),
        ],
      ),
    );
  }
}
