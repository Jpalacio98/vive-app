import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vive_app/domain/alerts/alertCargando.dart';
import 'package:vive_app/domain/models/grupos.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/infrastructure/controllers/map.dart';
import 'package:vive_app/ui/components/otrosGrupos.dart';
import 'package:vive_app/ui/pages/chat.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String userId;
  final ControllerUser controllerUser = Get.find();
  static final MapController controller = Get.find();
  String? isUbicacion;

  @override
  void initState() {
    super.initState();
    userId = controllerUser.user!.userId;
    iniciarUbicacion();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> iniciarUbicacion() async {
    if (controller.latitud == 0 && controller.longitud == 0) {
      _showLocationPermissionDialog();
    }
  }

  Future<bool> checkIfMember(String grupoId) async {
    try {
      final documentId = userId + grupoId;
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('miembros')
          .doc(documentId)
          .get();

      return document.exists;
    } catch (e) {
      print("Error al verificar membresía: $e");
      return false;
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar sin aceptar
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permisos de ubicación'),
          content: const Text(
              'Esta aplicación requiere permisos de ubicación. Por favor, activa la ubicación.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () async {
                isUbicacion = await controller.getCurrentLocation();
                if (isUbicacion == 'exito') {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double userLat = controller.latitud;
    double userLon = controller.longitud;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 50, right: 20, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/logo_letras.png",
              fit: BoxFit.cover,
              width: 50,
            ),
            const SizedBox(height: 25),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Buscar grupos...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
            const SizedBox(height: 25),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('grupos').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final grupos = snapshot.data?.docs ?? [];

                // Filtrar grupos por búsqueda y distancia
                final filteredGrupos = grupos.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final nombre = data['nombre']?.toLowerCase() ?? '';
                  final latitud = data['latitud'] as double? ?? 0.0;
                  final longitud = data['longitud'] as double? ?? 0.0;

                  final distance =
                      calculateDistance(userLat, userLon, latitud, longitud);
                  return nombre.contains(_searchQuery) && distance <= 250.0;
                }).toList();

                if (filteredGrupos.isEmpty) {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'No se han encontrado resultados.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                }

                return Column(
                  children: filteredGrupos.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final grupoId = doc.id;

                    return FutureBuilder<bool>(
                      future: checkIfMember(grupoId),
                      builder: (context, memberSnapshot) {
                        final isMember = memberSnapshot.data ?? false;

                        if (memberSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor:
                                const Color.fromARGB(255, 255, 255, 255),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      width: 100,
                                      height: 170,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 150,
                                          height: 20,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 10),
                                        Container(
                                          width: 200,
                                          height: 15,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 5),
                                        Container(
                                          width: 180,
                                          height: 15,
                                          color: Colors.grey[300],
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
                                          width: 200,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return OtrosGrupos(
                          member: isMember,
                          onViewGroup: () {
                            print(data);
                            Grupos grupo = Grupos.fromJson(data);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Chat(
                                  grupo: grupo,
                                ),
                              ),
                            );
                          },
                          imageUrl: data['imagen'] ??
                              'https://via.placeholder.com/150',
                          title: data['nombre'] ?? 'Grupo sin título',
                          description: data['description'] ?? 'Sin descripción',
                          onJoin: () async {
                            mostrarAlertaCargando(
                                context, "Estamos añadiendote al grupo...");
                            await FirebaseFirestore.instance
                                .collection('miembros')
                                .doc(controllerUser.user!.userId + grupoId)
                                .set({
                              'grupoId': grupoId,
                              'userId': controllerUser.user!.userId,
                              'tipo': "miembro",
                              'fecha': DateTime.now().millisecondsSinceEpoch,
                            });

                            Navigator.of(context).pop();

                            Grupos grupo = Grupos.fromJson(data);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Chat(
                                  grupo: grupo,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  double degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const int radiusEarthKm = 6371; // Radio de la Tierra en kilómetros
    final double dLat = degreesToRadians(lat2 - lat1);
    final double dLon = degreesToRadians(lon2 - lon1);

    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        cos(degreesToRadians(lat1)) *
            cos(degreesToRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radiusEarthKm * c; // Devuelve la distancia en kilómetros
  }
}
