import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vive_app/domain/services/respuestaSign.dart';
import 'package:vive_app/ui/components/btnCustom.dart';
import 'package:vive_app/ui/components/customProgresoSign.dart';
import 'package:vive_app/ui/components/customTextfield1.dart';
import 'package:vive_app/utils/styles.dart';

class Sign3 extends StatefulWidget {
  final String correo;
  const Sign3({super.key, required this.correo});

  @override
  State<Sign3> createState() => _Sign3State();
}

class _Sign3State extends State<Sign3> {
  var _image;

  final TextEditingController nombreController = TextEditingController();

  ImagePicker picker = ImagePicker();

  _camGaleria(bool op) async {
    XFile? image;
    image = op
        ? await picker.pickImage(source: ImageSource.camera, imageQuality: 50)
        : await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = (image != null) ? File(image.path) : null;
    });
  }

  void _opcioncamara(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Imagen de Galeria'),
                    onTap: () {
                      _camGaleria(false);
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Capturar Imagen'),
                  onTap: () {
                    _camGaleria(true);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }

  @override
  void dispose() {
    nombreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Paso 3 de 4",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ProgresoSign(
                      porcentaje: fullWidth(context) * 0.72,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 400,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Text(
                        "Configura tu perfil",
                        style: TextStyle(
                            fontSize: 35,
                            color: Colors.black87,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Container(
                      width: 400,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Text(
                        "Esta es la información que podran ver los otros usuarios acerca de ti.",
                        style: TextStyle(
                            fontSize: 17,
                            color: Colors.black87,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 120,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            padding: _image == null
                                ? const EdgeInsets.only(top: 10)
                                : const EdgeInsets.all(0),
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color.fromARGB(29, 71, 111, 245),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(75),
                                color: const Color.fromARGB(0, 255, 255, 255)),
                            child: ClipOval(
                              child: _image == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                    )
                                  : Image.file(_image!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 14, 144, 196),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  _opcioncamara(context);
                                },
                                icon: const Icon(
                                  Icons.add_photo_alternate,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                iconSize: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField1(
                      text: "Nombre",
                      controller: nombreController,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: BtnCustom(
                onPressed: () {
                  RespuestaSign.verificarImagenName(
                      context: context,
                      correo: widget.correo,
                      image: _image,
                      nombre: nombreController.text);
                },
                bg: primaryColor(),
                textColor: colorWhite(),
                text: "Siguiente",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
