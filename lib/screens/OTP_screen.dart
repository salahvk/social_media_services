// ignore_for_file: use_build_context_synchronously, avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hive/hive.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:social_media_services/API/address/getUserAddress.dart';
import 'package:social_media_services/API/endpoint.dart';
import 'package:social_media_services/API/get_chat_list.dart';
import 'package:social_media_services/API/get_serviceManProfileDetails.dart';
import 'package:social_media_services/API/home/get_home.dart';
import 'package:social_media_services/API/get_otp.dart';
import 'package:social_media_services/animations/animtions.dart';
import 'package:social_media_services/components/color_manager.dart';
import 'package:social_media_services/components/styles_manager.dart';
import 'package:social_media_services/controllers/controllers.dart';
import 'package:social_media_services/model/otp/otp_verification.dart';
import 'package:social_media_services/providers/data_provider.dart';
import 'package:social_media_services/providers/otp_provider.dart';
import 'package:social_media_services/responsive/responsive.dart';
import 'package:social_media_services/screens/home_page.dart';
import 'package:social_media_services/utils/pinTheme.dart';
import 'package:social_media_services/screens/edit_profile_screen.dart';
import 'package:social_media_services/utils/snack_bar.dart';
import 'package:social_media_services/API/viewProfile.dart';
import 'package:social_media_services/widgets/terms_and_condition.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

class OTPscreen extends StatefulWidget {
  const OTPscreen({Key? key}) : super(key: key);

  @override
  State<OTPscreen> createState() => _OTPscreenState();
}

class _OTPscreenState extends State<OTPscreen> {
  bool isResendButtonClicked = false;
  bool loading = false;
  String lang = '';

  @override
  void initState() {
    super.initState();
    PhoneNumberControllers.otpCon.text = '';
    lang = Hive.box('LocalLan').get(
      'lang',
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final otpProvider = Provider.of<OTPProvider>(context, listen: false);
    final str = AppLocalizations.of(context)!;
    final mob = Responsive.isMobile(context);

    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: Responsive.isMini(context) ? h * 0.46 : h * .36,
                child: FadeCustomAnimation(
                  delay: .1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          width: w * .6,
                          height: h * .2,
                          child: SvgPicture.asset(
                              'assets/logo/app_logo_green.svg')),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, h * .01, 0, 0),
                        child: Text(str.o_verification,
                            style: getBoldtStyle(
                                color: ColorManager.black, fontSize: 20)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                        child: Text(
                            "${str.o_pls_type} \n+${otpProvider.countryCode} ${otpProvider.phoneNo}",
                            textAlign: TextAlign.center,
                            style: getRegularStyle(
                                color: const Color(0xff9f9f9f),
                                fontSize: mob ? 15 : 12)),
                      ),
                    ],
                  ),
                )),
            FadeSlideCustomAnimation(
              delay: .1,
              isRight: lang == 'ar' ? true : false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, h * .03, 10, 0),
                child: Pinput(
                  defaultPinTheme: defaultPinTheme,
                  separator: const SizedBox(
                    width: 5,
                  ),
                  length: 6,
                  controller: PhoneNumberControllers.otpCon,
                  focusedPinTheme: focusedPinTheme,
                  // validator: (s) {
                  //   return s == '2222' ? null : 'Pin is incorrect';
                  // },
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showCursor: true,
                  onCompleted: (pin) {
                    verifyNow();
                  },
                ),
              ),
            ),
            FadeSlideCustomAnimation(
              delay: .1,
              isRight: lang == 'ar' ? true : false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, h * .05, 0, h * .05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(str.o_dont,
                        style: getRegularStyle(
                            color: const Color(0xff9f9f9f), fontSize: 15)),
                    InkWell(
                      onTap: () async {
                        getOtp(context, {otpProvider.countryCode},
                            {otpProvider.phoneNo}, true);
                        setState(() {
                          isResendButtonClicked = true;
                        });
                        await Future.delayed(const Duration(seconds: 2));
                        setState(() {
                          isResendButtonClicked = false;
                        });
                      },
                      child: isResendButtonClicked
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ColorManager.primary3,
                                backgroundColor: ColorManager.whiteColor,
                              ),
                            )
                          : Text(str.o_resend,
                              style: getRegularStyle(
                                  color: ColorManager.primary, fontSize: 15)),
                    ),
                  ],
                ),
              ),
            ),

            // * Verify Now Button
            FadeSlideCustomAnimation(
              isRight: lang == 'ar' ? true : false,
              delay: .1,
              child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 5,
                        color: Colors.grey.shade400,
                        offset: const Offset(6, 6),
                      ),
                    ],
                  ),
                  width: 220,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(elevation: 0),
                      onPressed: verifyNow,
                      child: loading
                          ? const CircularProgressIndicator(
                              color: ColorManager.primary3,
                              backgroundColor: ColorManager.whiteColor,
                            )
                          : Text(
                              str.o_verify,
                              style: getRegularStyle(
                                  color: ColorManager.whiteText, fontSize: 18),
                            ))),
            ),
            SizedBox(
              height: Responsive.isMobile(context) ? h * .24 : h * .04,
            ),
            const TermsAndCondition()
          ],
        ),
      )),
    );
  }

  verifyNow() async {
    final otpProvider = Provider.of<OTPProvider>(context, listen: false);
    print(PhoneNumberControllers.otpCon.text);
    print(otpProvider.getOtp?.oTP.toString());

    FocusManager.instance.primaryFocus?.unfocus();
    final str = AppLocalizations.of(context)!;
    if (PhoneNumberControllers.otpCon.text.length < 6 ||
        PhoneNumberControllers.otpCon.text.toString() !=
            otpProvider.getOtp?.oTP.toString()) {
      AnimatedSnackBar.material(str.o_snack,
              type: AnimatedSnackBarType.error,
              borderRadius: BorderRadius.circular(6),
              // brightness: Brightness.dark,
              duration: const Duration(seconds: 1))
          .show(
        context,
      );
    } else {
      setState(() {
        loading = true;
      });
      await verifyOtpApi();

      setState(() {
        loading = false;
      });
    }
  }

  verifyOtpApi() async {
    final otpProvider = Provider.of<OTPProvider>(context, listen: false);
    final provider = Provider.of<DataProvider>(context, listen: false);

    try {
      var response = await http.post(
          Uri.parse(
              "$apiUser/otp_verification?countrycode=${otpProvider.countryCode}&phone=${otpProvider.phoneNo}&otp=${otpProvider.getOtp?.oTP.toString()}"),
          headers: {"device-id": provider.deviceId ?? ''});
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        log(response.body);

        var otpVerifiedData = OtpVerification.fromJson(jsonResponse);
        otpProvider.getOtpVerifiedData(otpVerifiedData);
        final apitoken = otpProvider.otpVerification?.customerdetails?.apiToken;
        print(apitoken);

        Hive.box("token").put('api_token', apitoken ?? '');
        await viewProfile(context);
        await getUserAddress(context);
        await getHome(context);
        await getChatList(context);
        provider.viewProfileModel?.userdetails?.userType == 'customer'
            ? null
            : await getServiceManProfileFun(context);

        otpProvider.getOtp!.action!.contains('registration')
            ? navigateToEdit(context)
            : navigateToHome(context);
      } else {
        print('Something went wrong');
      }
    } on Exception catch (_) {
      showSnackBar("Connection Timed Out", context);
    }
  }
}

navigateToHome(BuildContext context) {
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx) {
    return const HomePage();
  }), (route) => false);
}

navigateToEdit(BuildContext context) {
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (ctx) {
    return EditProfileScreen();
  }), (route) => false);
}
