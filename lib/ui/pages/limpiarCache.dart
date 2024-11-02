import 'package:hive/hive.dart';

Future<void> limpiarBaseDeDatos() async {
  await Hive.deleteBoxFromDisk('mensajes173025380927296160');
  await Hive.deleteBoxFromDisk('mensajes173025498955082465');

  await Hive.deleteBoxFromDisk('ultimoMensaje');
  await Hive.deleteBoxFromDisk('miembros');
  await Hive.deleteBoxFromDisk('grupos');
  // await Hive.deleteBoxFromDisk('auth');
}
