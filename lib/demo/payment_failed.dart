import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:screenshot/screenshot.dart';
import 'package:social_media_services/responsive/responsive_width.dart';
import 'package:social_media_services/components/assets_manager.dart';
import 'package:social_media_services/components/color_manager.dart';
import 'package:social_media_services/components/styles_manager.dart';
import 'package:social_media_services/screens/home_page.dart';
import 'package:social_media_services/screens/messagePage.dart';
import 'package:social_media_services/screens/serviceHome.dart';
import 'package:social_media_services/utils/pdfApi.dart';
import 'package:social_media_services/widgets/custom_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PaymentFailurePage extends StatefulWidget {
  const PaymentFailurePage({Key? key}) : super(key: key);

  @override
  State<PaymentFailurePage> createState() => _PaymentFailurePageState();
}

class _PaymentFailurePageState extends State<PaymentFailurePage> {
  int _selectedIndex = 2;
  final List<Widget> _screens = [const ServiceHomePage(), const MessagePage()];
  final player = AudioPlayer();
  bool isProgress = true;
  String lang = '';
  ScreenshotController screenshotController = ScreenshotController();
  bool isLoading = false;

  // paySuccessSound() async {
  //   final duration = await player.setAsset('assets/Gpay.mp3');
  // }

  @override
  void initState() {
    super.initState();
    // paySuccessSound();
    lang = Hive.box('LocalLan').get(
      'lang',
    );

    Future.delayed(const Duration(seconds: 0), () {
      setState(() {
        isProgress = false;
      });
      player.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final str = AppLocalizations.of(context)!;
    final w = MediaQuery.of(context).size.width;
    final mobWth = ResponsiveWidth.isMobile(context);
    final smobWth = ResponsiveWidth.issMobile(context);
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      endDrawer: SizedBox(
        height: size.height * 0.825,
        width: mobWth
            ? size.width * 0.6
            : smobWth
                ? w * .7
                : w * .75,
        child: const CustomDrawer(),
      ),
      // * Custom bottom Nav
      bottomNavigationBar: Stack(
        children: [
          Container(
            height: 45,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                blurRadius: 5.0,
                color: Colors.grey.shade400,
                offset: const Offset(6, 1),
              ),
            ]),
          ),
          SizedBox(
            height: 44,
            child: GNav(
              tabMargin: const EdgeInsets.symmetric(
                vertical: 0,
              ),
              gap: 0,
              backgroundColor: ColorManager.whiteColor,
              mainAxisAlignment: MainAxisAlignment.center,
              activeColor: ColorManager.grayDark,
              iconSize: 24,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: ColorManager.primary.withOpacity(0.4),
              color: ColorManager.black,
              tabs: [
                GButton(
                  icon: FontAwesomeIcons.message,
                  leading: SizedBox(
                    width: 24,
                    height: 24,
                    child: SvgPicture.asset(ImageAssets.homeIconSvg),
                  ),
                ),
                GButton(
                  icon: FontAwesomeIcons.message,
                  leading: SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.asset(ImageAssets.chatIconSvg)),
                ),
              ],
              haptic: true,
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
          Positioned(
              left: lang == 'ar' ? 5 : null,
              right: lang != 'ar' ? 5 : null,
              bottom: 0,
              child: Builder(
                builder: (context) => InkWell(
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.menu,
                      size: 25,
                      color: ColorManager.black,
                    ),
                  ),
                ),
              ))
        ],
      ),
      body: _selectedIndex != 2
          ? _screens[_selectedIndex]
          : SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Screenshot(
                      controller: screenshotController,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 20,
                          ),
                          isProgress
                              ? const SizedBox(
                                  height: 280,
                                  width: 280,
                                  child: Center(
                                    child: SizedBox(
                                        height: 90,
                                        width: 90,
                                        child: CircularProgressIndicator(
                                          backgroundColor: ColorManager.primary,
                                          color: ColorManager.whiteColor,
                                          strokeWidth: 5,
                                        )),
                                  ))
                              : SizedBox(
                                  height: 180,
                                  child: Stack(
                                    alignment: AlignmentDirectional.center,
                                    children: [
                                      LottieBuilder.asset(
                                        // fit: BoxFit.fitWidth,
                                        ImageAssets.paymentFailure,
                                        repeat: false,
                                      ),
                                    ],
                                  ),
                                ),
                          Text(
                            // lang == 'ar'
                            //     ? str.su_title
                            //     : 'Your payment was successfully processed\nDetail of transaction are included',
                            str.pay_fail,
                            textAlign: TextAlign.center,
                            style: getRegularStyle(
                                color: ColorManager.errorRed, fontSize: 16),
                          ),
                          // Text(
                          //   str.su_title_1,
                          //   textAlign: TextAlign.center,
                          //   style: getRegularStyle(
                          //       color: ColorManager.paymentPageColor1,
                          //       fontSize: 16),
                          // ),
                          const SizedBox(
                            height: 30,
                          ),
                          // PaymentListTile(
                          //     text1: str.su_date, text2: '25/08/2022'),
                          // PaymentListTile(
                          //     text1: str.su_service_fee,
                          //     text2: "\$135.00 OMR"),
                          // PaymentListTile(
                          //     text1: str.su_discount,
                          //     text2: '\$7.00 OMR = 5%'),
                          // PaymentListTile(
                          //   text1: str.su_vat,
                          //   text2: '\$12.00 OMR = 8%',
                          // ),
                          // PaymentListTile(
                          //   text1: str.su_mobile,
                          //   text2: '+968 9526 123456',
                          // ),
                          // PaymentListTile(
                          //   text1: str.su_exp,
                          //   text2: '25/09/2022',
                          // ),
                          // const SizedBox(
                          //   height: 30,
                          // ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(context,
                                  MaterialPageRoute(builder: (ctx) {
                                return const HomePage(
                                  selectedIndex: 0,
                                );
                              }));
                            },
                            style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.fromLTRB(13, 0, 13, 0)),
                            child: Text(
                              "BACK TO HOME",
                              style: getMediumtStyle(
                                  color: ColorManager.whiteText, fontSize: 14),
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  generatePdf() {
    setState(() {
      isLoading = true;
    });
    screenshotController
        .capture(delay: const Duration(milliseconds: 10))
        .then((capturedImage) async {
      final pdfFile = await PdfApi.generateCenteredText(
        capturedImage,
      );
      await PdfApi.openFile(pdfFile);
      setState(() {
        isLoading = false;
      });
    }).catchError((onError) {
      print(onError);
    });
  }
}
