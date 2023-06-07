import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:social_media_services/API/becomeServiceMan/customerParent.dart';
import 'package:social_media_services/API/endpoint.dart';
import 'package:social_media_services/API/get_region_info.dart';
import 'package:social_media_services/animations/animtions.dart';
import 'package:social_media_services/components/assets_manager.dart';
import 'package:social_media_services/components/color_manager.dart';
import 'package:social_media_services/components/styles_manager.dart';
import 'package:social_media_services/controllers/controllers.dart';
import 'package:social_media_services/model/get_countries.dart';
import 'package:social_media_services/providers/data_provider.dart';
import 'package:social_media_services/responsive/responsive.dart';
import 'package:social_media_services/responsive/responsive_width.dart';
import 'package:social_media_services/screens/Become%20a%20servie%20man/choose_service_page.dart';
import 'package:social_media_services/screens/home_page.dart';
import 'package:social_media_services/screens/messagePage.dart';
import 'package:social_media_services/screens/serviceHome.dart';
import 'package:social_media_services/utils/animatedSnackBar.dart';
import 'package:social_media_services/widgets/customRadioButton.dart';
import 'package:social_media_services/widgets/custom_drawer.dart';
import 'package:social_media_services/widgets/custom_stepper.dart';
import 'package:social_media_services/widgets/custom_text_field.dart';
import 'package:social_media_services/widgets/mandatory_widget.dart';
import 'package:social_media_services/widgets/title_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileServicePage extends StatefulWidget {
  ProfileServicePage({Key? key}) : super(key: key);

  @override
  State<ProfileServicePage> createState() => _ProfileServicePageState();
}

