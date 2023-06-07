import 'dart:async';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:social_media_services/API/endpoint.dart';
import 'package:social_media_services/API/get_otp.dart';
import 'package:social_media_services/animations/animtions.dart';
import 'package:social_media_services/components/color_manager.dart';
import 'package:social_media_services/components/styles_manager.dart';
import 'package:social_media_services/controllers/controllers.dart';
import 'package:social_media_services/main.dart';
import 'package:social_media_services/model/get_countries.dart';
import 'package:social_media_services/providers/data_provider.dart';
import 'package:social_media_services/providers/otp_provider.dart';
import 'package:social_media_services/widgets/terms_and_condition.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({Key? key}) : super(key: key);

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  Countries? selectedValue;
  String? countryCode;
  String lang = '';
  List<Countries> r = [];
  bool isPickerSelected = false;
  Timer? _debounce;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    PhoneNumberControllers.phoneNumCon.text = '';
    countryCode = "968";
    lang = Hive.box('LocalLan').get(
      'lang',
    );

    r.clear();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final provider = Provider.of<DataProvider>(context, listen: false);
      r = (provider.countriesModel!.countries)!;
      setTimer();
    });
    print(r);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // print(size.height);
    // print(size.width);
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final str = AppLocalizations.of(context)!;
    final provider = Provider.of<DataProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        setState(() {
          isPickerSelected = false;
        });
      },
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: SingleChildScrollView(
          // reverse: true,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeCustomAnimation(
                    delay: .1,
                    child: SizedBox(
                      height: size.height * 0.36,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              0, size.height * .13, 0, size.height * .04),
                          child: SizedBox(
                              width: size.width * .6,
                              height: size.height * .2,
                              child: SvgPicture.asset(
                                  'assets/logo/app_logo_green.svg')),
                        ),
                      ),
                    ),
                  ),

                  FadeSlideCustomAnimation(
                    isRight: lang == 'ar' ? true : false,
                    delay: .1,
                    child: Padding(
                      padding:
                          EdgeInsets.fromLTRB(20, size.height * .025, 20, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10.0,
                              color: Colors.grey.shade300,
                              offset: const Offset(5, 8.5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: ColorManager.whiteColor,
                            ),
                            // width: 500,
                            height: size.height * .07,

                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      isPickerSelected = true;
                                    });
                                  },
                                  child: SizedBox(
                                      width: size.width * .18,
                                      height: size.height * .07,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 3, 0),
                                          child: Text(
                                            "+${countryCode.toString()}",
                                            style: getRegularStyle(
                                                color: ColorManager
                                                    .paymentPageColor2,
                                                fontSize: 16),
                                          ),
                                        ),
                                      )),
                                ),
                                Container(
                                  height: 40,
                                  width: .6,
                                  color: ColorManager.grayLight,
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                    child: SizedBox(
                                  child: TextField(
                                      keyboardType: TextInputType.phone,
                                      controller:
                                          PhoneNumberControllers.phoneNumCon,
                                      style: const TextStyle(),
                                      maxLength: 10,
                                      decoration: InputDecoration(
                                          counterText: '',
                                          contentPadding: const EdgeInsets.only(
                                              left: 0,
                                              right: 10,
                                              top: 0,
                                              bottom: 0),
                                          hintText: str.m_ent_mob_no,
                                          hintStyle: getRegularStyle(
                                              color: ColorManager.grayLight,
                                              fontSize: 15))),
                                ))
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  FadeSlideCustomAnimation(
                    isRight: lang == 'ar' ? true : false,
                    delay: .1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(40, 40, 40, 30),
                      child: Text(str.m_sub1,
                          textAlign: TextAlign.center,
                          style: getRegularStyle(
                              color: ColorManager.grayLight, fontSize: 15)),
                    ),
                  ),
                  FadeSlideCustomAnimation(
                    isRight: lang == 'ar' ? true : false,
                    delay: .1,
                    child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4.5,
                              color: Colors.grey.shade400,
                              offset: const Offset(6, 6),
                            ),
                          ],
                        ),
                        width: 220,
                        height: 50,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(elevation: 0),
                            onPressed: onContinue,
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: ColorManager.primary3,
                                    backgroundColor: ColorManager.whiteColor,
                                  )
                                : Text(
                                    str.m_continue,
                                    style: getRegularStyle(
                                        color: ColorManager.whiteText,
                                        fontSize: 18),
                                  ))),
                  ),
                  // const TroubleSign(),
                  // const Spacer(),
                  SizedBox(
                    height: size.height < 600 ? h * .13 : h * .23,
                  ),
                  const TermsAndCondition()
                ],
              ),
              isPickerSelected
                  ? Positioned(
                      top: size.height * .458,
                      right: lang == 'ar' ? size.width * .05 : null,
                      left: lang != 'ar' ? size.width * .05 : null,
                      child: FadeCustomAnimation(
                        delay: .005,
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10.0,
                                color: Colors.grey.shade300,
                                offset: const Offset(3, 8.5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: ColorManager.primary2,
                              ),
                              height: 200,
                              width: 200,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SizedBox(
                                        height: 40,
                                        child: TextField(
                                          onChanged: (value) async {
                                            String capitalize(String s) =>
                                                s[0].toUpperCase() +
                                                s.substring(1);

                                            if (value.isEmpty) {
                                              print('empty');
                                              r = [];
                                              setState(() {
                                                r = (provider.countriesModel!
                                                    .countries)!;
                                              });
                                            } else {
                                              final lower = capitalize(value);

                                              _onSearchChanged(lower);
                                            }

                                            // print(r);
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                          itemCount: r.length,
                                          shrinkWrap: true,
                                          itemBuilder: (ctx, index) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  countryCode = r[index]
                                                      .phonecode
                                                      .toString();
                                                  r = (provider.countriesModel!
                                                      .countries)!;
                                                  isPickerSelected = false;
                                                });
                                              },
                                              child: Container(
                                                width: 100,
                                                height: 35,
                                                color: ColorManager.primary2,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 0, 5, 0),
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      CachedNetworkImage(
                                                          errorWidget: (context,
                                                                  url, error) =>
                                                              Container(
                                                                width: 25,
                                                                height: 20,
                                                                color: ColorManager
                                                                    .whiteColor,
                                                              ),
                                                          imageBuilder: (context,
                                                                  imageProvider) =>
                                                              Container(
                                                                width: 25,
                                                                height: 20,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  // shape: BoxShape.circle,
                                                                  image: DecorationImage(
                                                                      image:
                                                                          imageProvider,
                                                                      fit: BoxFit
                                                                          .cover),
                                                                ),
                                                              ),
                                                          // width: 90,
                                                          progressIndicatorBuilder:
                                                              (context, url,
                                                                  progress) {
                                                            return Container(
                                                              color:
                                                                  ColorManager
                                                                      .black,
                                                            );
                                                          },
                                                          imageUrl:
                                                              '$endPoint${r[index].countryflag}'),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                          "+${r[index].phonecode.toString()}",
                                                          style: getSemiBoldtStyle(
                                                              color: ColorManager
                                                                  .background,
                                                              fontSize: 13)),
                                                      const SizedBox(
                                                        width: 8,
                                                      ),
                                                      Text(
                                                          overflow: TextOverflow
                                                              .fade,
                                                          // softWrap: true,
                                                          r[index]
                                                                      .countryName!
                                                                      .length >
                                                                  22
                                                              ? r[index]
                                                                      .countryName
                                                                      ?.substring(
                                                                          0,
                                                                          22) ??
                                                                  ''
                                                              : r[index]
                                                                      .countryName ??
                                                                  '',
                                                          style:
                                                              getSemiBoldtStyle(
                                                                  color: ColorManager
                                                                      .background,
                                                                  fontSize: r[index]
                                                                              .countryName!
                                                                              .length <
                                                                          12
                                                                      ? 12
                                                                      : r[index].countryName!.length <
                                                                              20
                                                                          ? 10
                                                                          : r[index].countryName!.length > 25
                                                                              ? 10
                                                                              : 10)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container()
            ],
          ),
        )),
      ),
    );
  }

  onContinue() async {
    searchCountryName(countryCode ?? '');
    FocusManager.instance.primaryFocus?.unfocus();
    final OtpProvider = Provider.of<OTPProvider>(context, listen: false);
    final str = AppLocalizations.of(context)!;
    final phoneNumber = PhoneNumberControllers.phoneNumCon.text.trim();
    if (phoneNumber.isEmpty) {
      AnimatedSnackBar.material(str.m_snack,
              type: AnimatedSnackBarType.error,
              borderRadius: BorderRadius.circular(6),
              duration: const Duration(seconds: 1))
          .show(
        context,
      );
    } else if (phoneNumber.length < 5) {
      AnimatedSnackBar.material(str.snack_phone_digits,
              type: AnimatedSnackBarType.error,
              borderRadius: BorderRadius.circular(6),
              duration: const Duration(seconds: 1))
          .show(
        context,
      );
    } else {
      final phoneNo = PhoneNumberControllers.phoneNumCon.text;
      OtpProvider.getPhoneNo(phoneNo);
      OtpProvider.getCountryCode(countryCode);
      setState(() {
        loading = true;
      });
      await getOtp(context, countryCode, phoneNo, false);
      print(OtpProvider.getOtp?.oTP.toString());
      setState(() {
        loading = false;
      });
    }
  }

