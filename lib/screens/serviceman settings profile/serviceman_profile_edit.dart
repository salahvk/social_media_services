// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_media_services/API/endpoint.dart';
import 'package:social_media_services/API/get_serviceManProfileDetails.dart';
import 'package:social_media_services/API/update_ServiceMan.dart';
import 'package:social_media_services/components/assets_manager.dart';
import 'package:social_media_services/components/color_manager.dart';
import 'package:social_media_services/components/styles_manager.dart';
import 'package:social_media_services/controllers/controllers.dart';
import 'package:social_media_services/model/get_countries.dart';
import 'package:social_media_services/providers/data_provider.dart';
import 'package:social_media_services/responsive/responsive.dart';
import 'package:social_media_services/responsive/responsive_width.dart';
import 'package:social_media_services/screens/messagePage.dart';
import 'package:social_media_services/screens/serviceHome.dart';
import 'package:social_media_services/screens/serviceman%20settings%20profile/serviceman_profile_view.dart';
import 'package:social_media_services/utils/animatedSnackBar.dart';
import 'package:social_media_services/utils/delete_image.dart';
import 'package:social_media_services/widgets/custom_drawer.dart';
import 'package:social_media_services/widgets/description_edit_widget.dart';
import 'package:social_media_services/widgets/popup_image.dart';
import 'package:social_media_services/widgets/profile_image.dart';
import 'package:social_media_services/widgets/statusListTile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

class ServiceManProfileEditPage extends StatefulWidget {
  const ServiceManProfileEditPage({super.key});

  @override
  State<ServiceManProfileEditPage> createState() =>
      _ServiceManProfileEditPageState();
}

class _ServiceManProfileEditPageState extends State<ServiceManProfileEditPage> {
  String checkBoxValue = '';
  int _selectedIndex = 2;
  final List<Widget> _screens = [const ServiceHomePage(), const MessagePage()];
  String lang = '';
  String? selectedValue;
  int? countryid;

  final ImagePicker _picker = ImagePicker();

  String? selectedCountry;
  List<Countries> r = [];

  bool isCountryEditEnabled = false;
  bool isStatusVisible = false;
  bool isLoading = false;

