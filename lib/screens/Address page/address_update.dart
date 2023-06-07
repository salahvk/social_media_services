import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_media_services/API/address/getUserAddress.dart';
import 'package:social_media_services/API/endpoint.dart';
import 'package:social_media_services/API/get_region_info.dart';
import 'package:social_media_services/components/assets_manager.dart';
import 'package:social_media_services/components/color_manager.dart';
import 'package:social_media_services/components/styles_manager.dart';
import 'package:social_media_services/controllers/controllers.dart';
import 'package:social_media_services/model/get_countries.dart';
import 'package:social_media_services/model/user_address_show.dart';
import 'package:social_media_services/providers/data_provider.dart';
import 'package:social_media_services/responsive/responsive_width.dart';
import 'package:social_media_services/screens/Address%20page/address_page.dart';
import 'package:social_media_services/screens/Google%20Map/address_locator.dart';
import 'package:social_media_services/screens/messagePage.dart';
import 'package:social_media_services/screens/serviceHome.dart';
import 'package:social_media_services/utils/animatedSnackBar.dart';
import 'package:social_media_services/widgets/custom_drawer.dart';
import 'package:social_media_services/widgets/mandatory_widget.dart';
import 'package:social_media_services/widgets/profile_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:social_media_services/widgets/textField_Profile.dart';
import 'package:http/http.dart' as http;
import 'package:async/async.dart';

class UserAddressUpdate extends StatefulWidget {
  final UserAddress userAddress;
  bool isUpdate;
  UserAddressUpdate(
      {super.key, required this.userAddress, this.isUpdate = false});

  @override
  State<UserAddressUpdate> createState() => _UserAddressUpdateState();
}

class _UserAddressUpdateState extends State<UserAddressUpdate> {
  Countries? selectedValue;
  String? countryValue;

