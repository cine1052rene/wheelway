import 'package:flutter/material.dart';
import '../models/station.dart';
import 'route_search_screen.dart';
import 'line_map_screen.dart';
import 'station_access_screen.dart';
import 'data_info_screen.dart';

/// 하단 탭 4개로 구성된 앱 셸.
/// 탭: 지름길 찾기 / 노선도 / 역 접근성 / 데이터 정보.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;
  // 노선도 탭에서 역을 탭해 넘어올 때 지름길 찾기 화면에 미리 채워 넣을 값.
  // 값이 바뀔 때마다 아래에서 새 ValueKey로 RouteSearchScreen을 다시
  // 만들어야, 이미 열려 있던 이전 검색 상태가 남지 않고 새로 채워진다.
  Station? _presetOrigin;
  Station? _presetDestination;
  int _presetSeq = 0;

  void _pickFromMap(Station station, {required bool asOrigin}) {
    setState(() {
      if (asOrigin) {
        _presetOrigin = station;
      } else {
        _presetDestination = station;
      }
      _presetSeq++;
      _index = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      RouteSearchScreen(
        key: ValueKey('route-$_presetSeq'),
        initialOrigin: _presetOrigin,
        initialDestination: _presetDestination,
      ),
      LineMapScreen(
        onPickOrigin: (s) => _pickFromMap(s, asOrigin: true),
        onPickDestination: (s) => _pickFromMap(s, asOrigin: false),
      ),
      const StationAccessScreen(),
      const DataInfoScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_index]),
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
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: '노선도',
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
