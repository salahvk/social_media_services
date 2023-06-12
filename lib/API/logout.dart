// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:social_media_services/API/endpoint.dart';
import 'package:social_media_services/providers/data_provider.dart';

logoutFun(BuildContext context) async {
  //  final otpProvider = Provider.of<OTPProvider>(context, listen: false);
  final provider = Provider.of<DataProvider>(context, listen: false);
  final apiToken = Hive.box("token").get('api_token');
  try {
    var response = await http.post(Uri.parse(logout),
        headers: {"device-id": provider.deviceId ?? '', "api-token": apiToken});
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
    } else {
      print(response.statusCode);
      print(response.body);
      log("Something Went Wrong15");
    }
  } on Exception catch (e) {
    log("Something Went Wrong14");
    print(e);
  }
}

deleteAccountFun(BuildContext context) async {
  //  final otpProvider = Provider.of<OTPProvider>(context, listen: false);
  final provider = Provider.of<DataProvider>(context, listen: false);
  final apiToken = Hive.box("token").get('api_token');
  try {
    var response = await http.post(Uri.parse(deleteApi),
        headers: {"device-id": provider.deviceId ?? '', "api-token": apiToken});
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
    } else {
      print(response.statusCode);
      print(response.body);
      log("Something Went Wrong15");
    }
  } on Exception catch (e) {
    log("Something Went Wrong14");
    print(e);
  }
}
