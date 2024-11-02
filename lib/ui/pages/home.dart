import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:vive_app/ui/pages/ExploreScreen.dart';
import 'package:vive_app/ui/pages/HomeScreen.dart';
import 'package:vive_app/ui/pages/ProfileScreen.dart';
import 'package:vive_app/ui/pages/map.dart';
import 'package:vive_app/utils/styles.dart';

class Home extends StatefulWidget {
  final int index;
  const Home({super.key, this.index = 0});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const MapaGrupos(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _screens[_currentIndex],
          Positioned(
            bottom: 10,
            left: 10,
            right: 10,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: bgPrincipal(),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 153, 153, 153)
                        .withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildMenuItem(
                        icon: Icons.forum, label: 'Grupos', index: 0),
                    _buildMenuItem(
                        icon: Icons.search, label: 'Explorar', index: 1),
                    _buildMenuItem(
                        icon: Icons.map, label: 'Explora Grupos', index: 2),
                    _buildMenuItem(
                        icon: Icons.person, label: 'Perfil', index: 3),
                  ],
                ),
              ),
            ),
          ),
          _currentIndex == 1 || _currentIndex == 2
              ? StreamBuilder<ConnectivityResult>(
                  stream: Connectivity().onConnectivityChanged.map(
                      (connectivityList) => connectivityList.isNotEmpty
                          ? connectivityList.first
                          : ConnectivityResult.none),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        final connectivityResult = snapshot.data;

                        if (connectivityResult == ConnectivityResult.none) {
                          return _buildNoConnectionAlert();
                        } else {
                          return Container();
                        }
                      }
                    }
                    return Container();
                  },
                )
              : _conexionExito(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      {required IconData icon, required String label, required int index}) {
    bool isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Container(
          color: isSelected
              ? const Color.fromARGB(255, 255, 255, 255)
              : Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Icon(
                icon,
                color: isSelected
                    ? primaryColor()
                    : const Color.fromARGB(255, 255, 255, 255),
              ),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  color: isSelected
                      ? primaryColor()
                      : const Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _conexionExito() {
    setState(() {});
    return Container();
  }

  Widget _buildNoConnectionAlert() {
    return Stack(
      children: [
        // Fondo semi-transparente para bloquear la interacción
        Container(
          color: Colors.black54,
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Text(
                  'Te has quedado sin conexión',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Color.fromARGB(255, 29, 85, 236), fontSize: 16),
                ),
                SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text("Reconectando...")
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
