import 'dart:async';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:social_media_services/API/get_region_info.dart';
import 'package:social_media_services/API/home/get_service_man.dart';
import 'package:social_media_services/animations/animtions.dart';
import 'package:social_media_services/components/assets_manager.dart';
import 'package:social_media_services/components/color_manager.dart';
import 'package:social_media_services/components/routes_manager.dart';
import 'package:social_media_services/components/styles_manager.dart';
import 'package:social_media_services/controllers/controllers.dart';
import 'package:social_media_services/model/get_countries.dart';
import 'package:social_media_services/providers/data_provider.dart';
import 'package:social_media_services/providers/servicer_provider.dart';
import 'package:social_media_services/responsive/responsive.dart';
import 'package:social_media_services/responsive/responsive_width.dart';
import 'package:social_media_services/screens/Google%20Map/searchServicerLocation.dart';
import 'package:social_media_services/screens/home_page.dart';
import 'package:social_media_services/screens/messagePage.dart';
import 'package:social_media_services/screens/serviceHome.dart';
import 'package:social_media_services/loading%20screens/profile_loading.dart';
import 'package:social_media_services/utils/animatedSnackBar.dart';
import 'package:social_media_services/widgets/custom_drawer.dart';
import 'package:social_media_services/widgets/servicer_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:social_media_services/widgets/servicer_list_tile.dart';
import 'package:social_media_services/widgets/title_widget.dart';

class ServicerPage extends StatefulWidget {
  int? id;
  bool? isAdvancedSearchEnabled;
  ServicerPage({super.key, this.id, this.isAdvancedSearchEnabled = false});

  @override
  State<ServicerPage> createState() => _ServicerPageState();
}

