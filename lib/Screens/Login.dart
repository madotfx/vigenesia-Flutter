import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vigenesia/Screens/MainScreens.dart';
import 'package:vigenesia/Screens/Register.dart';
import 'package:vigenesia/Constant/const.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:vigenesia/Models/Login_Model.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late String nama;
  late String iduser;

  // ignore: unused_field
  final GlobalKey<FormBuilderState> _fbkey = GlobalKey<FormBuilderState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login Area',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Form(
                        child: Container(
                      width: MediaQuery.of(context).size.width / 1.3,
                      child: Column(
                        children: [
                          FormBuilderTextField(
                            name: "Email",
                            controller: emailController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                border: OutlineInputBorder(),
                                labelText: "Email"),
                          ),
                          SizedBox(height: 20),
                          FormBuilderTextField(
                            name: "Password",
                            controller: passwordController,
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(left: 10),
                                border: OutlineInputBorder(),
                                labelText: "Password"),
                          ),
                          SizedBox(height: 20),
                          Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                text: 'Kamu Belum Mempunyai Akun?',
                                style: TextStyle(color: Colors.black54),
                              ),
                              TextSpan(
                                  text: 'Daftar',
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  new Register()));
                                    },
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blueAccent)),
                            ]),
                          ),
                          SizedBox(height: 20),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            child: ElevatedButton(
                                onPressed: () async {
                                  await (String email, String password) async {
                                    var dio = Dio();
                                    String baseurl = url;

                                    Map<String, dynamic> data = {
                                      "email": email,
                                      "password": password
                                    };
                                    try {
                                      final Response = await dio.post(
                                          "$baseurl/api/login/",
                                          data: data,
                                          options: Options(headers: {
                                            'Content-type': 'application/json'
                                          }));
                                      print(
                                          "Respon -> ${Response.data} + ${Response.statusCode}");
                                      if (Response.statusCode == 200) {
                                        final loginModel =
                                            LoginModels.fromJson(Response.data);
                                        return loginModel;
                                      }
                                    } catch (e) {
                                      print("Failed To Load $e");
                                    }
                                  }(emailController.text,
                                          passwordController.text)
                                      .then((value) => {
                                            if (value != null)
                                              {
                                                setState(() {
                                                  nama = value.data.nama;
                                                  iduser = value.data.iduser;
                                                  print(
                                                      "ini Data id ---->${iduser}");
                                                  Navigator.pushReplacement(
                                                      context,
                                                      new MaterialPageRoute(
                                                          builder: (BuildContext
                                                                  context) =>
                                                              new MainScreens(
                                                                  iduser:
                                                                      iduser,
                                                                  nama: nama)));
                                                })
                                              }
                                            else if (value == null)
                                              {
                                                Flushbar(
                                                  message:
                                                      "Check Your email / password",
                                                  duration:
                                                      Duration(seconds: 5),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  flushbarPosition:
                                                      FlushbarPosition.TOP,
                                                ).show(context)
                                              }
                                          });
                                },
                                child: Text("Sign In")),
                          )
                        ],
                      ),
                    )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
