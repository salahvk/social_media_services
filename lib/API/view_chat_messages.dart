// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:social_media_services/API/endpoint.dart';
import 'package:social_media_services/model/view_chat_message_model.dart';
import 'package:social_media_services/providers/data_provider.dart';

viewChatMessages(BuildContext context, id, {page = 1}) async {
  log("view message api calling");
  print(page);
  final provider = Provider.of<DataProvider>(context, listen: false);
  // provider.subServicesModel = null;
  final apiToken = Hive.box("token").get('api_token');
  if (apiToken == null) return;
  try {
    var response = await http.post(
        Uri.parse('$viewChatMessagesApi$id&page=$page'),
        headers: {"device-id": provider.deviceId ?? '', "api-token": apiToken});
    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      // log(response.body);
      // if (jsonResponse['result'] == false) {
      //   await Hive.box("token").clear();

      //   return;
      // }

      final viewChatMessageData = ViewChatMessageModel.fromJson(jsonResponse);
      provider.viewChatMessageModelData(viewChatMessageData);
    } else {
      // print(response.statusCode);
      // print(response.body);
      // print('Something went wrong');
    }
  } on Exception catch (e) {
    log("Something Went Wrong18");
    print(e);
  }
}
