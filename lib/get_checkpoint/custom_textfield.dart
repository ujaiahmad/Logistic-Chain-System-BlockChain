import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  //const CustomTextField({Key? key}) : super(key: key);
  TextEditingController itemId;
  CustomTextField(this.itemId);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      //alignment: Alignment.center,
      //margin: EdgeInsets.fromLTRB(2, 15, 2, 2),
      width: 100,
      height: 40,
      child: TextField(
          controller: itemId,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
              border: const OutlineInputBorder(),
              // hintText: 'Item Id',
              // hintStyle: TextStyle(color: Colors.black26),
              labelText: 'Item Id',
              labelStyle: TextStyle(color: Colors.blue[600])),
          keyboardType: TextInputType.number),
    );
  }
}