// * Flutter internationalizing functions

  setTimer() {
    Future.delayed(const Duration(seconds: 1));
    getlocalLanguage();
  }

  getlocalLanguage() {
    lang = Hive.box('LocalLan').get(
      'lang',
    );
    if (!mounted) return;
    MyApp.of(context).setLocale(
      Locale.fromSubtags(
        languageCode: lang,
      ),
    );
  }

//  * Country code search function

  _onSearchChanged(String query) {
    setState(() {
      r = [];
    });
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(microseconds: 200), () {
      s(query);
    });
  }

  s(filter) {
    final provider = Provider.of<DataProvider>(context, listen: false);
    final otpProvider = Provider.of<OTPProvider>(context, listen: false);
    provider.countriesModel?.countries?.forEach((element) {
      final m = element.countryName?.contains(filter);

      if (m == true) {
        setState(() {
          // r = [];
          r.add(element);
        });
      }

      final phoneCode = element.phonecode?.toString().contains(filter);

      if (phoneCode == true) {
        setState(() {
          // r = [];
          r.add(element);
        });
      }
    });
  }

  searchCountryName(code) {
    final provider = Provider.of<DataProvider>(context, listen: false);
    final otpProvider = Provider.of<OTPProvider>(context, listen: false);
    provider.countriesModel?.countries?.forEach((element) {
      if (code == element.phonecode?.toString()) {
        print(element.countryName);
        otpProvider.userCountryName = element.countryName;
      }
    });
  }
}
