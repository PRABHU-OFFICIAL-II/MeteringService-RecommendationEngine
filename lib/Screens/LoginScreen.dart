import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recommendation_engine_ipu/Helpers/LoginHelper.dart';
import 'package:recommendation_engine_ipu/Model/User.dart';
import 'package:recommendation_engine_ipu/Screens/DashboardScreen.dart';
import 'package:recommendation_engine_ipu/Screens/HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool passwordVisible = false;

  String userName = "";
  String password = "";
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  late User currentLoggedInUser;
  bool _isChecked = false;
  bool loading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    passwordVisible = true;
  }

  @override
  Widget build(BuildContext context) {
    return loading == true
        ? Center(
            child: CircularProgressIndicator(
            color: Colors.deepOrange,
          ))
        : Row(
            children: [
              Expanded(
                  //<-- Expanded widget
                  child: Image.asset(
                'resources/logo.png',
                fit: BoxFit.cover,
              )),
              Expanded(
                //<-- Expanded widget
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 21),
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Welcome back',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Login to your account',
                        style: GoogleFonts.inter(
                          fontSize: 23,
                          color: Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 35),
                      TextField(
                        controller: userNameController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "Enter your User Name",
                          labelText: "Username",
                          // helperText: "Password must contain special character",

                          alignLabelWithHint: false,
                          filled: true,
                        ),
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        obscureText: passwordVisible,
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: UnderlineInputBorder(),
                          hintText: "Password",
                          labelText: "Password",
                          // helperText: "Password must contain special character",
                          helperStyle: TextStyle(color: Colors.green),
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(
                                () {
                                  passwordVisible = !passwordVisible;
                                },
                              );
                            },
                          ),
                          alignLabelWithHint: false,
                          filled: true,
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 25),
                      Row(
                          //...
                          ),
                      const SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: TextButton(
                          onPressed: () async {
                            userName = userNameController.text;
                            password = passwordController.text;

                            if (userName.length == 0 || password.length == 0) {
                              _showMyDialog(context);

                              // Navigator.pushReplacement(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => HomeScreen()));
                            } else {
                              setState(() {
                                loading = true;
                              });
                              currentLoggedInUser =
                                  await LoginHelper.makeLoginCall(
                                      userName, password);

                              setState(() {
                                loading = false;
                              });


                              //TODO:Add Error Handling here for Login Response

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DashBoardScreen(
                                    currentUser: currentLoggedInUser,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Text(
                            "Login",
                            style: GoogleFonts.albertSans(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),

                          //...
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text('Alert', style: GoogleFonts.albertSans(color: Colors.red),),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[

                Text('Username or Password box cannot be empty'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Re-Entry'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
