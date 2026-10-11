import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../features/home/home_screen.dart';
import '../features/map/map_screen.dart';
import '../features/read_once/read_once_screen.dart';
import '../features/tracking/tracking_screen.dart';
import '../features/compare/compare_screen.dart';

/// App raíz: tema Flutter dark + navegación por tabs.
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPS en Flutter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      home: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(onGo: _go),
            const ReadOnceScreen(),
            const TrackingScreen(),
            const MapScreen(),
            const CompareScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _go,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.my_location_outlined),
              selectedIcon: Icon(Icons.my_location),
              label: 'Leer',
            ),
            NavigationDestination(
              icon: Icon(Icons.route_outlined),
              selectedIcon: Icon(Icons.route),
              label: 'Seguir',
            ),
            NavigationDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: 'Mapa',
            ),
            NavigationDestination(
              icon: Icon(Icons.lock_outline),
              selectedIcon: Icon(Icons.lock),
              label: 'Permiso',
            ),
          ],
        ),
      ),
    );
  }
}
