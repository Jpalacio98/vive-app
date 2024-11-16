 import 'dart:convert';

import 'package:vive_app/ui/components/aditionalsFuntions.dart';
 

 void main() {
  
 String name = "hola mundo";
  String m1 = "miembro1";
  String m2 = "miembro2";
 List<String> members =[m1, m2];


String  cuerpo =jsonEncode({
        'topicName': toCamelCase(name),
        'tokens': members,
      });
print(cuerpo);

}