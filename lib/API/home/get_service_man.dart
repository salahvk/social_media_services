import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:social_media_services/API/endpoint.dart';
import 'package:social_media_services/providers/data_provider.dart';
import 'package:social_media_services/screens/servicer.dart';
import 'package:social_media_services/utils/snack_bar.dart';

getServiceMan(BuildContext context, id) async {
  //  final otpProvider = Provider.of<OTPProvider>(context, listen: false);
  final provider = Provider.of<DataProvider>(context, listen: false);
  provider.subServicesModel = null;
  final apiToken = Hive.box("token").get('api_token');
  if (apiToken == null) return;
  try {
    var response = await http.post(
        Uri.parse('$servicemanList?service_id=$id&page=1'),
        headers: {"device-id": provider.deviceId ?? '', "api-token": apiToken});
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      log(response.body);
      navToServiceMan(context);
      if (jsonResponse['result'] == false) {
        await Hive.box("token").clear();

        return;
      }

      // final subServicesData = SubServicesModel.fromJson(jsonResponse);
      // provider.subServicesModelData(subServicesData);

    } else {
      // print(response.statusCode);
      // print(response.body);
      // print('Something went wrong');
    }
  } on Exception catch (_) {
    showSnackBar("Something Went Wrong1", context);
  }
}

navToServiceMan(context) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) {
    return const ServicerPage();
  }));
}