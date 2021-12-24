import 'dart:convert';
// ignore: unused_import
import 'dart:core';
// ignore: unused_import
import 'dart:html';
// ignore: unused_import
import 'dart:math';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import 'package:vigenesia/Screens/Login.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:vigenesia/Models/Motivasi_Model.dart';
import 'package:dio/dio.dart';
import 'package:vigenesia/Constant/const.dart';
// ignore: unused_import
import 'package:vigenesia/Screens/EditPage.dart';

class MainScreens extends StatefulWidget {
  final String iduser;
  final String nama;
  const MainScreens({Key? key, required this.iduser, required this.nama})
      : super(key: key);

  @override
  _MainScreensState createState() => _MainScreensState();
}

class _MainScreensState extends State<MainScreens> {
  String baseurl = url;
  String? id;
  var dio = Dio();
  List<MotivasiModel> ass = [];
  TextEditingController titleController = TextEditingController();

  Future<dynamic> sendMotivasi(String isi) async {
    Map<String, dynamic> body = {
      "isi_motivasi": isi,
      "iduser": widget.iduser,
    };
    try {
      Response response = await dio.post(
          "$baseurl/vigenesia/api/dev/POSTmotivasi",
          data: body,
          options: Options(contentType: Headers.formUrlEncodedContentType));
      print("Respon -> ${response.data} + ${response.statusCode}");

      return response;
    } catch (e) {
      print("Error di -> $e");
    }
  }

  List<MotivasiModel> listproduk = [];

  Future<List<MotivasiModel>> getData() async {
    var response = await dio
        .get('$baseurl/vigenesia/api/Get_motivasi?iduser=${widget.iduser}');
    print("${response.data}");
    if (response.statusCode == 200) {
      var getUsersData = response.data as List;
      var listUsers =
          getUsersData.map((i) => MotivasiModel.fromJson(i)).toList();
      return listUsers;
    } else {
      throw Exception('Failed To Load');
    }
  }

  Future<dynamic> deletePost(String id) async {
    dynamic data = {
      "id": id,
    };
    var response = await dio.delete('$baseurl/vigenesia/api/dev/DELETEmotivasi',
        data: data,
        options: Options(
            contentType: Headers.formUrlEncodedContentType,
            headers: {"Content-type": "application/json"}));

    print("${response.data}");
    var resbody = jsonDecode(response.data);
    return resbody;
  }

  Future<List<MotivasiModel>> getData2() async {
    var response = await dio.get('$baseurl/vigenesia/api/Get_motivasi');
    print("${response.data}");
    if (response.statusCode == 200) {
      var getUsersData = response.data as List;
      var listUsers =
          getUsersData.map((i) => MotivasiModel.fromJson(i)).toList();
      return listUsers;
    } else {
      throw Exception('Failed To Load');
    }
  }

  Future<void> _getData() async => setState(() {
        getData();
        listproduk.clear();
      });

  TextEditingController isiController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData2();
    _getData();
  }

  String? trigger;
  String? triggeruser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
            child: Container(
          padding: const EdgeInsets.only(left: 30.0, right: 30.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              height: 40,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                "Hallo ${widget.nama}",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              TextButton(
                child: Icon(Icons.logout),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      new MaterialPageRoute(
                        builder: (BuildContext context) => new Login(),
                      ));
                },
              ),
            ]),
            SizedBox(
              height: 30,
            ),
            FormBuilderTextField(
              controller: isiController,
              name: "isi_motivasi",
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.only(left: 10),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: ElevatedButton(
                onPressed: () async {
                  if (isiController.text.toString().isEmpty) {
                    Flushbar(
                      message: "Tidak Boleh Kosong",
                      duration: Duration(seconds: 2),
                      backgroundColor: Colors.redAccent,
                      flushbarPosition: FlushbarPosition.TOP,
                    ).show(context);
                  } else if (isiController.text.toString().isNotEmpty) {
                    await sendMotivasi(
                      isiController.text.toString(),
                    ).then((value) => {
                          if (value != null)
                            {
                              Flushbar(
                                message: "Berhasil Submit",
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.greenAccent,
                                flushbarPosition: FlushbarPosition.TOP,
                              ).show(context)
                            }
                        });
                  }

                  print("Sukses");
                },
                child: Text("Submit"),
              ),
            ),
            SizedBox(
              child: CircularProgressIndicator(),
              height: 40,
            ),
            TextButton(
                child: Icon(Icons.refresh),
                onPressed: () {
                  _getData();
                }),
            FormBuilderRadioGroup(
                onChanged: (value) {
                  setState(() {
                    trigger = value as String;
                    print("HASILNYA --> ${trigger}");
                  });
                },
                name: "_",
                options: ["Motivasi By All User", "Motivasi By User"]
                    .map((e) =>
                        FormBuilderFieldOption(value: e, child: Text("${e}")))
                    .toList()),
            trigger == "Motivasi By All"
                ? FutureBuilder(
                    future: getData2(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<MotivasiModel>> snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          child: Column(
                            children: [
                              for (var item in snapshot.data!)
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView(
                                    shrinkWrap: true,
                                    children: [
                                      Container(child: Text(item.isiMotivasi)),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        );
                      } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                        return Text("No Data");
                      } else {
                        return CircularProgressIndicator();
                      }
                    })
                : Container(),
            trigger == "Motivasi By User"
                ? FutureBuilder(
                    future: getData(),
                    builder: (BuildContext context,
                        AsyncSnapshot<List<MotivasiModel>> snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                          children: [
                            for (var item in snapshot.data!)
                              Container(
                                width: MediaQuery.of(context).size.width,
                                child: ListView(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(child: Text(item.isiMotivasi)),
                                        Row(children: [
                                          TextButton(
                                            child: Icon(Icons.settings),
                                            onPressed: () {
                                              // ignore: unused_local_variable
                                              String id;
                                              // ignore: unused_local_variable
                                              String isi_motivasi;
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (BuildContext
                                                            context) =>
                                                        EditPage(
                                                            id: item.id,
                                                            isi_motivasi: item
                                                                .isiMotivasi),
                                                  ));
                                            },
                                          ),
                                          TextButton(
                                            child: Icon(Icons.delete),
                                            onPressed: () {
                                              deletePost(item.id)
                                                  .then((value) => {
                                                        if (value != null)
                                                          {
                                                            Flushbar(
                                                              message:
                                                                  "Berhasil Delete",
                                                              duration:
                                                                  Duration(
                                                                      seconds:
                                                                          2),
                                                              backgroundColor:
                                                                  Colors
                                                                      .redAccent,
                                                              flushbarPosition:
                                                                  FlushbarPosition
                                                                      .TOP,
                                                            ).show(context)
                                                          }
                                                      });
                                              getData();
                                            },
                                          ),
                                        ])
                                      ],
                                    )
                                  ],
                                ),
                              )
                          ],
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.hasError}");
                      } else {
                        return Text("No Data");
                      }
                    })
                : Container(),
          ]),
        )),
      ),
    );
  }
}
