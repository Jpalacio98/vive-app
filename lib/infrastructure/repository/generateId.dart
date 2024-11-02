import 'dart:math'; 

class Generateid {
  static String generateUuid() {
    final random = Random(); 
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return '${_randomString(6, random)}-$timestamp-${_randomString(6, random)}';
  } 

  static String _randomString(int length, Random random) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
}