  List<String> r3 = [];
  List<String> items = [
    'four wheeler',
    'two wheeler',
  ];
  @override
  void initState() {
    super.initState();
    lang = Hive.box('LocalLan').get(
      'lang',
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      // print(timeStamp);
      final provider = Provider.of<DataProvider>(context, listen: false);
      final userData = provider.serviceManProfile?.userData;
      final str = AppLocalizations.of(context)!;
      int? n = provider.countriesModel?.countries?.length;
      int i = 0;
      while (i < n!.toInt()) {
        r3.add(provider.countriesModel!.countries![i].countryName!);
        i++;
      }
      await getServiceManProfileFun(context);
      ServiceManProfileEdit.descriptionController.text = userData?.about ?? '';
      ServiceManProfileEdit.detailsController.text = userData?.profile ?? '';
      items = [str.s_two, str.s_four];
      // print('object');
      // print(userData?.transport ?? 's');
      setState(() {
        checkBoxValue = userData?.onlineStatus ?? '';
        selectedValue =
            userData!.transport!.contains('four') ? str.s_four : str.s_two;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DataProvider>(context, listen: true);
    final size = MediaQuery.of(context).size;
    final userData = provider.serviceManProfile?.userData;
    final str = AppLocalizations.of(context)!;
    final w = MediaQuery.of(context).size.width;
    final mobWth = ResponsiveWidth.isMobile(context);
    final smobWth = ResponsiveWidth.issMobile(context);
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
                    child: SvgPicture.asset(ImageAssets.chatIconSvg),
                  ),
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
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: size.width,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Stack(
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
                                        top: 10,
                                        left: 5,
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              isStatusVisible =
                                                  !isStatusVisible;
                                            });
                                          },
                                          child: CircleAvatar(
                                            radius: 9,
                                            backgroundColor:
                                                userData?.onlineStatus ==
                                                        'online'
                                                    ? ColorManager.primary
                                                    : userData?.onlineStatus ==
                                                            'offline'
                                                        ? ColorManager.grayLight
                                                        : ColorManager.errorRed,
                                            child: isStatusVisible
                                                ? const Icon(
                                                    Icons.keyboard_arrow_up,
                                                    color: ColorManager.black,
                                                  )
                                                : const Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: ColorManager.black,
                                                  ),
                                          ),
                                        )),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          isStatusVisible
                              ? Positioned(
                                  left: size.width * .17,
                                  top: 22,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: ColorManager.primary,
                                        borderRadius: BorderRadius.circular(5)),
                                    width: 95,
                                    height: 120,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5, 0, 0, 0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    checkBoxValue = 'online';
                                                    isStatusVisible = false;
                                                  });
                                                },
                                                child: StatusLIstTile(
                                                  checkBoxValue: checkBoxValue,
                                                  title2: str.wd_online,
                                                  title: 'online',
                                                )),
                                            InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    checkBoxValue = 'offline';
                                                    isStatusVisible = false;
                                                  });
                                                },
                                                child: StatusLIstTile(
                                                  checkBoxValue: checkBoxValue,
                                                  title2: str.wd_offline,
                                                  title: 'offline',
                                                )),
                                            InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    checkBoxValue = 'busy';
                                                    isStatusVisible = false;
                                                  });
                                                },
                                                child: StatusLIstTile(
                                                  checkBoxValue: checkBoxValue,
                                                  title2: str.wd_busy,
                                                  title: 'busy',
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 4),
                        child: Text(
                          '${userData?.firstname ?? ''} ${userData?.lastname ?? ''}',
                          style: getRegularStyle(
                              color: ColorManager.black, fontSize: 16),
                        ),
                      ),
                      Container(
                        height: 35,
                        width: 170,
                        decoration: BoxDecoration(
                          color: ColorManager.whiteColor,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 10.0,
                              color: Colors.grey.shade300,
                              offset: const Offset(5, 8.5),
                            ),
                          ],
                        ),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              child: Image.asset(ImageAssets.tools),
                            ),
                            Text(userData?.serviceName ?? '',
                                style: getRegularStyle(
                                    color: ColorManager.engineWorkerColor,
                                    fontSize: 15)),
                            // const Spacer(),
                            // Padding(
                            //   padding: const EdgeInsets.fromLTRB(10, 0, 5, 0),
                            //   child: Image.asset(ImageAssets.penEdit),
                            // )
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            isCountryEditEnabled = !isCountryEditEnabled;
                          });
                        },
                        child: Container(
                          height: 35,
                          width: 170,
                          decoration: BoxDecoration(
                            color: ColorManager.whiteColor,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 10.0,
                                color: Colors.grey.shade300,
                                offset: const Offset(5, 8.5),
                              ),
                            ],
                          ),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 140,
                                child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: Text(
                                      '${userData?.countryName ?? ''} | ${userData?.state ?? ''}',
                                      style: getRegularStyle(
                                          color: ColorManager.engineWorkerColor,
                                          fontSize:
                                              userData!.countryName!.length > 10
                                                  ? 10
                                                  : 12),
                                    )),
                              ),
                              SizedBox(
                                width: 30,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(2, 0, 2, 0),
                                  child: isCountryEditEnabled
                                      ? const Icon(Icons.arrow_drop_up_outlined)
                                      : Image.asset(ImageAssets.penEdit),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
// * Country edit enabled

                      isCountryEditEnabled
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
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
                                      width: size.width * .45,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: ColorManager.whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 10, 0, 10),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton2(
                                              isExpanded: true,
                                              // focusNode: nfocus,
                                              // icon: const Icon(
                                              //   Icons.keyboard_arrow_down,
                                              //   size: 35,
                                              //   color: ColorManager.black,
                                              // ),
                                              hint: Text(str.ae_country_h,
                                                  style: getRegularStyle(
                                                      color:
                                                          const Color.fromARGB(
                                                              255,
                                                              173,
                                                              173,
                                                              173),
                                                      fontSize: 15)),
                                              items: r3
                                                  .map((item) =>
                                                      DropdownMenuItem<String>(
                                                        value: item,
                                                        child: Text(item,
                                                            style: getRegularStyle(
                                                                color:
                                                                    ColorManager
                                                                        .black,
                                                                fontSize: 15)),
                                                      ))
                                                  .toList(),
                                              value: selectedCountry,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedCountry =
                                                      value as String;
                                                });
                                                s(selectedCountry);
                                              },
                                              buttonHeight: 40,
                                              dropdownMaxHeight:
                                                  size.height * .6,
                                              // buttonWidth: 140,
                                              itemHeight: 40,
                                              buttonPadding:
                                                  const EdgeInsets.fromLTRB(
                                                      12, 0, 8, 0),
                                              // dropdownWidth: size.width,
                                              itemPadding: const EdgeInsets
                                                  .fromLTRB(12, 0, 12, 0),
                                              searchController:
                                                  ServiceManProfileEdit
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
                                                      ServiceManProfileEdit
                                                          .searchController,
                                                  decoration: InputDecoration(
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                      horizontal: 10,
                                                      vertical: 8,
                                                    ),
                                                    // TODO: localisation
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
                                              searchMatchFn:
                                                  (item, searchValue) {
                                                return (item.value
                                                    .toString()
                                                    .toLowerCase()
                                                    .contains(searchValue));
                                              },
                                              //This to clear the search value when you close the menu
                                              onMenuStateChange: (isOpen) {
                                                if (!isOpen) {
                                                  ServiceManProfileEdit
                                                      .searchController
                                                      .clear();
                                                }
                                              }),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: size.width * .45,
                                    height: 40,
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
                                          ServiceManProfileEdit.stateController,
                                      decoration: InputDecoration(
                                          hintText: str.e_state_h,
                                          hintStyle: getRegularStyle(
                                              color: const Color.fromARGB(
                                                  255, 173, 173, 173),
                                              fontSize:
                                                  Responsive.isMobile(context)
                                                      ? 15
                                                      : 10)),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // * Add image start
                          InkWell(
                            onTap: () {
                              selectImage();
                            },
                            child: Container(
                                width: 30,
                                height: 21,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 9.5,
                                      color: Colors.grey.shade400,
                                      offset: const Offset(6, 6),
                                    ),
                                  ],
                                  borderRadius: BorderRadius.circular(5),
                                  color: ColorManager.whiteColor,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(3.0),
                                  child: Image.asset(
                                    ImageAssets.addImage,
                                    fit: BoxFit.contain,
                                  ),
                                )),
                          ),
                          const SizedBox(
                            width: 3,
                          ),

                          // * Image gallery start
                          Container(
                              width: 30,
                              height: 21,
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
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Image.asset(
                                  ImageAssets.gallery,
                                  fit: BoxFit.contain,
                                ),
                              ))
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          itemCount:
                              provider.serviceManProfile!.galleryImages!.isEmpty
                                  ? 4
                                  : provider
                                      .serviceManProfile?.galleryImages?.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final galleryImages =
                                provider.serviceManProfile?.galleryImages;
                            return Padding(
                              padding: const EdgeInsets.fromLTRB(3, 0, 3, 0),
                              child: InkWell(
                                onTap: () {
                                  galleryImages!.isEmpty
                                      ? showAnimatedSnackBar(
                                          context, str.sv_no_images)
                                      : showDialog(
                                          context: context,
                                          builder: (context) => PopupImage(
                                              image: galleryImages[index]
                                                  .galleryImage),
                                          barrierDismissible: true);
                                },
                                onLongPress: () {
                                  final imageId = galleryImages?[index].id;
                                  showDialog(
                                      context: context,
                                      builder: (context) => DeleteImage(
                                          imageId: imageId.toString()),
                                      barrierDismissible: false);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Container(
                                    height: 80,
                                    width: size.width * .28,
                                    color: ColorManager.grayLight,
                                    child: galleryImages!.isEmpty
                                        ? Image.asset(
                                            'assets/no_image.png',
                                            fit: BoxFit.cover,
                                          )
                                        : CachedNetworkImage(
                                            errorWidget: (context, url, error) {
                                              return Container(
                                                height: 80,
                                                width: size.width * .28,
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
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                        child: DescriptionEditWidget(
                            controller:
                                ServiceManProfileEdit.descriptionController,
                            hint: str.wd_desc,
                            title: str.wd_desc),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: w * .3,
                              child: Text(
                                str.wd_ser,
                                style: getRegularStyle(
                                    color: ColorManager.black, fontSize: 16),
                              ),
                            ),
                            // SizedBox(
                            //   width: size.width * .05,
                            // ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: ColorManager.whiteColor,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10.0,
                                    color: Colors.grey.shade300,
                                    offset: const Offset(5, 8.5),
                                  ),
                                ],
                              ),
                              height: 40,
                              width: size.width * .5,
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 10,
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
                                  Text(userData.serviceName ?? '',
                                      style: getRegularStyle(
                                          color: ColorManager.engineWorkerColor,
                                          fontSize: 15)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: w * .3,
                            child: Text(
                              str.wd_tran,
                              style: getRegularStyle(
                                  color: ColorManager.black, fontSize: 16),
                            ),
                          ),
                          // SizedBox(
                          //   width: size.width * .1,
                          // ),
                          DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              isExpanded: true,
                              hint: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      str.se_transport_ty,
                                      style: getRegularStyle(
                                          color: ColorManager.grayLight),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              items: items
                                  .map((item) => DropdownMenuItem<String>(
                                        value: item,
                                        child: Text(
                                          item,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            // fontWeight: FontWeight.bold,
                                            color: ColorManager.grayLight,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ))
                                  .toList(),
                              // value: selectedValue,
                              customButton: selectedValue == null
                                  ? null
                                  : Container(
                                      height: 40,
                                      width: size.width * .5,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: ColorManager.whiteColor,
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 10.0,
                                            color: Colors.grey.shade300,
                                            offset: const Offset(5, 8.5),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 14, right: 14),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  selectedValue ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    // fontWeight: FontWeight.bold,
                                                    color:
                                                        ColorManager.grayLight,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons
                                                      .arrow_forward_ios_outlined,
                                                  color: ColorManager.primary,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                              onChanged: (value) {
                                setState(() {
                                  selectedValue = value as String;
                                });
                                print(value);
                              },
                              icon: const Icon(
                                Icons.arrow_forward_ios_outlined,
                              ),
                              iconSize: 14,
                              iconEnabledColor: ColorManager.primary,
                              iconDisabledColor: Colors.grey,
                              buttonHeight: 40,
                              buttonWidth: size.width * .5,
                              buttonPadding:
                                  const EdgeInsets.only(left: 14, right: 14),
                              buttonDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 10.0,
                                    color: Colors.grey.shade300,
                                    offset: const Offset(5, 8.5),
                                  ),
                                ],
                                // border: Border.all(
                                //   color: Colors.black26,
                                // ),
                                color: ColorManager.whiteColor,
                              ),
                              // buttonElevation: 2,
                              itemHeight: 40,
                              itemPadding:
                                  const EdgeInsets.only(left: 14, right: 14),
                              dropdownMaxHeight: 200,
                              dropdownWidth: size.width * .5,
                              dropdownPadding: null,
                              dropdownDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                color: ColorManager.background,
                              ),
                              dropdownElevation: 8,
                              scrollbarRadius: const Radius.circular(40),
                              scrollbarThickness: 6,
                              scrollbarAlwaysShow: true,
                              // offset: const Offset(-20, 0),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 15, 0, 10),
                        child: DescriptionEditWidget(
                            controller: ServiceManProfileEdit.detailsController,
                            hint: 'Details',
                            title: str.wd_more),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isLoading = true;
                                });
                                onSaveFunction();
                              },
                              style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.fromLTRB(33, 0, 33, 0)),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: Center(
                                          child: CircularProgressIndicator(
                                        backgroundColor: ColorManager.primary,
                                        color: ColorManager.whiteColor,
                                        strokeWidth: 5,
                                      )))
                                  : Text(
                                      str.e_save,
                                      style: getMediumtStyle(
                                          color: ColorManager.whiteText,
                                          fontSize: 14),
                                    ))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  onSaveFunction() {
    final provider = Provider.of<DataProvider>(context, listen: false);
    final str = AppLocalizations.of(context)!;
    final userData = provider.serviceManProfile?.userData;
    final state = ServiceManProfileEdit.stateController.text.isEmpty
        ? userData?.state ?? ''
        : ServiceManProfileEdit.stateController.text;
    final about = ServiceManProfileEdit.descriptionController.text.isEmpty
        ? userData?.about ?? ''
        : ServiceManProfileEdit.descriptionController.text;
    final profile = ServiceManProfileEdit.detailsController.text.isEmpty
        ? userData?.profile ?? ''
        : ServiceManProfileEdit.detailsController.text;
    final countryId = countryid ?? userData?.countryId.toString();
    String transport = '';
    if (selectedValue != null) {
      if (selectedValue!.contains(str.s_two)) {
        transport = 'two wheeler';
      } else {
        transport = 'four wheeler';
      }
    }

    updateServiceManApiFun(context, state, countryId.toString(), about, profile,
        transport, checkBoxValue);
  }

  s(filter) {
    setState(() {
      r = [];
    });

    final provider = Provider.of<DataProvider>(context, listen: false);
    provider.countriesModel?.countries?.forEach((element) {
      final m = element.countryName?.contains(filter);

      if (m == true) {
        if (selectedCountry != element.countryName) {
          return;
        }
        setState(() {
          // r = [];
          r.add(element);
        });
        countryid = r[0].countryId;

        provider.selectedCountryId = r[0].countryId;
      }
    });
  }

  selectImage() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images == null) {
      return;
    }

    upload(images);
  }

  upload(List<XFile> imageFile) async {
    final provider = Provider.of<DataProvider>(context, listen: false);
    final userData = provider.serviceManProfile?.userData;
    final str = AppLocalizations.of(context)!;
    final state = ServiceManProfileEdit.stateController.text.isEmpty
        ? userData?.state ?? ''
        : ServiceManProfileEdit.stateController.text;
    final about = ServiceManProfileEdit.descriptionController.text.isEmpty
        ? userData?.about ?? ''
        : ServiceManProfileEdit.descriptionController.text;
    final profile = ServiceManProfileEdit.detailsController.text.isEmpty
        ? userData?.profile ?? ''
        : ServiceManProfileEdit.detailsController.text;
    final cntryId = countryid ?? userData?.countryId.toString();

    String transport = '';
    if (selectedValue != null) {
      if (selectedValue!.contains(str.s_two)) {
        transport = 'two wheeler';
      } else {
        transport = 'four wheeler';
      }
    }

    final length = imageFile.length;
    var uri = Uri.parse(
        '$updateServiceManApi?state=$state&country_id=${cntryId.toString()}&profile=$profile&about=$about&transport=$transport&online_status=$checkBoxValue');
    var request = http.MultipartRequest(
      "POST",
      uri,
    );

    print(uri);

    List<MultipartFile> multiPart = [];
    for (var i = 0; i < length; i++) {
      var stream = http.ByteStream(DelegatingStream(imageFile[i].openRead()));
      var length = await imageFile[i].length();
      final apiToken = Hive.box("token").get('api_token');

      request.headers.addAll(
          {"device-id": provider.deviceId ?? '', "api-token": apiToken});
      var multipartFile = http.MultipartFile(
        'gallery_images[]',
        stream,
        length,
        filename: (imageFile[i].path),
      );
      multiPart.add(multipartFile);
    }

    length > 1
        ? request.files.addAll(multiPart)
        : request.files.add(multiPart[0]);

    // "content-type": "multipart/form-data"

    var response = await request.send();
    final res = await http.Response.fromStream(response);
    var jsonResponse = jsonDecode(res.body);

    if (jsonResponse["result"] == false) {
      showAnimatedSnackBar(context, jsonResponse["message"]);
      setState(() {});
      return;
    }

    navigateToViewPage();
  }

  navigateToViewPage() async {
    await getServiceManProfileFun(context);
    Navigator.pop(context);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) {
      return ServiceManProfileViewPage();
    }));
  }
}