class _ProfileServicePageState extends State<ProfileServicePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? defvalue;
  String? selectedValue;
  String? defaultReg;
  bool isTickSelected = false;
  DateTime selectedDate = DateTime.now();
  bool value = true;
  final int _selectedIndex = 2;
  final List<Widget> _screens = [const ServiceHomePage(), const MessagePage()];
  String lang = '';
  List<Countries> r2 = [];
  FocusNode nfocus = FocusNode();
  List<Countries> r = [];

  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.requestFocus(nfocus);
    lang = Hive.box('LocalLan').get(
      'lang',
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // print(timeStamp);
      final provider = Provider.of<DataProvider>(context, listen: false);
      int? n = provider.countriesModel?.countries?.length;
      int i = 0;

      while (i < n!.toInt()) {
        r2.add(provider.countriesModel!.countries![i]);
        i++;
      }

      fillFields(provider);
      provider.clearRegions();
      await getRegionData(
          context, provider.viewProfileModel?.userdetails?.countryId);

      setState(() {});
      getCustomerParent(context);
    });
  }

  Future<bool> _willPopCallback() async {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) {
      return const HomePage(
        selectedIndex: 0,
      );
    }));
    return true; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    final str = AppLocalizations.of(context)!;
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final mob = Responsive.isMobile(context);
    final provider = Provider.of<DataProvider>(context, listen: false);

    final mobWth = ResponsiveWidth.isMobile(context);
    final smobWth = ResponsiveWidth.issMobile(context);
    return Scaffold(
      key: _scaffoldKey,
      drawerEnableOpenDragGesture: false,
      endDrawer: SizedBox(
        height: h * 0.825,
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
      body: _selectedIndex != 2
          ? _screens[_selectedIndex]
          : WillPopScope(
              onWillPop: () async {
                return _willPopCallback();
              },
              child: SafeArea(
                child: Column(
                  children: [
                    const FadeCustomAnimation(
                        delay: .1, child: CustomStepper(num: 1)),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FadeSlideCustomAnimation(
                                  delay: .1,
                                  child: MandatoryHeader(
                                      heading: str.p_first_name)),
                              FadeSlideCustomAnimation(
                                delay: .15,
                                child: CustomTextField(
                                    hintText: str.p_first_name_h,
                                    controller: ProfileServiceControllers
                                        .firstNameController),
                              ),
                              FadeSlideCustomAnimation(
                                delay: .2,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: TitleWidget(name: str.p_last_name),
                                ),
                              ),
                              FadeSlideCustomAnimation(
                                delay: .25,
                                child: CustomTextField(
                                    hintText: str.p_last_name_h,
                                    controller: ProfileServiceControllers
                                        .lastNameController),
                              ),
                              FadeSlideCustomAnimation(
                                  delay: .3,
                                  child: MandatoryHeader(heading: str.p_civil)),
                              FadeSlideCustomAnimation(
                                delay: .35,
                                child: CustomTextField(
                                    hintText: str.p_civil_h,
                                    controller: ProfileServiceControllers
                                        .civilCardController,
                                    type: TextInputType.number),
                              ),
                              FadeSlideCustomAnimation(
                                delay: .4,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          child: TitleWidget(name: str.p_dob),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          child: Container(
                                            width: mob ? w * 0.5 : w * .45,
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
                                              style: const TextStyle(),
                                              readOnly: true,
                                              controller:
                                                  ProfileServiceControllers
                                                      .dateController,
                                              decoration: InputDecoration(
                                                  suffixIcon: InkWell(
                                                    onTap: () =>
                                                        _selectDate(context),
                                                    child: const Icon(
                                                      Icons.calendar_month,
                                                      color:
                                                          ColorManager.primary,
                                                    ),
                                                  ),
                                                  hintText: str.p_dob_h,
                                                  hintStyle: getRegularStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              173,
                                                              173,
                                                              173),
                                                      fontSize: 14)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      // mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 0, 0),
                                          child:
                                              TitleWidget(name: str.p_gender),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 15, 0, 0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  provider.gender = 'male';
                                                  setState(() {
                                                    value = true;
                                                  });
                                                },
                                                child: CustomizedRadioButton(
                                                  gender: "MALE",
                                                  isMaleSelected: value,
                                                ),
                                              ),
                                              TitleWidget(name: str.p_male),
                                              InkWell(
                                                onTap: () {
                                                  provider.gender = 'female';
                                                  print(provider.gender);
                                                  setState(() {
                                                    value = false;
                                                  });
                                                },
                                                child: CustomizedRadioButton(
                                                  gender: "FEMALE",
                                                  isMaleSelected: value,
                                                ),
                                              ),
                                              TitleWidget(name: str.p_female),
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              FadeSlideCustomAnimation(
                                delay: .5,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Row(
                                    children: [
                                      TitleWidget(name: str.p_country),
                                      const Icon(
                                        Icons.star_outlined,
                                        size: 10,
                                        color: ColorManager.errorRed,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              FadeSlideCustomAnimation(
                                delay: .55,
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
                                    child: Container(
                                      width: w,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: ColorManager.whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 10, 0, 10),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton2<Countries>(
                                              isExpanded: true,
                                              icon: const Icon(
                                                Icons.keyboard_arrow_down,
                                                size: 35,
                                                color: ColorManager.black,
                                              ),
                                              hint: Text(str.ae_country_h,
                                                  style: getRegularStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              173,
                                                              173,
                                                              173),
                                                      fontSize: 15)),
                                              items: r2
                                                  .map(
                                                      (item) =>
                                                          DropdownMenuItem<
                                                              Countries>(
                                                            value: item,
                                                            child: Row(
                                                              children: [
                                                                CachedNetworkImage(
                                                                    errorWidget: (context,
                                                                            url,
                                                                            error) =>
                                                                        Container(
                                                                          width:
                                                                              25,
                                                                          height:
                                                                              20,
                                                                          color:
                                                                              ColorManager.whiteColor,
                                                                        ),
                                                                    imageBuilder:
                                                                        (context,
                                                                                imageProvider) =>
                                                                            Container(
                                                                              width: 25,
                                                                              height: 20,
                                                                              decoration: BoxDecoration(
                                                                                // shape: BoxShape.circle,
                                                                                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                                                                              ),
                                                                            ),
                                                                    // width: 90,
                                                                    progressIndicatorBuilder:
                                                                        (context,
                                                                            url,
                                                                            progress) {
                                                                      return Container(
                                                                        color: ColorManager
                                                                            .black,
                                                                      );
                                                                    },
                                                                    imageUrl:
                                                                        '$endPoint${item.countryflag}'),
                                                                const SizedBox(
                                                                  width: 4,
                                                                ),
                                                                Text(
                                                                    item.countryName ??
                                                                        '',
                                                                    style: getRegularStyle(
                                                                        color: ColorManager
                                                                            .black,
                                                                        fontSize:
                                                                            15)),
                                                              ],
                                                            ),
                                                          ))
                                                  .toList(),
                                              // value: selectedValue,
                                              onChanged: (value) async {
                                                setState(() {
                                                  selectedValue =
                                                      value?.countryName ?? '';
                                                });
                                                defaultReg = null;
                                                await getRegionData(
                                                    context, value?.countryId);
                                                setState(() {});
                                                // provider.selectedAddressCountry =
                                                //     value as Countries;
                                              },
                                              buttonHeight: 40,
                                              dropdownMaxHeight: h * .6,
                                              // buttonWidth: 140,
                                              itemHeight: 40,
                                              buttonPadding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 0, 8, 0),
                                              // dropdownWidth: size.width,
                                              itemPadding: const EdgeInsets
                                                  .fromLTRB(12, 0, 12, 0),
                                              searchController:
                                                  AddressEditControllers
                                                      .searchController,
                                              searchInnerWidget: Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 8,
                                                  bottom: 4,
                                                  right: 8,
                                                  left: 8,
                                                ),
                                                child: TextFormField(
                                                  controller:
                                                      AddressEditControllers
                                                          .searchController,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 10,
                                                      vertical: 8,
                                                    ),
                                                    hintText:
                                                        str.s_search_country,
                                                    hintStyle: const TextStyle(
                                                        fontSize: 12),
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              customButton:
                                                  selectedValue == null
                                                      ? null
                                                      : Row(
                                                          children: [
                                                            Center(
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                            .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        10,
                                                                        0),
                                                                child: Text(
                                                                    selectedValue ??
                                                                        ''),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                              searchMatchFn:
                                                  (item, searchValue) {
                                                return (item.value.countryName
                                                    .toString()
                                                    .toLowerCase()
                                                    .contains(searchValue));
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
                                //   child: Padding(
                                //     padding:
                                //         const EdgeInsets.fromLTRB(0, 20, 0, 0),
                                //     child: Row(
                                //       children: [
                                //         TitleWidget(name: str.p_country),
                                //         const Icon(
                                //           Icons.star_outlined,
                                //           size: 10,
                                //           color: ColorManager.errorRed,
                                //         )
                                //       ],
                                //     ),
                                //   ),
                                // ),
                                // FadeSlideCustomAnimation(
                                //   delay: .55,
                                //   child: Padding(
                                //     padding:
                                //         const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                //     child: Container(
                                //       decoration: BoxDecoration(
                                //         boxShadow: [
                                //           BoxShadow(
                                //             blurRadius: 10.0,
                                //             color: Colors.grey.shade300,
                                //             // offset: const Offset(5, 8.5),
                                //           ),
                                //         ],
                                //       ),
                                //       child: Container(
                                //         width: w,
                                //         height: 50,
                                //         decoration: BoxDecoration(
                                //             color: ColorManager.whiteColor,
                                //             borderRadius:
                                //                 BorderRadius.circular(8)),
                                //         child: Padding(
                                //           padding: const EdgeInsets.fromLTRB(
                                //               0, 10, 0, 10),
                                //           child: DropdownButtonHideUnderline(
                                //             child: DropdownButton2(
                                //                 isExpanded: true,
                                //                 focusNode: nfocus,
                                //                 icon: const Icon(
                                //                   Icons.keyboard_arrow_down,
                                //                   size: 35,
                                //                   color: ColorManager.black,
                                //                 ),
                                //                 hint: Text(str.ae_country_h,
                                //                     style: getRegularStyle(
                                //                         color:
                                //                             const Color.fromARGB(
                                //                                 255,
                                //                                 173,
                                //                                 173,
                                //                                 173),
                                //                         fontSize: 15)),
                                //                 items: r3
                                //                     .map((item) =>
                                //                         DropdownMenuItem<String>(
                                //                           value: item,
                                //                           child: Text(item,
                                //                               style: getRegularStyle(
                                //                                   color:
                                //                                       ColorManager
                                //                                           .black,
                                //                                   fontSize: 15)),
                                //                         ))
                                //                     .toList(),
                                //                 value: selectedValue,
                                //                 onChanged: (value) {
                                //                   setState(() {
                                //                     selectedValue =
                                //                         value as String;
                                //                   });
                                //                   s(selectedValue);
                                //                 },
                                //                 buttonHeight: 40,
                                //                 dropdownMaxHeight: h * .6,
                                //                 // buttonWidth: 140,
                                //                 itemHeight: 40,
                                //                 buttonPadding:
                                //                     const EdgeInsets.fromLTRB(
                                //                         12, 0, 8, 0),
                                //                 // dropdownWidth: size.width,
                                //                 itemPadding: const EdgeInsets
                                //                     .fromLTRB(12, 0, 12, 0),
                                //                 searchController:
                                //                     AddressEditControllers
                                //                         .searchController,
                                //                 searchInnerWidget: Padding(
                                //                   padding: const EdgeInsets.only(
                                //                     top: 8,
                                //                     bottom: 4,
                                //                     right: 8,
                                //                     left: 8,
                                //                   ),
                                //                   child: TextFormField(
                                //                     controller:
                                //                         AddressEditControllers
                                //                             .searchController,
                                //                     decoration: InputDecoration(
                                //                       isDense: true,
                                //                       contentPadding:
                                //                           const EdgeInsets
                                //                               .symmetric(
                                //                         horizontal: 10,
                                //                         vertical: 8,
                                //                       ),
                                //                       // TODO: localisation
                                //                       hintText:
                                //                           str.s_search_country,
                                //                       hintStyle: const TextStyle(
                                //                           fontSize: 12),
                                //                       border: OutlineInputBorder(
                                //                         borderRadius:
                                //                             BorderRadius.circular(
                                //                                 8),
                                //                       ),
                                //                     ),
                                //                   ),
                                //                 ),
                                //                 searchMatchFn:
                                //                     (item, searchValue) {
                                //                   return (item.value
                                //                       .toString()
                                //                       .toLowerCase()
                                //                       .contains(searchValue));
                                //                 },
                                //                 //This to clear the search value when you close the menu
                                //                 onMenuStateChange: (isOpen) {
                                //                   if (!isOpen) {
                                //                     AddressEditControllers
                                //                         .searchController
                                //                         .clear();
                                //                   }
                                //                 }),
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                              ),

                              // Padding(
                              //   padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                              //   child: Container(
                              //     decoration: BoxDecoration(
                              //       boxShadow: [
                              //         BoxShadow(
                              //           blurRadius: 10.0,
                              //           color: Colors.grey.shade300,
                              //           // offset: const Offset(5, 8.5),
                              //         ),
                              //       ],
                              //     ),
                              //     child: Container(
                              //       width: w,
                              //       height: 50,
                              //       decoration: BoxDecoration(
                              //           color: ColorManager.whiteColor,
                              //           borderRadius: BorderRadius.circular(8)),
                              //       child: Padding(
                              //         padding:
                              //             const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              //         child: DropdownButtonHideUnderline(
                              //           child: DropdownButton2(
                              //             icon: const Icon(
                              //               Icons.keyboard_arrow_down,
                              //               size: 35,
                              //               color: ColorManager.black,
                              //             ),
                              //             hint: Text(str.p_country_h,
                              //                 style: getRegularStyle(
                              //                     color: const Color.fromARGB(
                              //                         255, 173, 173, 173),
                              //                     fontSize: 15)),
                              //             items: items
                              //                 .map((item) =>
                              //                     DropdownMenuItem<String>(
                              //                       value: item,
                              //                       child: Text(item,
                              //                           style: getRegularStyle(
                              //                               color: ColorManager
                              //                                   .black,
                              //                               fontSize: 15)),
                              //                     ))
                              //                 .toList(),
                              //             value: selectedValue,
                              //             onChanged: (value) {
                              //               setState(() {
                              //                 selectedValue = value as String;
                              //               });
                              //             },
                              //             buttonHeight: 40,
                              //             // buttonWidth: 140,
                              //             itemHeight: 40,
                              //             buttonPadding:
                              //                 const EdgeInsets.fromLTRB(
                              //                     12, 0, 8, 0),
                              //             // dropdownWidth: size.width,
                              //             itemPadding: const EdgeInsets.fromLTRB(
                              //                 12, 0, 12, 0),
                              //           ),
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),

                              // * Region
                              FadeSlideCustomAnimation(
                                delay: .6,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MandatoryHeader(heading: str.p_region),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          child: Container(
                                            width: w * .44,
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  blurRadius: 10.0,
                                                  color: Colors.grey.shade300,
                                                  // offset: const Offset(5, 8.5),
                                                ),
                                              ],
                                              color: ColorManager.whiteColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child:
                                                //  TextField(
                                                //   style: const TextStyle(),
                                                //   controller:
                                                //       ProfileServiceControllers
                                                //           .regionController,
                                                //   decoration: InputDecoration(
                                                //       hintText: str.p_region_h,
                                                //       hintStyle: getRegularStyle(
                                                //           color:
                                                //               const Color.fromARGB(
                                                //                   255,
                                                //                   173,
                                                //                   173,
                                                //                   173),
                                                //           fontSize: 15)),
                                                // ),
                                                DropdownButtonHideUnderline(
                                              child: DropdownButton2(
                                                isExpanded: true,
                                                focusNode: nfocus,
                                                icon: const Icon(
                                                  Icons.keyboard_arrow_down,
                                                  size: 35,
                                                  color: ColorManager.black,
                                                ),
                                                hint: Text(str.p_region_h,
                                                    style: getRegularStyle(
                                                        color: const Color
                                                                .fromARGB(
                                                            255, 173, 173, 173),
                                                        fontSize: 15)),
                                                items: provider
                                                    .regionInfoModel?.regions!
                                                    .map((item) =>
                                                        DropdownMenuItem<
                                                            String>(
                                                          value: item.cityName,
                                                          child: Text(
                                                              item.cityName ??
                                                                  '',
                                                              style: getRegularStyle(
                                                                  color:
                                                                      ColorManager
                                                                          .black,
                                                                  fontSize:
                                                                      15)),
                                                        ))
                                                    .toList(),
                                                // value: defaultReg,
                                                onChanged: (value) {
                                                  setState(() {
                                                    defaultReg =
                                                        value as String;
                                                  });
                                                  ProfileServiceControllers
                                                      .regionController
                                                      .text = defaultReg ?? '';
                                                  // s(selectedValue);
                                                },
                                                buttonHeight: 50,
                                                dropdownMaxHeight: h * .6,
                                                // buttonWidth: 140,
                                                itemHeight: 40,
                                                buttonPadding:
                                                    const EdgeInsets.fromLTRB(
                                                        12, 0, 8, 0),
                                                // dropdownWidth: size.width,
                                                itemPadding:
                                                    const EdgeInsets.fromLTRB(
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
                                                customButton: defaultReg == null
                                                    ? null
                                                    : Row(
                                                        children: [
                                                          Center(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      10,
                                                                      15,
                                                                      10,
                                                                      15),
                                                              child: Text(
                                                                  defaultReg ??
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MandatoryHeader(heading: str.p_city),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 10, 0, 0),
                                          child: Container(
                                            width: w * .44,
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
                                              style: const TextStyle(),
                                              controller:
                                                  ProfileServiceControllers
                                                      .stateController,
                                              decoration: InputDecoration(
                                                  hintText: str.p_city_h,
                                                  hintStyle: getRegularStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              173,
                                                              173,
                                                              173),
                                                      fontSize: 15)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              FadeSlideCustomAnimation(
                                delay: .7,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: TitleWidget(name: str.p_address),
                                ),
                              ),
                              FadeSlideCustomAnimation(
                                delay: .75,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 15),
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
                                    child: SizedBox(
                                      child: TextField(
                                        minLines: 4,
                                        maxLines: 5,
                                        style: const TextStyle(),
                                        controller: ProfileServiceControllers
                                            .addressController,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 10),
                                            hintText: str.p_address_h,
                                            hintStyle: getRegularStyle(
                                                color: const Color.fromARGB(
                                                    255, 173, 173, 173),
                                                fontSize: 15)),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.fromLTRB(
                                              28, 0, 28, 0)),
                                      onPressed: onContinue,
                                      child: Text(str.p_continue,
                                          style: getRegularStyle(
                                              color: ColorManager.whiteText,
                                              fontSize: 16))),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        builder: (context, child) {
          return Theme(
            data: ThemeData.light().copyWith(
                colorScheme:
                    const ColorScheme.light(primary: ColorManager.primary)),
            child: child!,
          );
        },
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(1900, 8),
        lastDate: DateTime.now());
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        ProfileServiceControllers.dateController.text =
            selectedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  onContinue() {
    print(ProfileServiceControllers.regionController.text);
    FocusManager.instance.primaryFocus?.unfocus();
    if (ProfileServiceControllers.firstNameController.text.isEmpty) {
      showAnimatedSnackBar(context, "Please Enter Your First Name");
    }
    //  else if (ProfileServiceControllers.lastNameController.text.isEmpty) {
    //   showAnimatedSnackBar(context, "Please Enter Your Last Name");
    // }
    else if (ProfileServiceControllers.civilCardController.text.isEmpty) {
      showAnimatedSnackBar(context, "Please Enter Your Civil Card Number");
    } else if (selectedValue == null) {
      showAnimatedSnackBar(context, "Please Select your country");
    } else if (ProfileServiceControllers.regionController.text.isEmpty) {
      showAnimatedSnackBar(context, "Please Enter Your Region");
    } else if (ProfileServiceControllers.stateController.text.isEmpty) {
      showAnimatedSnackBar(context, "Please Enter Your State");
    }
    // else if (ProfileServiceControllers.addressController.text.isEmpty) {
    //   showAnimatedSnackBar(context, "Please Enter Your Address");
    // }
    else {
      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
        return ChooseServicePage(
          scaffoldKey: _scaffoldKey,
        );
      }));
    }
  }

  fillFields(DataProvider provider) {
    final fieldData = provider.viewProfileModel?.userdetails;
    ProfileServiceControllers.firstNameController.text =
        fieldData?.firstname ?? '';

    ProfileServiceControllers.lastNameController.text =
        fieldData?.lastname ?? '';
    ProfileServiceControllers.civilCardController.text =
        fieldData?.civilCardNo ?? '';

    ProfileServiceControllers.dateController.text = fieldData?.dob ?? '';
    selectedValue = fieldData?.countryName ?? '';

    ProfileServiceControllers.stateController.text = fieldData?.state ?? '';

    ProfileServiceControllers.regionController.text = fieldData?.region ?? '';
    defaultReg = fieldData?.region;
  }

  s(filter) {
    setState(() {
      r = [];
    });
    // print(filter);
    final provider = Provider.of<DataProvider>(context, listen: false);
    provider.countriesModel?.countries?.forEach((element) {
      final m = element.countryName?.contains(filter);

      if (m == true) {
        if (selectedValue != element.countryName) {
          return;
        }
        setState(() {
          // r = [];
          r.add(element);
        });
        print(r[0].countryId);
        print(r[0].countryName);
        provider.selectedCountryId = r[0].countryId;
      }
    });
  }
}