  int _selectedIndex = 2;
  final List<Widget> _screens = [const ServiceHomePage(), const MessagePage()];
  String lang = '';
  List<Countries> r2 = [];
  final ImagePicker _picker = ImagePicker();
  bool isLoading = false;
  bool isSaveAddressLoading = false;
  String? imagePath;
  String? defaultReg;
  XFile? imageFile;
  GoogleMapController? mapController;
  @override
  void initState() {
    super.initState();
    lang = Hive.box('LocalLan').get(
      'lang',
    );
    if (widget.isUpdate == false) {
      fillFields();
    } else {
      countryValue = widget.userAddress.country;
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final provider = Provider.of<DataProvider>(context, listen: false);
      int? n = provider.countriesModel?.countries?.length;
      int i = 0;
      while (i < n!.toInt()) {
        r2.add(provider.countriesModel!.countries![i]);
        i++;
      }
      if (widget.isUpdate == true) {
        imageFile = provider.image ?? XFile('');
        imagePath = provider.image?.path ?? '';
      } else {
        imageFile = XFile('');
        imagePath = '';

        // final currentLocator = LatLng(
        //     double.parse(widget.userAddress.latitude ?? '1.612849'),
        //     double.parse(widget.userAddress.longitude ?? '1.046816'));
        // mapController?.animateCamera(CameraUpdate.newCameraPosition(
        //     CameraPosition(target: currentLocator, zoom: 12)));
      }
      provider.clearRegions();
      await getRegionData(context, widget.userAddress.countryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final str = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final provider = Provider.of<DataProvider>(context, listen: true);
    final userDetails = provider.viewProfileModel?.userdetails;
    final w = MediaQuery.of(context).size.width;
    final mobWth = ResponsiveWidth.isMobile(context);
    final smobWth = ResponsiveWidth.issMobile(context);
    print("$endPoint${widget.userAddress.image}");
    final currentLocator = LatLng(
        provider.addressLatitude ??
            double.parse(widget.userAddress.latitude ?? '41.612849'),
        provider.addressLongitude ??
            double.parse(widget.userAddress.longitude ?? '13.046816'));
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
                  // reverse: true,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ProfileImage(
                          isNavigationActive: true,
                          iconSize: 12,
                          profileSize: 40.5,
                          iconRadius: 12,
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              provider.viewProfileModel?.userdetails
                                      ?.firstname ??
                                  '',
                              style: getBoldtStyle(
                                  color: ColorManager.black, fontSize: 13),
                            ),
                            const SizedBox(
                              width: 2,
                            ),
                            Text(
                              provider.viewProfileModel?.userdetails
                                      ?.lastname ??
                                  '',
                              style: getBoldtStyle(
                                  color: ColorManager.black, fontSize: 13),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 2,
                        ),
                        // Text(
                        //   "mail @gmail.com",
                        //   style: getRegularStyle(
                        //       color: ColorManager.grayLight, fontSize: 13),
                        // ),
                        // const SizedBox(
                        //   height: 2,
                        // ),
                        // Text(
                        //   provider.viewProfileModel?.userdetails?.phone ?? '',
                        //   style: getRegularStyle(
                        //       color: ColorManager.grayLight, fontSize: 13),
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5, top: 5),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                str.ae_address,
                                style: getBoldtStyle(
                                    color: ColorManager.black, fontSize: 14),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: ColorManager.primary,
                                    borderRadius: BorderRadius.circular(5)),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(5),
                                child: SizedBox(
                                  height: 100,
                                  width: size.width,
                                  child: isLoading
                                      ? Container(
                                          height: 20,
                                          color: ColorManager.whiteColor,
                                          child: const Center(
                                              child:
                                                  CircularProgressIndicator()))
                                      : AddressImageWidget2(
                                          userAddress: widget.userAddress,
                                          imagePath: imagePath ?? ''),
                                ),
                              ),
                              Positioned(
                                right: 5,
                                top: 5,
                                child: InkWell(
                                  onTap: () {
                                    selectImage();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.shade300,
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          // offset: const Offset(2, 2.5),
                                        ),
                                      ],
                                    ),
                                    child: const CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.white,
                                      child: Icon(
                                        Icons.edit,
                                        size: 14,
                                        color: ColorManager.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 40,
                          width: size.width,
                          decoration: BoxDecoration(
                              color: ColorManager.whiteColor,
                              borderRadius: BorderRadius.circular(5)),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  provider.locality ??
                                      widget.userAddress.country ??
                                      '',
                                  style: getRegularStyle(
                                    color: ColorManager.black,
                                    // fontSize:
                                    // userDetails.homeLocation!.length >
                                    //         10
                                    //     ? 10
                                    //     : 12
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                      color: ColorManager.primary,
                                      borderRadius: BorderRadius.circular(5)),

                                  // width: 30,
                                  child: InkWell(
                                    onTap: () {
                                      // Navigator.push(context,
                                      //     MaterialPageRoute(builder: (ctx) {
                                      //   return CustomizeMarkerExample();
                                      // }));
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (ctx) {
                                        return AddressLocatorScreen(
                                          isUpdate: true,
                                          userAddress: widget.userAddress,
                                        );
                                      }));
                                    },
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 2, 5, 5),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: ColorManager.whiteColor,
                                          ),
                                          Text(
                                            // str.ae_home_locator,
                                            "Address Locator",
                                            style: getRegularStyle(
                                                color: ColorManager.whiteColor),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 14),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: SizedBox(
                              height: 100,
                              width: size.width,
                              child: GoogleMap(
                                myLocationEnabled: true,
                                initialCameraPosition: CameraPosition(
                                  target: currentLocator,
                                  zoom: 4.0,
                                ),
                                onMapCreated: (controller) {
                                  setState(() {
                                    mapController = controller;
                                  });
                                },
                                markers: <Marker>{
                                  Marker(
                                    markerId: const MarkerId('test_marker_id'),
                                    position: currentLocator,
                                    infoWindow: InfoWindow(
                                      title: str.a_home_locator,
                                      snippet: '*',
                                    ),
                                  ),
                                },
                              ),
                            ),
                          ),
                        ),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Text(
                        //       str.ae_address,
                        //       style: getBoldtStyle(
                        //           color: ColorManager.black, fontSize: 14),
                        //     ),
                        //     Container(
                        //       decoration: BoxDecoration(
                        //           color: ColorManager.primary,
                        //           borderRadius: BorderRadius.circular(5)),

                        //       // width: 30,
                        //       child: Padding(
                        //         padding:
                        //             const EdgeInsets.fromLTRB(5, 5, 5, 5),
                        //         child: Row(
                        //           children: [
                        //             const Icon(
                        //               Icons.location_on,
                        //               color: ColorManager.whiteColor,
                        //             ),
                        //             Text(
                        //               str.ae_add,
                        //               style: getRegularStyle(
                        //                   color: ColorManager.whiteColor),
                        //             )
                        //           ],
                        //         ),
                        //       ),
                        //     )
                        //   ],
                        // ),
                        MandatoryHeader(heading: str.ae_address_n),
                        TextFieldProfileService(
                            hintText: str.ae_address_h,
                            controller:
                                AddressEditControllers.addressNameController),
                        MandatoryHeader(heading: str.ae_address),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                                controller:
                                    AddressEditControllers.addressController,
                                decoration: InputDecoration(
                                    contentPadding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 10),
                                    hintText: str.ae_address_h,
                                    hintStyle: getRegularStyle(
                                        color: const Color.fromARGB(
                                            255, 173, 173, 173),
                                        fontSize: 15)),
                              ),
                            ),
                          ),
                        ),
                        MandatoryHeader(heading: str.ae_country),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
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
                              width: size.width,
                              height: 50,
                              decoration: BoxDecoration(
                                  color: ColorManager.whiteColor,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 10, 0, 10),
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
                                              color: const Color.fromARGB(
                                                  255, 173, 173, 173),
                                              fontSize: 15)),
                                      items: r2
                                          .map((item) =>
                                              DropdownMenuItem<Countries>(
                                                value: item,
                                                child: Row(
                                                  children: [
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
                                                            color: ColorManager
                                                                .black,
                                                          );
                                                        },
                                                        imageUrl:
                                                            '$endPoint${item.countryflag}'),
                                                    const SizedBox(
                                                      width: 4,
                                                    ),
                                                    Text(item.countryName ?? '',
                                                        style: getRegularStyle(
                                                            color: ColorManager
                                                                .black,
                                                            fontSize: 15)),
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                      // value: selectedValue,
                                      onChanged: (value) async {
                                        setState(() {
                                          selectedValue = value as Countries;
                                        });
                                        defaultReg = null;
                                        await getRegionData(
                                            context, selectedValue?.countryId);
                                        setState(() {});
                                      },
                                      buttonHeight: 40,
                                      dropdownMaxHeight: size.height * .6,
                                      // buttonWidth: 140,
                                      itemHeight: 40,
                                      buttonPadding: const EdgeInsets.fromLTRB(
                                          12, 0, 8, 0),
                                      // dropdownWidth: size.width,
                                      itemPadding: const EdgeInsets.fromLTRB(
                                          12, 0, 12, 0),
                                      searchController: AddressEditControllers
                                          .searchController,
                                      searchInnerWidget: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8,
                                          bottom: 4,
                                          right: 8,
                                          left: 8,
                                        ),
                                        child: TextFormField(
                                          controller: AddressEditControllers
                                              .searchController,
                                          decoration: InputDecoration(
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 8,
                                            ),
                                            hintText: str.s_search_country,
                                            hintStyle:
                                                const TextStyle(fontSize: 12),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                      customButton: selectedValue == null
                                          ? Row(
                                              children: [
                                                Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 0, 10, 0),
                                                    child: Text(
                                                        countryValue ?? ''),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Center(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(10, 0, 10, 0),
                                                    child: Text(selectedValue
                                                            ?.countryName ??
                                                        ''),
                                                  ),
                                                ),
                                              ],
                                            ),
                                      searchMatchFn: (item, searchValue) {
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
                        ), // * Region
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MandatoryHeader(heading: str.ae_region),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Container(
                                    width: size.width * .44,
                                    decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                          blurRadius: 10.0,
                                          color: Colors.grey.shade300,
                                          // offset: const Offset(5, 8.5),
                                        ),
                                      ],
                                      color: ColorManager.whiteColor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton2(
                                        isExpanded: true,
                                        // focusNode: nfocus,
                                        icon: const Icon(
                                          Icons.keyboard_arrow_down,
                                          size: 35,
                                          color: ColorManager.black,
                                        ),
                                        hint: Text(str.p_region_h,
                                            style: getRegularStyle(
                                                color: const Color.fromARGB(
                                                    255, 173, 173, 173),
                                                fontSize: 15)),
                                        items: provider
                                            .regionInfoModel?.regions!
                                            .map((item) =>
                                                DropdownMenuItem<String>(
                                                  value: item.cityName,
                                                  child: Text(
                                                      item.cityName ?? '',
                                                      style: getRegularStyle(
                                                          color: ColorManager
                                                              .black,
                                                          fontSize: 15)),
                                                ))
                                            .toList(),
                                        value: defaultReg,
                                        onChanged: (value) {
                                          setState(() {
                                            defaultReg = value as String;
                                          });
                                          // s(selectedValue);
                                        },
                                        buttonHeight: 50,
                                        dropdownMaxHeight: size.height * .6,
                                        // buttonWidth: 140,
                                        itemHeight: 40,
                                        buttonPadding:
                                            const EdgeInsets.fromLTRB(
                                                12, 0, 8, 0),
                                        // dropdownWidth: size.width,
                                        itemPadding: const EdgeInsets.fromLTRB(
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
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          10, 15, 10, 15),
                                                      child: Text(
                                                          defaultReg ?? ''),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MandatoryHeader(heading: str.ae_state),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 10, 0, 0),
                                  child: Container(
                                    width: size.width * .44,
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
                                      controller: AddressEditControllers
                                          .stateController,
                                      decoration: InputDecoration(
                                          hintText: str.ae_state_h,
                                          hintStyle: getRegularStyle(
                                              color: const Color.fromARGB(
                                                  255, 173, 173, 173),
                                              fontSize: 15)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        MandatoryHeader(heading: str.ae_home_flat),
                        TextFieldProfileService(
                            hintText: str.ae_no,
                            controller:
                                AddressEditControllers.flatNoController),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    validateAddressFields();
                                  },
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 0)),
                                  child: isSaveAddressLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 3,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    ColorManager.whiteColor),
                                          ))
                                      : Text(
                                          str.ae_save,
                                          style: getMediumtStyle(
                                              color: ColorManager.whiteText,
                                              fontSize: 14),
                                        )),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 0)),
                                  child: Text(
                                    str.ae_cancel,
                                    style: getMediumtStyle(
                                        color: ColorManager.whiteText,
                                        fontSize: 14),
                                  ))
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ));
  }

  validateAddressFields() {
    final addressName = AddressEditControllers.addressNameController.text;
    final address = AddressEditControllers.addressController.text;
    final country = selectedValue?.countryId;
    // final region = AddressEditControllers.regionController.text;
    final state = AddressEditControllers.stateController.text;
    final flat = AddressEditControllers.flatNoController.text;

    if (addressName.isEmpty) {
      showAnimatedSnackBar(context, "Address name field is required");
    } else if (address.isEmpty) {
      showAnimatedSnackBar(context, "Address field is required");
    } else if (selectedValue == null && countryValue == null) {
      showAnimatedSnackBar(context, "Select a country");
    } else if (defaultReg == null) {
      showAnimatedSnackBar(context, "Region is required");
    } else if (state.isEmpty) {
      showAnimatedSnackBar(context, "state is required");
    } else if (flat.isEmpty) {
      showAnimatedSnackBar(context, "Flat No is required");
    } else {
      setState(() {
        isSaveAddressLoading = true;
      });
      addressUpdaeFun(context);
    }
  }

  addressUpdaeFun(BuildContext context) async {
    final provider = Provider.of<DataProvider>(context, listen: false);
    final addressName = AddressEditControllers.addressNameController.text;
    final address = AddressEditControllers.addressController.text;
    final country = selectedValue != null
        ? (selectedValue?.countryId)
        : widget.userAddress.countryId;
    final region = defaultReg;
    final state = AddressEditControllers.stateController.text;
    final flat = AddressEditControllers.flatNoController.text;
    final id = widget.userAddress.id;
    final latitude = provider.addressLatitude ?? widget.userAddress.latitude;
    final longitude = provider.addressLongitude ?? widget.userAddress.longitude;
    //  final otpProvider = Provider.of<OTPProvider>(context, listen: false);

    final apiToken = Hive.box("token").get('api_token');

    try {
      var uri = Uri.parse(
          '$updateUserAddressApi?address_name=$addressName&address=$address&country_id=$country&state=$state&region=$region&home_no=$flat&address_id=$id&latitude=$latitude&longitude=$longitude');
      var request = http.MultipartRequest(
        "POST",
        uri,
      );
      if (imagePath!.isNotEmpty) {
        var stream = http.ByteStream(DelegatingStream(imageFile!.openRead()));
        var length = await imageFile!.length();
        print("imagepath not empty");
        request.headers.addAll(
            {"device-id": provider.deviceId ?? '', "api-token": apiToken});
        var multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: (imageFile!.path),
        );
        request.files.add(multipartFile);
        var response = await request.send();
      }

      var response = await http.post(uri, headers: {
        "device-id": provider.deviceId ?? '',
        "api-token": apiToken
      });
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        log(response.body);
        await getUserAddress(context);
        setState(() {
          isSaveAddressLoading = false;
        });

        navigateToAddressPage();

        // final subServicesData = SubServicesModel.fromJson(jsonResponse);
        // provider.subServicesModelData(subServicesData);
      } else {
        // print(response.statusCode);
        // print(response.body);
        // print('Something went wrong');
      }
    } on Exception catch (e) {
      log("Something Went Wrong1");
      print(e);
    }
  }

  navigateToAddressPage() {
    Navigator.pop(context);
    clearFields();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (ctx) {
      return const AddressPage();
    }));
  }

  // selectImage() async {
  //   print("Img picker");
  //   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
  //   final imagePath = image?.path;
  //   final imageName = image?.name;
  //   print(image?.name);
  //   print(image?.path);
  //   // final XFile? photo =
  //   //     await _picker.pickImage(source: ImageSource.camera);
  //   if (image == null) {
  //     return;
  //   }
  //   // updateProfile(imageName);
  //   setState(() {
  //     isLoading = true;
  //   });
  //   await upload(image);
  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  // upload(XFile imageFile) async {
  //   var stream = http.ByteStream(DelegatingStream(imageFile.openRead()));
  //   var length = await imageFile.length();
  //   final apiToken = Hive.box("token").get('api_token');
  //   final provider = Provider.of<DataProvider>(context, listen: false);
  //   var uri = Uri.parse(updateCoverPictureApi);
  //   var request = http.MultipartRequest(
  //     "POST",
  //     uri,
  //   );
  //   // "content-type": "multipart/form-data"
  //   request.headers
  //       .addAll({"device-id": provider.deviceId ?? '', "api-token": apiToken});
  //   var multipartFile = http.MultipartFile(
  //     'cover_image',
  //     stream,
  //     length,
  //     filename: (imageFile.path),
  //   );
  //   request.files.add(multipartFile);
  //   var response = await request.send();
  //   print(response.statusCode);
  //   await viewProfile(context);
  //   setState(() {});
  // }

  fillFields() {
    AddressEditControllers.addressNameController.text =
        widget.userAddress.addressName ?? '';
    AddressEditControllers.addressController.text =
        widget.userAddress.address ?? '';
    AddressEditControllers.regionController.text =
        widget.userAddress.region ?? '';
    AddressEditControllers.stateController.text =
        widget.userAddress.state ?? '';
    AddressEditControllers.flatNoController.text =
        widget.userAddress.homeNo ?? '';
    countryValue = widget.userAddress.country;
  }

  clearFields() {
    AddressEditControllers.addressNameController.text = '';
    AddressEditControllers.addressController.text = '';
    AddressEditControllers.regionController.text = '';
    AddressEditControllers.stateController.text = '';
    AddressEditControllers.flatNoController.text = '';
  }

  selectImage() async {
    print("Img picker");
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    final provider = Provider.of<DataProvider>(context, listen: false);
    setState(() {
      imagePath = image?.path;
      imageFile = image;
      provider.image = image;
    });

    final imageName = image?.name;
    print(image?.name);
    print(image?.path);
    // final XFile? photo =
    //     await _picker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return;
    }
    // updateProfile(imageName);
    setState(() {
      isLoading = true;
    });
    // await upload(image);
    setState(() {
      isLoading = false;
    });
  }
}

class AddressImageWidget2 extends StatelessWidget {
  const AddressImageWidget2({Key? key, this.imagePath, this.userAddress})
      : super(key: key);

  final String? imagePath;
  final UserAddress? userAddress;

  @override
  Widget build(BuildContext context) {
    final str = AppLocalizations.of(context)!;
    return SizedBox(
      child: imagePath!.isEmpty
          ? CachedNetworkImage(
              imageUrl: "$endPoint${userAddress?.image}",
              fit: BoxFit.cover,
            )
          : Image.file(
              File(
                imagePath ?? '',
              ),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 20,
                  color: ColorManager.whiteColor,
                  child: Center(
                    child: Text(
                      "Please choose an address Photo",
                      style: getRegularStyle(
                          color: ColorManager.black, fontSize: 14),
                    ),
                  ),
                );
              },
            ),
    );
    //  CachedNetworkImage(
    //   imageUrl: '$endPoint/assets/uploads/cover_image/${userDetails?.coverPic}',
    //   fit: BoxFit.cover,

    // );
  }
}
