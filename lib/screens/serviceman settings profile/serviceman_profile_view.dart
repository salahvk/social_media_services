import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:social_media_services/API/endpoint.dart';
import 'package:social_media_services/API/get_serviceManProfileDetails.dart';
import 'package:social_media_services/animations/animtions.dart';
import 'package:social_media_services/components/assets_manager.dart';
import 'package:social_media_services/components/color_manager.dart';
import 'package:social_media_services/components/styles_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:social_media_services/model/serviceManLIst.dart';
import 'package:social_media_services/providers/data_provider.dart';
import 'package:social_media_services/responsive/responsive.dart';
import 'package:social_media_services/responsive/responsive_width.dart';
import 'package:social_media_services/screens/home_page.dart';
import 'package:social_media_services/screens/serviceman%20settings%20profile/serviceman_profile_edit.dart';
import 'package:social_media_services/utils/animatedSnackBar.dart';
import 'package:social_media_services/utils/delete_image.dart';
import 'package:social_media_services/widgets/custom_drawer.dart';
import 'package:social_media_services/widgets/popup_image.dart';
import 'package:social_media_services/widgets/profile_image.dart';

class ServiceManProfileViewPage extends StatefulWidget {
  Serviceman? serviceman;
  ServiceManProfileViewPage({super.key, this.serviceman});

  @override
  State<ServiceManProfileViewPage> createState() =>
      _ServiceManProfileViewPageState();
}

