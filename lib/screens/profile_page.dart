import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:social_media_services/API/get_active_services.dart';
import 'package:social_media_services/API/get_active_subscription.dart';
import 'package:social_media_services/responsive/responsive_width.dart';
import 'package:social_media_services/screens/my_services.dart';
import 'package:social_media_services/screens/my_subscription.dart';
import 'package:social_media_services/animations/animtions.dart';
import 'package:social_media_services/components/routes_manager.dart';
import 'package:social_media_services/components/assets_manager.dart';
import 'package:social_media_services/components/color_manager.dart';
import 'package:social_media_services/components/styles_manager.dart';
import 'package:social_media_services/providers/data_provider.dart';
import 'package:social_media_services/screens/edit_profile_screen.dart';
import 'package:social_media_services/screens/home_page.dart';
import 'package:social_media_services/screens/messagePage.dart';
import 'package:social_media_services/screens/serviceHome.dart';
import 'package:social_media_services/screens/serviceman%20settings%20profile/serviceman_profile_view.dart';
import 'package:social_media_services/widgets/custom_drawer.dart';
import 'package:social_media_services/widgets/profile_image.dart';
import 'package:social_media_services/widgets/profile_tile_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final int _selectedIndex = 2;
  final List<Widget> _screens = [
    const ServiceHomePage(),
    const MessagePage(
      isHome: true,
    )
  ];
  String lang = '';
  @override
  void initState() {
    super.initState();
    lang = Hive.box('LocalLan').get(
      'lang',
    );
    log(lang);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getActiveServices(context);
      getActiveSubscriptionData(context);
    });
  }

  Future<bool> _willPopCallback() async {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      return const HomePage(
        selectedIndex: 0,
      );
    }));
    return true; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<DataProvider>(context, listen: true);
    final str = AppLocalizations.of(context)!;
    final w = MediaQuery.of(context).size.width;
    final mobWth = ResponsiveWidth.isMobile(context);
    final smobWth = ResponsiveWidth.issMobile(context);
    final firstName = toBeginningOfSentenceCase(
        provider.viewProfileModel?.userdetails?.firstname);
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
                  leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: const HomePage(
                              selectedIndex: 0,
                            ),
                          ));
                    },
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.asset(ImageAssets.homeIconSvg),
                    ),
                  ),
                ),
                GButton(
                  icon: FontAwesomeIcons.message,
                  leading: InkWell(
                    onTap: () {
                      Navigator.pop(context);

                      Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.fade,
                            child: const HomePage(
                              selectedIndex: 1,
                            ),
                          ));
                    },
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: SvgPicture.asset(ImageAssets.chatIconSvg),
                    ),
                  ),
                ),
              ],
              haptic: true,
              selectedIndex: _selectedIndex,
              // onTabChange: (index) {
              //   Navigator.pushNamedAndRemoveUntil(
              //       context, Routes.homePage, (route) => false);
              //   // setState(() {
              //   //   _selectedIndex = index;
              //   // });
              // },
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
      body: WillPopScope(
        onWillPop: () async {
          return _willPopCallback();
        },
        child: SafeArea(
            child: Column(
          children: [
            SizedBox(
                height: size.height * 0.36,
                child: FadeCustomAnimation(
                  delay: .1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Center(
                      //     child: ProfileImage(
                      //   isNavigationActive: false,
                      //   iconSize: 18,
                      //   profileSize: 60,
                      //   iconRadius: 17,
                      // )),
                      Center(
                          child: ProfileImage3(
                        isNavigationActive: false,
                        iconSize: 18,
                        profileSize: 60,
                        iconRadius: 17,
                      )),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 5),
                        child: Text(
                            '${firstName ?? ''} ${provider.viewProfileModel?.userdetails?.lastname ?? ''}',
                            style: getBoldtStyle(
                                color: ColorManager.black, fontSize: 20)),
                      ),
                      Text(provider.viewProfileModel?.userdetails?.phone ?? '',
                          style: getRegularStyle(
                              color: const Color(0xff6e6e6e), fontSize: 14)),
                    ],
                  ),
                )),
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                  return EditProfileScreen(
                    isregister: false,
                  );
                }));
              },
              child: FadeSlideCustomAnimation(
                delay: .1,
                child: ProfileTitleWidget(
                  name: str.pp_my_profile,
                  icon: Icons.person_outline,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                  return const HomePage(
                    selectedIndex: 1,
                  );
                }));
              },
              child: FadeSlideCustomAnimation(
                delay: .2,
                child: ProfileTitleWidget(
                  name: str.pp_message,
                  icon: FontAwesomeIcons.message,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, Routes.wishList);
              },
              child: FadeSlideCustomAnimation(
                delay: .3,
                child: ProfileTitleWidget(
                  name: str.pp_favourites,
                  icon: Icons.favorite_border,
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pushNamed(context, Routes.addressPage);
              },
              child: FadeSlideCustomAnimation(
                delay: .4,
                child: ProfileTitleWidget(
                  name: str.pp_address,
                  icon: Icons.pin_drop_outlined,
                ),
              ),
            ),
            provider.viewProfileModel?.userdetails?.userType == 'customer'
                ? Container()
                : InkWell(
                    onTap: () {
                      navigateToServiceManProfile();
                    },
                    child: FadeSlideCustomAnimation(
                      delay: .5,
                      child: ProfileTitleWidget(
                        name: str.pp_settings,
                        icon: Icons.settings_outlined,
                      ),
                    ),
                  ),
            provider.viewProfileModel?.userdetails?.userType == 'customer'
                ? Container()
                : InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return const MyServicesPage();
                      }));
                    },
                    child: FadeSlideCustomAnimation(
                      delay: .5,
                      child: ProfileTitleWidget(
                        name: str.pp_my_Services,
                        icon: Icons.pin_drop_outlined,
                        svg: 'assets/Myservice.svg',
                      ),
                    ),
                  ),
            provider.viewProfileModel?.userdetails?.userType == 'customer'
                ? Container()
                : InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                        return const MySubscriptionPage();
                      }));
                    },
                    child: FadeSlideCustomAnimation(
                      delay: .5,
                      child: ProfileTitleWidget(
                        name: str.pp_my_sub,
                        icon: FontAwesomeIcons.bell,
                      ),
                    ),
                  ),
          ],
        )),
      ),
    );
  }

  navigateToServiceManProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      return ServiceManProfileViewPage();
    }));
  }
}
