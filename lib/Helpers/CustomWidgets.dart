import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Model/Role.dart';

class CustomWidgets {
  static AppBar CustomAppBar(String title) {
    return AppBar(
        title: Text(
          title.toString(),
          style: GoogleFonts.comicNeue(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
              icon: Image.asset('resources/phoenix.png'), onPressed: () => {}),
        ]);
  }

  static Widget UserTile(String key, String value) {
    return ListTile(
      title: Row(
        children: [Text("$key : "), Text(value)],
      ),
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  static Widget UserGroupAndRoles() {
    getUserGroupandRoles();

    return const Row(
      children: [
        // ListTile(title: getListofRoles(roles),)
      ],
    );
  }

  static List<Text> getListofRoles(List<Role> roles) {
    List<Text> roleWid = [];
    for (Role role in roles) {
      Text ti = Text(role.name.toString());
      roleWid.add(ti);
    }
    return roleWid;
  }

  static List<Role> getUserGroupandRoles() {
    List<Role> res = [];
    res.add(Role("afas", "oekroekr"));

    res.add(Role("afas", "oekroekr"));

    res.add(Role("afas", "oekroekr"));
    return res;
  }

  static Widget buildSummerCard1() {
    // color = Color(0xffFC9B87) ;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
          borderRadius: BorderRadius.circular(10),
          elevation: 10,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Text(
                "text",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '43124',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              )
            ],
          )),
    );
  }
}
