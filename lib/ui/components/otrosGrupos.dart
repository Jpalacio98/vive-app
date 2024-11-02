import 'package:flutter/material.dart';

class OtrosGrupos extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;
  final VoidCallback onJoin;
  final VoidCallback onViewGroup; // Callback para el botón "Ver grupo"
  final bool member;

  const OtrosGrupos({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.onJoin,
    required this.onViewGroup,
    required this.member, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Imagen del grupo
          imageUrl == "imagen local" ? ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              'assets/grupo.jpg',
              width: 100,
              height: 170,
              fit:
                  BoxFit.cover, // Asegura que la imagen no salga del contenedor
            ),
           ) :
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: 100,
              height: 170,
              fit:
                  BoxFit.cover, // Asegura que la imagen no salga del contenedor
            ),
          ),
          const SizedBox(width: 10), // Espacio entre imagen y el contenido

          // Column para el título, descripción y botones
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título del grupo
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),

                // Descripción del grupo con máximo de 2 líneas
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  maxLines: 2, // Limita a 2 líneas
                  overflow:
                      TextOverflow.ellipsis, // Añade "..." si es muy largo
                ),
                const SizedBox(height: 20),

                // Botón de "Unirme al grupo"
                !member ? SizedBox(
                  width: 200,
                  child: ElevatedButton(
                    onPressed: onJoin,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue, // Color del botón
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Unirme al grupo'),
                  ),
                ) : Container(),

                const SizedBox(height: 10), // Espacio entre los botones

                // Botón de "Ver grupo"
                member
                    ? SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: onViewGroup,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            backgroundColor:
                                Colors.white, // Fondo blanco para contraste
                            side: const BorderSide(
                                color: Colors.blue), // Borde azul
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Ver Chat'),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
