import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vive_app/infrastructure/controllers/controllerUser.dart';
import 'package:vive_app/ui/components/btnCustom.dart';
import 'package:vive_app/ui/components/customTextfield1.dart';
import 'package:vive_app/ui/pages/seguridad.dart';
import 'package:vive_app/utils/styles.dart';

class Cuenta extends StatefulWidget {
  const Cuenta({super.key});

  @override
  State<Cuenta> createState() => _CuentaState();
}

class _CuentaState extends State<Cuenta> {
  var _image;

  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();
  final ControllerUser controllerUser = Get.find();

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
  void initState() {
    super.initState();
    nombreController.text = controllerUser.user!.nombre;
    correoController.text = controllerUser.user!.correo;
  }

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: primaryColor(),
        title: const Text(
          "Configuración de la cuenta",
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
                    const SizedBox(height: 20),
                    const SizedBox(height: 40),
                    Container(
                        width: 400,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "Imagen de Perfil",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        )),
                    SizedBox(
                      width: 120,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color.fromARGB(29, 71, 111, 245),
                                  width: 3,
                                ),
                                borderRadius: BorderRadius.circular(75),
                                color: const Color.fromARGB(0, 255, 255, 255)),
                            child: ClipOval(
                              child: _image == null
                                  ? Image.network('${controllerUser.user!.imageUrl}?${DateTime.now().millisecondsSinceEpoch}',
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover)
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
                    Container(
                        width: 400,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Text(
                          "Datos Personales",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        )),
                    const SizedBox(height: 20),
                    CustomTextField1(
                      text: "Nombre",
                      controller: nombreController,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField1(
                      text: "Correo",
                      controller: correoController,
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
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Seguridad(
                        correo: correoController.text,
                        image: _image,
                        nombre: nombreController.text,
                      ),
                    ),
                  );
                  
                },
                bg: primaryColor(),
                textColor: colorWhite(),
                text: "Guardar",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
