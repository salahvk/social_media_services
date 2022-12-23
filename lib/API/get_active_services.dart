// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:social_media_services/model/active_services.dart';
import 'package:social_media_services/providers/data_provider.dart';

getActiveServices(
  BuildContext context,
) async {
  final provider = Provider.of<DataProvider>(context, listen: false);

  final apiToken = Hive.box("token").get('api_token');
  if (apiToken == null) return;
  try {
    var response = await http.post(
        Uri.parse(
            'http://projects.techoriz.in/serviceapp/public/api/active-services'),
        headers: {"device-id": provider.deviceId ?? '', "api-token": apiToken});
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      log(response.body);

      final activeServicesResponse = ActiveServices.fromJson(jsonResponse);
      provider.getActiveServicesData(activeServicesResponse);
    } else {
      log("Something Went Wrong50");
      // print(response.statusCode);
      // print(response.body);
      // print('Something went wrong');
    }
  } on Exception catch (e) {
    log("Something Went Wrong50");
    print(e);
  }
}