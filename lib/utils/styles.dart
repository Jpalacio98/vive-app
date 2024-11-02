import 'package:flutter/material.dart';

const TextStyle styleTextSplash = TextStyle(
  fontSize: 30.0,
  fontWeight: FontWeight.bold,
  color: Color.fromARGB(255, 255, 255, 255),
);

bgPrincipal() {
  return const Color(0xffA1D0FF);
}

bg() {
  return const Color.fromARGB(255, 255, 255, 255);
}

primaryColor() {
  return Colors.blue;
}

secondaryColor() {
  return const Color.fromARGB(255, 187, 41, 41);
}

marginBtn(){
  return const EdgeInsets.only(bottom: 5);
}

colorWhite() {
  return const Color.fromARGB(255, 255, 255, 255);
}

paddingDefauld() {
  return const EdgeInsets.symmetric(horizontal: 20);
}

fullWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

fullHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

paddingBtn() {
  return const EdgeInsets.only(top: 15.0, bottom: 15.0);
}