class _ServicerPageState extends State<ServicerPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? selectedValue;
  final int _selectedIndex = 2;
  final List<Widget> _screens = [const ServiceHomePage(), const MessagePage()];
  String lang = '';

  bool isPickerSelected = false;
  bool isSerDrawerOpened = false;
  bool isAdvancedSearchEnabled = false;

  List<Countries> r2 = [];
  Timer? _debounce;
  List<String> r3 = [];
  int? countryid;
  int? countryid2;
  List<Countries> r = [];
  String? defRegion;

  @override
  void initState() {
    super.initState();
    lang = Hive.box('LocalLan').get(
      'lang',
    );
    isAdvancedSearchEnabled = widget.isAdvancedSearchEnabled ?? false;
    countryid = 165;
    selectedValue = "Oman";

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final str = AppLocalizations.of(context)!;
      final provider = Provider.of<DataProvider>(context, listen: false);
      final servicerProvider =
          Provider.of<ServicerProvider>(context, listen: false);
      int? n = provider.countriesModel?.countries?.length;
      int i = 0;
      while (i < n!.toInt()) {
        r3.add(provider.countriesModel!.countries![i].countryName!);
        i++;
      }
      ServiceControllers.mapController.text = servicerProvider
                  .servicerLatitude !=
              null
          ? "${servicerProvider.servicerLatitude} ${servicerProvider.servicerLongitude}"
          : str.s_map;
      provider.servicerSelectedCountry = '';
      provider.clearRegions();
      await getRegionData(context, 165);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = MediaQuery.of(context).size.width;
    final mob = Responsive.isMobile(context);
    final mobWth = ResponsiveWidth.isMobile(context);
    final smobWth = ResponsiveWidth.issMobile(context);
    final str = AppLocalizations.of(context)!;
    final provider = Provider.of<DataProvider>(context, listen: false);
    final servicerProvider =
        Provider.of<ServicerProvider>(context, listen: false);
    final serviceManData = provider.serviceManListModel?.serviceman;

    return GestureDetector(
      onTap: () {
        setState(() {
          isPickerSelected = false;
        });
      },
      child: Scaffold(
        onEndDrawerChanged: (isOpened) async {
          setState(() {});
          await Future.delayed(const Duration(seconds: 2));
          setState(() {});
        },

        drawerEnableOpenDragGesture: false,
        endDrawer: SizedBox(
          height: isSerDrawerOpened ? size.height * 0.425 : size.height * 0.825,
          width: isSerDrawerOpened
              ? size.width * 0.54
              : mobWth
                  ? size.width * 0.6
                  : smobWth
                      ? w * .7
                      : w * .75,
          child: isSerDrawerOpened
              ? SerDrawer(
                  id: widget.id,
                )
              : const CustomDrawer(),
        ),
        // * Custom bottom Nav
        bottomNavigationBar: GestureDetector(
          onTap: () {
            Navigator.pushNamedAndRemoveUntil(
                context, Routes.homePage, (route) => false);
          },
          child: Stack(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
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
                          // Navigator.pushReplacement(context,
                          //     MaterialPageRoute(builder: (ctx) {
                          //   return const HomePage(
                          //     selectedIndex: 0,
                          //   );
                          // }));
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
                  onTabChange: (index) {
                    // setState(() {
                    //   _selectedIndex = index;
                    // });
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
                        setState(() {
                          isSerDrawerOpened = false;
                        });
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
        ),
        body: _selectedIndex != 2
            ? _screens[_selectedIndex]
            : SafeArea(
                child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                  height: 48,
                                  width: size.width * .8,
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 10.0,
                                            color: Colors.grey.shade300,
                                            // offset: const Offset(5, 8.5),
                                          ),
                                        ],
                                      ),
                                      child: TextField(
                                        // focusNode: nfocus,
                                        style: const TextStyle(),
                                        controller: ServiceControllers
                                            .servicerController,
                                        onChanged: (value) async {
                                          value.isEmpty
                                              ? await searchServicer()
                                              : null;
                                          await Future.delayed(
                                              const Duration(seconds: 2));
                                          setState(() {});
                                        },
                                        decoration: InputDecoration(
                                            suffixIcon: SizedBox(
                                              width: 50,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Center(
                                                    child: Container(
                                                      width: .5,
                                                      height: 48,
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              206,
                                                              205,
                                                              205),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(5, 0, 5, 0),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        await searchServicer();
                                                        await Future.delayed(
                                                            const Duration(
                                                                seconds: 1));
                                                        setState(() {});
                                                      },
                                                      child: Text(
                                                        textAlign:
                                                            TextAlign.center,
                                                        String.fromCharCode(
                                                            Icons.search
                                                                .codePoint),
                                                        style: TextStyle(
                                                          inherit: false,
                                                          color: ColorManager
                                                              .primary,
                                                          fontSize: 20.0,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontFamily: Icons
                                                              .search
                                                              .fontFamily,
                                                          package: Icons.search
                                                              .fontPackage,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            hintText: str.s_servicer,
                                            hintStyle: getRegularStyle(
                                                color: const Color.fromARGB(
                                                    255, 173, 173, 173),
                                                fontSize:
                                                    Responsive.isMobile(context)
                                                        ? 15
                                                        : 10)),
                                      ),
                                    ),
                                  )),

                              // * Filter icon
                              SizedBox(
                                width: Responsive.isMobile(context) ? 10 : 5,
                              ),
                              Builder(
                                builder: (context) => InkWell(
                                  onTap: () {
                                    setState(() {
                                      isSerDrawerOpened = true;
                                    });

                                    Scaffold.of(context).openEndDrawer();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: ColorManager.whiteColor,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 10.0,
                                          color: Colors.grey.shade300,
                                          // offset: const Offset(5, 8.5),
                                        ),
                                      ],
                                    ),
                                    width: size.width * .09,
                                    height: 38,
                                    child: const Icon(
                                      Icons.filter_alt,
                                      size: 25,
                                      color: ColorManager.primary,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          // * Country & Region
                          isAdvancedSearchEnabled
                              ? FadeCustomAnimation(
                                  delay: .001,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 10, 0, 0),
                                                child: TitleWidget(
                                                    name: str.s_country),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 10, 0, 0),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 10.0,
                                                        color: Colors
                                                            .grey.shade300,
                                                        // offset: const Offset(5, 8.5),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Container(
                                                    width: size.width * .44,
                                                    height: 50,
                                                    decoration: BoxDecoration(
                                                        color: ColorManager
                                                            .whiteColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          0, 10, 0, 10),
                                                      child:
                                                          DropdownButtonHideUnderline(
                                                        child: DropdownButton2(
                                                            isExpanded: true,
                                                            // focusNode: nfocus,
                                                            icon: const Icon(
                                                              Icons
                                                                  .keyboard_arrow_down,
                                                              size: 35,
                                                              color:
                                                                  ColorManager
                                                                      .black,
                                                            ),
                                                            hint: Text(str.ae_country_h,
                                                                style: getRegularStyle(
                                                                    color: const Color.fromARGB(
                                                                        255,
                                                                        173,
                                                                        173,
                                                                        173),
                                                                    fontSize:
                                                                        15)),
                                                            items: r3
                                                                .map(
                                                                    (item) => DropdownMenuItem<
                                                                            String>(
                                                                          value:
                                                                              item,
                                                                          child: Text(
                                                                              item,
                                                                              style: getRegularStyle(color: ColorManager.black, fontSize: 15)),
                                                                        ))
                                                                .toList(),
                                                            value:
                                                                selectedValue,
                                                            onChanged:
                                                                (value) async {
                                                              setState(() {
                                                                selectedValue =
                                                                    value
                                                                        as String;
                                                              });
                                                              await s(
                                                                  selectedValue);
                                                              defRegion = null;
                                                              await getRegionData(
                                                                  context,
                                                                  countryid);
                                                              setState(() {});
                                                            },
                                                            buttonHeight: 40,
                                                            dropdownMaxHeight:
                                                                size.height *
                                                                    .6,
                                                            // buttonWidth: 140,
                                                            itemHeight: 40,
                                                            buttonPadding:
                                                                const EdgeInsets.fromLTRB(
                                                                    12, 0, 8, 0),
                                                            // dropdownWidth: size.width,
                                                            itemPadding:
                                                                const EdgeInsets.fromLTRB(
                                                                    12, 0, 12, 0),
                                                            searchController:
                                                                AddressEditControllers
                                                                    .searchController,
                                                            searchInnerWidget:
                                                                Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                top: 8,
                                                                bottom: 4,
                                                                right: 8,
                                                                left: 8,
                                                              ),
                                                              child:
                                                                  TextFormField(
                                                                controller:
                                                                    AddressEditControllers
                                                                        .searchController,
                                                                decoration:
                                                                    InputDecoration(
                                                                  isDense: true,
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        10,
                                                                    vertical: 8,
                                                                  ),
                                                                  hintText: str
                                                                      .s_search_country,
                                                                  hintStyle:
                                                                      const TextStyle(
                                                                          fontSize:
                                                                              12),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  suffixIcon:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        selectedValue =
                                                                            null;
                                                                        countryid =
                                                                            null;
                                                                      });
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: const Icon(
                                                                        size:
                                                                            25,
                                                                        Icons
                                                                            .close),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            searchMatchFn: (item, searchValue) {
                                                              return (item.value
                                                                  .toString()
                                                                  .toLowerCase()
                                                                  .contains(
                                                                      searchValue));
                                                            },
                                                            //This to clear the search value when you close the menu
                                                            onMenuStateChange: (isOpen) {
                                                              if (!isOpen) {
                                                                AddressEditControllers
                                                                    .searchController
                                                                    .clear();
                                                              }
                                                            }),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 10, 0, 0),
                                                child: TitleWidget(
                                                    name: str.s_region),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 10, 0, 0),
                                                child: Container(
                                                  width: size.width * .44,
                                                  height: mob ? 50 : 35,
                                                  decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          blurRadius: 10.0,
                                                          color: Colors
                                                              .grey.shade300,
                                                          // offset: const Offset(5, 8.5),
                                                        ),
                                                      ],
                                                      color: ColorManager
                                                          .whiteColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8)),
                                                  child:
                                                      //  TextField(
                                                      //   controller:
                                                      //       ServiceControllers
                                                      //           .regionController,
                                                      //   decoration: InputDecoration(
                                                      //       hintText: str.s_region,
                                                      //       hintStyle: getRegularStyle(
                                                      //           color: const Color
                                                      //                   .fromARGB(
                                                      //               255,
                                                      //               173,
                                                      //               173,
                                                      //               173),
                                                      //           fontSize: Responsive
                                                      //                   .isMobile(
                                                      //                       context)
                                                      //               ? 15
                                                      //               : 10)),
                                                      // ),
                                                      DropdownButtonHideUnderline(
                                                    child: DropdownButton2(
                                                      isExpanded: true,
                                                      // focusNode: nfocus,
                                                      icon: const Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        size: 35,
                                                        color:
                                                            ColorManager.black,
                                                      ),
                                                      hint: Text(str.p_region_h,
                                                          style: getRegularStyle(
                                                              color: const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  173,
                                                                  173,
                                                                  173),
                                                              fontSize: 15)),
                                                      items: provider
                                                          .regionInfoModel
                                                          ?.regions!
                                                          .map((item) =>
                                                              DropdownMenuItem<
                                                                  String>(
                                                                value: item
                                                                    .cityName,
                                                                child: Text(
                                                                    item.cityName ??
                                                                        '',
                                                                    style: getRegularStyle(
                                                                        color: ColorManager
                                                                            .black,
                                                                        fontSize:
                                                                            15)),
                                                              ))
                                                          .toList(),
                                                      // value: defRegion,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          defRegion =
                                                              value as String;
                                                        });
                                                        ProfileServiceControllers
                                                                .regionController
                                                                .text =
                                                            defRegion ?? '';
                                                        // s(selectedValue);
                                                      },
                                                      buttonHeight: 50,
                                                      dropdownMaxHeight:
                                                          size.height * .6,
                                                      // buttonWidth: 140,
                                                      itemHeight: 40,
                                                      buttonPadding:
                                                          const EdgeInsets
                                                                  .fromLTRB(
                                                              12, 0, 8, 0),
                                                      // dropdownWidth: size.width,
                                                      itemPadding:
                                                          const EdgeInsets
                                                                  .fromLTRB(
                                                              12, 0, 12, 0),
                                                      // searchController:
                                                      //     AddressEditControllers
                                                      //         .searchController,
                                                      // searchInnerWidget: Padding(
                                                      //   padding:
                                                      //       const EdgeInsets.only(
                                                      //     top: 8,
                                                      //     bottom: 4,
                                                      //     right: 8,
                                                      //     left: 8,
                                                      //   ),
                                                      //   child: TextFormField(
                                                      //     controller:
                                                      //         AddressEditControllers
                                                      //             .searchController,
                                                      //     decoration: InputDecoration(
                                                      //       isDense: true,
                                                      //       contentPadding:
                                                      //           const EdgeInsets
                                                      //               .symmetric(
                                                      //         horizontal: 10,
                                                      //         vertical: 8,
                                                      //       ),
                                                      //       // TODO: localisation
                                                      //       hintText:
                                                      //           str.s_search_country,
                                                      //       hintStyle:
                                                      //           const TextStyle(
                                                      //               fontSize: 12),
                                                      //       border:
                                                      //           OutlineInputBorder(
                                                      //         borderRadius:
                                                      //             BorderRadius
                                                      //                 .circular(8),
                                                      //       ),
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                      // searchMatchFn:
                                                      //     (item, searchValue) {
                                                      //   return (item.value
                                                      //       .toString()
                                                      //       .toLowerCase()
                                                      //       .contains(searchValue));
                                                      // },
                                                      customButton:
                                                          defRegion == null
                                                              ? null
                                                              : Row(
                                                                  children: [
                                                                    Center(
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets.fromLTRB(
                                                                            10,
                                                                            15,
                                                                            10,
                                                                            15),
                                                                        child: Text(defRegion ??
                                                                            ''),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                      //This to clear the search value when you close the menu
                                                      // onMenuStateChange: (isOpen) {
                                                      //   if (!isOpen) {
                                                      //     AddressEditControllers
                                                      //         .searchController
                                                      //         .clear();
                                                      //   }
                                                      // }
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      // * Google map
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 10, 0, 0),
                                                child: TitleWidget(
                                                    name: str.s_map),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        0, 10, 0, 0),
                                                child: Container(
                                                  width: size.width * .44,
                                                  height: mob ? 50 : 35,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                        blurRadius: 10.0,
                                                        color: Colors
                                                            .grey.shade300,
                                                        // offset: const Offset(5, 8.5),
                                                      ),
                                                    ],
                                                  ),
                                                  child: TextField(
                                                    readOnly: true,
                                                    style: const TextStyle(
                                                        fontSize: 12),
                                                    controller:
                                                        ServiceControllers
                                                            .mapController,
                                                    decoration: InputDecoration(
                                                        suffixIcon: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 5),
                                                          child: SizedBox(
                                                            width: size.width *
                                                                .15,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                InkWell(
                                                                  onTap: () {
                                                                    final servicerProvider = Provider.of<
                                                                            ServicerProvider>(
                                                                        context,
                                                                        listen:
                                                                            false);
                                                                    ServiceControllers
                                                                        .mapController
                                                                        .clear();
                                                                    servicerProvider
                                                                            .servicerLatitude =
                                                                        null;
                                                                  },
                                                                  child: const Icon(
                                                                      size: 25,
                                                                      Icons
                                                                          .close),
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(builder:
                                                                            (ctx) {
                                                                      return const SearchServicerLocation();
                                                                    }));
                                                                  },
                                                                  child:
                                                                      Container(
                                                                          width: mob
                                                                              ? 30
                                                                              : 20,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(5),
                                                                            color:
                                                                                ColorManager.primary,
                                                                          ),
                                                                          height: mob
                                                                              ? 30
                                                                              : 25,
                                                                          child:
                                                                              Icon(
                                                                            Icons.add_location_alt_outlined,
                                                                            color:
                                                                                ColorManager.whiteColor,
                                                                            size: mob
                                                                                ? 20
                                                                                : 15,
                                                                          )),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        hintText: 'Map',
                                                        hintStyle: getRegularStyle(
                                                            color: const Color
                                                                    .fromARGB(
                                                                255,
                                                                173,
                                                                173,
                                                                173),
                                                            fontSize: Responsive
                                                                    .isMobile(
                                                                        context)
                                                                ? 15
                                                                : 10)),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 10, 0, 0),
                                                  child: TitleWidget(
                                                      name: str.s_state),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          0, 10, 0, 0),
                                                  child: Container(
                                                    width: size.width * .44,
                                                    height: mob ? 50 : 35,
                                                    decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                          blurRadius: 10.0,
                                                          color: Colors
                                                              .grey.shade300,
                                                          // offset: const Offset(5, 8.5),
                                                        ),
                                                      ],
                                                    ),
                                                    child: TextField(
                                                      // style: const TextStyle(),
                                                      controller:
                                                          ServiceControllers
                                                              .stateController,
                                                      decoration: InputDecoration(
                                                          hintText: str.s_state,
                                                          hintStyle: getRegularStyle(
                                                              color: const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  173,
                                                                  173,
                                                                  173),
                                                              fontSize: Responsive
                                                                      .isMobile(
                                                                          context)
                                                                  ? 15
                                                                  : 10)),
                                                    ),
                                                  ),
                                                ),
                                              ])
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      SizedBox(
                                        width: size.width,
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              await searchServiceMan(
                                                  context,
                                                  widget.id.toString(),
                                                  countryid,
                                                  ServiceControllers
                                                      .stateController.text,
                                                  ServiceControllers
                                                      .regionController.text,
                                                  ServiceControllers
                                                      .servicerController.text,
                                                  provider.isFourWheelerSelected &&
                                                          provider
                                                              .isTwoWheelerSelected
                                                      ? ''
                                                      : provider
                                                              .isFourWheelerSelected
                                                          ? 'four wheeler'
                                                          : provider
                                                                  .isTwoWheelerSelected
                                                              ? 'two wheeler'
                                                              : '');
                                              setState(() {});
                                            },
                                            child: Text(
                                              str.s_search,
                                              style: getSemiBoldtStyle(
                                                  color:
                                                      ColorManager.whiteColor,
                                                  fontSize: 15),
                                            )),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      InkWell(
                                        onTap: () {
                                          setState(() {
                                            isAdvancedSearchEnabled = false;
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: ColorManager.whiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          width: size.width,
                                          height: 30,
                                          child: const Icon(
                                              Icons.keyboard_arrow_up),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : InkWell(
                                  onTap: () {
                                    setState(() {
                                      isAdvancedSearchEnabled = true;
                                    });
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: ColorManager.whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(6)),
                                      width: size.width,
                                      height: 30,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            str.s_advanced_search,
                                            style: getRegularStyle(
                                                color: ColorManager.black,
                                                fontSize: 12),
                                          ),
                                          const Icon(Icons.keyboard_arrow_down),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: ((context, index) {
                              return Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                child: InkWell(
                                    onTap: () {
                                      servicerProvider.navServiceId =
                                          serviceManData![index].id;
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (ctx) {
                                        return ProfileLoading(
                                          serviceman: serviceManData[index],
                                          key: _scaffoldKey,
                                        );
                                      }));
                                    },
                                    child: ServicerListTile(
                                      serviceman: serviceManData![index],
                                    )),
                              );
                            }),
                            itemCount: serviceManData?.length ?? 0,
                          ),

                          const SizedBox(
                            height: 5,
                          )
                        ],
                      ),
                    ),
                  ),
                  isPickerSelected
                      ? Positioned(
                          top: mob ? size.height * .19 : 140,
                          // top: size.height * .458,
                          right: lang == 'ar' ? size.width * .05 : null,
                          left: lang != 'ar' ? size.width * .05 : null,
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
                                height: 110,
                                width: 160,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ListView.builder(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 0, 0),
                                          itemCount: r2.length,
                                          itemBuilder: (ctx, index) {
                                            return InkWell(
                                              onTap: () {
                                                setState(() {
                                                  // countryid =
                                                  //     r1[index].countryId;
                                                  // r1 = (provider
                                                  //     .countriesModel!
                                                  //     .countries)!;
                                                  isPickerSelected = false;
                                                });
                                              },
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    // countryid =
                                                    //     r1[index].countryId;
                                                    EditProfileControllers
                                                            .countryController
                                                            .text =
                                                        r2[index].countryName ??
                                                            '';
                                                    isPickerSelected = false;
                                                  });
                                                },
                                                child: Container(
                                                  height: 25,
                                                  color: ColorManager.primary2,
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 0, 5, 0),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                            r2[index]
                                                                    .countryName ??
                                                                '',
                                                            style: getSemiBoldtStyle(
                                                                color: ColorManager.background,
                                                                fontSize: r2[index].countryName!.length < 12
                                                                    ? 12
                                                                    : r2[index].countryName!.length < 20
                                                                        ? 10
                                                                        : r2[index].countryName!.length > 25
                                                                            ? 8
                                                                            : 10)),
                                                      ],
                                                    ),
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
                        )
                      : Container()
                ],
              )),
      ),
    );
  }

  onSearchChanged(String query) {
    setState(() {
      r2 = [];
    });
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(microseconds: 200), () {
      s(query);
    });
  }

  s(filter) {
    setState(() {
      r = [];
    });

    final provider = Provider.of<DataProvider>(context, listen: false);
    provider.countriesModel?.countries?.forEach((element) {
      final m = element.countryName?.contains(filter);

      if (m == true) {
        if (selectedValue != element.countryName) {
          return;
        }
        setState(() {
          r.add(element);
        });
        countryid = r[0].countryId;
        provider.selectedCountryId = r[0].countryId;
        provider.servicerSelectedCountry = r[0].countryId.toString();
      }
    });
  }

  searchServicer() {
    final provider = Provider.of<DataProvider>(context, listen: false);
    print(ServiceControllers.stateController.text);
    if (ServiceControllers.servicerController.text.isEmpty) {
      showAnimatedSnackBar(context, "Enter a Servicer name to search");
    } else {
      searchServiceMan(
          context,
          widget.id.toString(),
          countryid2,
          ServiceControllers.stateController.text,
          ServiceControllers.regionController.text,
          ServiceControllers.servicerController.text,
          provider.isFourWheelerSelected && provider.isTwoWheelerSelected
              ? ''
              : provider.isFourWheelerSelected
                  ? 'four wheeler'
                  : provider.isTwoWheelerSelected
                      ? 'two wheeler'
                      : '');
    }
  }
}