class _ServiceManProfileViewPageState extends State<ServiceManProfileViewPage> {
  final int _selectedIndex = 2;
  String lang = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      getServiceManProfileFun(context);
    });
    lang = Hive.box('LocalLan').get(
      'lang',
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context, listen: true);
    final mob = Responsive.isMobile(context);
    final userData = provider.serviceManProfile?.userData;
    final size = MediaQuery.of(context).size;
    final str = AppLocalizations.of(context)!;
    final w = MediaQuery.of(context).size.width;
    final mobWth = ResponsiveWidth.isMobile(context);
    final smobWth = ResponsiveWidth.issMobile(context);
    String? transport;
    if (userData != null && userData.transport != null) {
      transport = userData.transport!.contains('four') ? str.s_four : str.s_two;
    }

    return Scaffold(
      drawerEnableOpenDragGesture: false,
      endDrawer: SizedBox(
        height: size.height * 0.825,
        width: mobWth
            ? w * 0.6
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
                      Navigator.pushReplacement(
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
                      Navigator.pushReplacement(
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
              onTabChange: (index) {},
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeCustomAnimation(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: ColorManager.background,
                        child: ProfileImage(
                          isNavigationActive: false,
                          iconSize: 0,
                          profileSize: 60,
                          iconRadius: 0,
                        ),
                      ),
                      Positioned(
                        height: 40,
                        // left: size.width * .0,
                        child: CircleAvatar(
                          radius: mob ? 8 : 6,
                          backgroundColor: userData?.onlineStatus == 'online'
                              ? ColorManager.primary
                              : userData?.onlineStatus == 'offline'
                                  ? ColorManager.grayLight
                                  : ColorManager.errorRed,
                        ),
                      )
                    ],
                  ),
                ),
                FadeSlideCustomAnimation(
                  delay: .1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 4),
                    child: Text(
                      '${userData?.firstname ?? ''} ${userData?.lastname ?? ''}',
                      style: getRegularStyle(
                          color: ColorManager.black, fontSize: 16),
                    ),
                  ),
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Image.asset(ImageAssets.tools),
                //     const SizedBox(
                //       width: 5,
                //     ),
                //     Text(widget.serviceman?.about ?? '',
                //         style: getRegularStyle(
                //             color: ColorManager.engineWorkerColor,
                //             fontSize: 15)),
                //   ],
                // ),
                // const SizedBox(
                //   height: 5,
                // ),
                FadeSlideCustomAnimation(
                  delay: .15,
                  child: Text(
                      '${userData?.countryName ?? ''} | ${userData?.state ?? ''}',
                      style: getRegularStyle(
                          color: ColorManager.engineWorkerColor, fontSize: 15)),
                ),
                FadeSlideCustomAnimation(
                  delay: .2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 40,
                        height: 30,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 9.5,
                              color: Colors.grey.shade400,
                              offset: const Offset(6, 6),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(5),
                          color: ColorManager.primary,
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          color: ColorManager.whiteColor,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                FadeSlideCustomAnimation(
                  delay: .25,
                  isRight: true,
                  child: SizedBox(
                    height: 80,
                    child: ListView.builder(
                      itemCount: provider
                              .serviceManProfile!.galleryImages!.isEmpty
                          ? 4
                          : provider.serviceManProfile?.galleryImages?.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        final galleryImages =
                            provider.serviceManProfile?.galleryImages;
                        return InkWell(
                          onTap: () {
                            galleryImages!.isEmpty
                                ? showAnimatedSnackBar(
                                    context, str.sv_no_images)
                                : showDialog(
                                    context: context,
                                    builder: (context) => PopupImage(
                                        image:
                                            galleryImages[index].galleryImage),
                                    barrierDismissible: true);
                          },
                          onLongPress: () {
                            final imageId = galleryImages?[index].id;
                            galleryImages!.isEmpty
                                ? showAnimatedSnackBar(
                                    context, str.sv_no_images)
                                : showDialog(
                                    context: context,
                                    builder: (context) => DeleteImage(
                                        imageId: imageId.toString()),
                                    barrierDismissible: false);
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: ColorManager.grayLight,
                                ),
                                height: 80,
                                width: size.width * .3,
                                child: galleryImages!.isEmpty
                                    ? Image.asset(
                                        'assets/no_image.png',
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        errorWidget: (context, url, error) {
                                          return Container(
                                            height: 80,
                                            width: size.width * .3,
                                            color: ColorManager.grayLight,
                                          );
                                        },
                                        imageUrl:
                                            "$endPoint${galleryImages[index].galleryImage ?? ''}",
                                        fit: BoxFit.cover,
                                        // cacheManager: customCacheManager,
                                      ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                FadeSlideCustomAnimation(
                  delay: .3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                    child: Row(
                      children: [
                        Text(
                          '${str.wd_desc}:',
                          style: getRegularStyle(
                              color: ColorManager.black, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                userData?.about != null
                    ? FadeSlideCustomAnimation(
                        delay: .35,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                userData?.about ?? '',
                                style: getRegularStyle(
                                    color: ColorManager.engineWorkerColor,
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                FadeSlideCustomAnimation(
                  delay: .4,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        0, userData?.about != null ? 15 : 0, 0, 10),
                    child: Row(
                      children: [
                        Text(
                          '${str.wd_ser}:',
                          style: getRegularStyle(
                              color: ColorManager.black, fontSize: 16),
                        ),
                        const SizedBox(
                          width: 7,
                        ),
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: Image.asset(
                            ImageAssets.tools,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(userData?.serviceName ?? '',
                            style: getRegularStyle(
                                color: ColorManager.engineWorkerColor,
                                fontSize: 15)),
                      ],
                    ),
                  ),
                ),
                FadeSlideCustomAnimation(
                  delay: .45,
                  child: Row(
                    children: [
                      Text(
                        '${str.wd_tran}:',
                        style: getRegularStyle(
                            color: ColorManager.black, fontSize: 16),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      userData?.transport == 'two wheeler'
                          ? Image.asset(ImageAssets.scooter)
                          : Image.asset(ImageAssets.car),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(transport ?? '',
                          style: getRegularStyle(
                              color: ColorManager.engineWorkerColor,
                              fontSize: 15)),
                    ],
                  ),
                ),
                FadeSlideCustomAnimation(
                  delay: .5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 0, 8),
                    child: Row(
                      children: [
                        Text(
                          '${str.wd_more}:',
                          style: getRegularStyle(
                              color: ColorManager.black, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
                FadeSlideCustomAnimation(
                  delay: .55,
                  child: Row(
                    children: [
                      // userData?.profile == null
                      //     ? Container()
                      //     :
                      Expanded(
                        child: Text(
                          userData?.profile ?? '',
                          style: getRegularStyle(
                              color: ColorManager.engineWorkerColor,
                              fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                FadeSlideCustomAnimation(
                  delay: .6,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: navigateToServiceEditManProfile,
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.fromLTRB(33, 0, 33, 0)),
                          child: Text(
                            str.sv_edit_profile,
                            style: getMediumtStyle(
                                color: ColorManager.whiteText, fontSize: 14),
                          )),
                      const SizedBox(
                        width: 15,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  navigateToServiceEditManProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
      return const ServiceManProfileEditPage();
    }));
  }
}
