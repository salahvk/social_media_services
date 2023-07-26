import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:social_media_services/API/endpoint.dart';
import 'package:social_media_services/model/serviceManLIst.dart';
import 'package:social_media_services/providers/data_provider.dart';
import 'package:social_media_services/providers/servicer_provider.dart';
import 'package:social_media_services/screens/serviceman/servicer.dart';
import 'package:social_media_services/utils/animatedSnackBar.dart';
import 'package:social_media_services/utils/snack_bar.dart';

getServiceMan(BuildContext context, id) async {
  //  final otpProvider = Provider.of<OTPProvider>(context, listen: false);
  final provider = Provider.of<DataProvider>(context, listen: false);
  final userDetails = provider.viewProfileModel?.userdetails;
  provider.subServicesModel = null;
  final apiToken = Hive.box("token").get('api_token');
  if (apiToken == null) return;
  try {
    var response = await http.post(
        Uri.parse(
            '$servicemanList?service_id=$id&page=1&latitude=${userDetails?.latitude}&longitude=${userDetails?.longitude}'),
        headers: {"device-id": provider.deviceId ?? '', "api-token": apiToken});
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      log(response.body);
      print("Navigation active");
      navToServiceMan(context, id);
      if (jsonResponse['result'] == false) {
        await Hive.box("token").clear();

        return;
      }

      final serviceManListData = ServiceManListModel.fromJson(jsonResponse);
      provider.getServiceManData(serviceManListData);
      if (provider.serviceManListModel?.serviceman?.isEmpty ?? false) {
        showAnimatedSnackBar(context, "No ServiceMan Available");
      }
    } else {
      // print(response.statusCode);
      // print(response.body);
      // print('Something went wrong');
    }
  } on Exception catch (_) {
 
  }
}

searchServiceMan(
    BuildContext context, id, countryId, state, region, name, transport) async {
  final servicerProvider =
      Provider.of<ServicerProvider>(context, listen: false);
  final provider = Provider.of<DataProvider>(context, listen: false);
  final userDetails = provider.viewProfileModel?.userdetails;
  provider.subServicesModel = null;
  final apiToken = Hive.box("token").get('api_token');
  if (apiToken == null) return;
  try {
    final url =
        '$servicemanList?service_id=$id&page=1&latitude=${servicerProvider.servicerLatitude ?? userDetails?.latitude}&longitude=${servicerProvider.servicerLatitude ?? userDetails?.longitude}&sel_country_id=${countryId ?? ''}&sel_state=${state ?? ''}&sel_region=${region ?? ''}&sel_name=${name ?? ''}&sel_transport=${transport ?? ''}';
    print(url);
    var response = await http.post(Uri.parse(url),
        headers: {"device-id": provider.deviceId ?? '', "api-token": apiToken});
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      log(response.body);

      final serviceManListData = ServiceManListModel.fromJson(jsonResponse);

      provider.getServiceManData(serviceManListData);
      // if (provider.serviceManListModel?.serviceman?.isEmpty ?? false) {
      //   showAnimatedSnackBar(context, "No ServiceMan Available");
      // }
    } else {
      // print(response.statusCode);
      // print(response.body);
      // print('Something went wrong');
    }
  } on Exception catch (_) {
  
  }
}

navToServiceMan(context, id) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) {
    return ServicerPage(
      id: id,
    );
  }));
}
