import 'package:flutter/material.dart';

class SearchBar1 extends StatelessWidget {
  final Function(String value) onChanged;

  const SearchBar1({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255), // Color de fondo suave
        borderRadius: BorderRadius.circular(5), // Borde con radio de 5
        border: Border.all(
          color: const Color.fromARGB(255, 230, 230, 230), // Color del borde
          width: 1, // Grosor del borde
        ),
      ),
      child: TextField(
        onChanged: (value) {
          onChanged(value);
        },
        decoration: const InputDecoration(
          hintText: 'Buscar en mis grupos',
          hintStyle:
              TextStyle(color: Color(0xFF828282), fontWeight: FontWeight.w400),
          prefixIcon: Icon(Icons.search,
              color: Color.fromARGB(255, 230, 230, 230)), // Icono de búsqueda
          border: InputBorder.none, // Sin borde adicional
          contentPadding:
              EdgeInsets.symmetric(vertical: 15), // Espacio vertical
        ),
      ),
    );
  }
}
