import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:recommendation_engine_ipu/Helpers/Constants.dart';

import 'package:flutter/material.dart';
import '../Model/User.dart';

class LoginHelper {


  static Future<User> makeLoginCall(String username, String password) async {
    print("USER NAME  : " + username);
    print("Password : " + password);
    var response = await http.post(
    Uri.parse( Constants.USW1_AWS_POD1_LoginURL.toString()),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode(
        {
          "type": "login",
          "username": username,
          "password": password,
        },
      ),
    );
    print(response.body);
    Map<String, dynamic> jsonMap = json.decode(response.body);

    User currUser =  User.fromJson(jsonMap);

    print("Current User Name: "+currUser.firstName.toString());

    return currUser;

  }



}
