import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prd/utils/config.dart';
import 'package:prd/utils/jml_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final userName = TextEditingController();
  final plantName = TextEditingController();
  bool userBool=false;
  final password = TextEditingController();
  bool showError = false;
  bool passWordColor = false;
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode plantFocusNode = FocusNode();
  bool showHidePassword=true;
  void passwordHideAndViewFunc(){
    setState(() {
      showHidePassword = !showHidePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              height: 220,
              width: 500,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: Colors.white,),
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        decoration:   const BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10)),
                          color:Colors.white,
                          //Color(0xff00004d),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Image.asset("assets/logo/jmi_logo.png"),
                            )
                          ],
                        ),
                      )
                  ),
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration:  BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(10),
                            bottomRight: Radius.circular(10)),
                        color: Colors.blue[50],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, right: 20, bottom: 20, left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Welcome",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
                            SizedBox(
                              height: 30,
                              child: TextField(
                                controller: userName,
                                style: const TextStyle(fontSize: 12),
                                decoration: decorationInput3("User Name", userBool),
                                onEditingComplete: () {
                                  FocusScope.of(context).requestFocus(passwordFocusNode);
                                },
                              ),
                            ),
                            SizedBox(
                              height: 30,
                              child: TextField(
                                controller: password,
                                obscureText: showHidePassword,
                                enableSuggestions: false,
                                autocorrect: false,
                                style: const TextStyle(fontSize: 12),
                                decoration: decorationInputPassword("Password", userBool,showHidePassword,passwordHideAndViewFunc),
                                onEditingComplete: () {
                                  postLogin(userName, password, plantName).then((value) {
                                    if(value != null){
                                      Navigator.of(context).push(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                HomeScreen(
                                                  selectedDestination: 0,
                                                  drawerWidth: 190,
                                                  plantValue: value,
                                                ),
                                          )
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Login failed. Invalid username, password'),
                                        ),
                                      );
                                    }
                                  });
                                },
                              ),
                            ),
                            // SizedBox(
                            //   height: 30,
                            //   child: TextField(
                            //     controller: plantName,
                            //     style: const TextStyle(fontSize: 12),
                            //     decoration: decorationInput3("Plant Name", userBool),
                            //     onEditingComplete: () {
                            //       postLogin(userName, password, plantName).then((value) {
                            //         if(value != null){
                            //           Navigator.of(context).push(
                            //               PageRouteBuilder(
                            //                 pageBuilder: (context, animation, secondaryAnimation) =>
                            //                     HomeScreen(
                            //                       selectedDestination: 0,
                            //                       drawerWidth: 190,
                            //                       plantValue: value,
                            //                     ),
                            //               )
                            //           );
                            //         } else {
                            //           ScaffoldMessenger.of(context).showSnackBar(
                            //             const SnackBar(
                            //               content: Text('Login failed. Invalid username, password, or plant.'),
                            //             ),
                            //           );
                            //         }
                            //       });
                            //     },
                            //   ),
                            // ),
                            Container(
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                color: Color(0xff00004d),
                              ),
                              child: TextButton(onPressed: () {
                                postLogin(userName, password, plantName).then((value) {
                                  if(value != null){
                                    Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation, secondaryAnimation) =>
                                              HomeScreen(
                                                selectedDestination: 0,
                                                drawerWidth: 190,
                                                plantValue: value,
                                              ),
                                        )
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Login failed. Invalid username, password.'),
                                      ),
                                    );
                                  }
                                });
                              },
                                  child: const Text("Login",style:  TextStyle(color: Colors.white,),)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future postLogin(TextEditingController userName, TextEditingController password, TextEditingController plant) async{
    String url = "${StaticData.apiURL}/YY1_USERCRED_CDS/YY1_USERCRED?filter=UserName eq '${userName.text}' and Password eq '${password.text}'";
    try{
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': StaticData.basicAuth,
        },
      );

      if (response.statusCode == 200) {
        Map responseData ={};
        try{
          responseData= jsonDecode(response.body);
          if(responseData.containsKey("d") && responseData["d"]["results"].isNotEmpty){
            String plantValue = responseData["d"]["results"][0]["Plant"];
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('userName', userName.text);
            prefs.setString('password', password.text);
            prefs.setString('plant', plantValue);
            return plantValue;
          } else {
            print("Login failed: No user found");
            return null;
          }
        }
        catch(e){
          log(response.body);
          return null;
        }
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    }catch(e){
      print("Exception during login: $e");
      return null;
    }
  }
  decorationInput3(String hintString, bool val,) {
    return  InputDecoration(

        label: Text(
          hintString,
        ),
        counterText: '',labelStyle: const TextStyle(fontSize: 12),
        contentPadding:  const EdgeInsets.fromLTRB(12, 00, 0, 0),
        hintText: hintString,
        suffixIconColor: const Color(0xfff26442),
        disabledBorder:  const OutlineInputBorder(borderSide:  BorderSide(color:  Colors.white)),
        enabledBorder:const OutlineInputBorder(borderSide:  BorderSide(color: mTextFieldBorder)),
        focusedBorder:  const OutlineInputBorder(borderSide:  BorderSide(color:Color(0xff00004d))),
        border:   const OutlineInputBorder(borderSide:  BorderSide(color:Color(0xff00004d)))
    );
  }
  decorationInputPassword(String hintString, bool val, bool passWordHind,  passwordHideAndView, ) {
    return InputDecoration(
        label: Text(
          hintString,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            passWordHind ? Icons.visibility : Icons.visibility_off,size: 20,
          ),
          onPressed: passwordHideAndView,
        ),suffixIconColor: val?const Color(0xff00004d):Colors.grey,
        // suffixIconColor:val?  const Color(0xff00004d):Colors.grey,
        counterText: "",
        contentPadding: const EdgeInsets.fromLTRB(12, 00, 0, 0),
        hintText: hintString,labelStyle: const TextStyle(fontSize: 12,),

        disabledBorder:  const OutlineInputBorder(borderSide:  BorderSide(color:  Colors.white)),
        enabledBorder:const OutlineInputBorder(borderSide:  BorderSide(color: mTextFieldBorder)),
        focusedBorder:  const OutlineInputBorder(borderSide:  BorderSide(color: Color(0xff00004d))),
        border:   const OutlineInputBorder(borderSide:  BorderSide(color: Color(0xff00004d)))

    );
  }

}
