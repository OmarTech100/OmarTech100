import 'dart:async';
import 'dart:io';
import 'package:country_code_picker/country_code.dart';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/localization_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/screens/auth/otp_screen.dart';
import 'package:efood_multivendor/view/screens/auth/widget/code_picker_widget.dart';
import 'package:efood_multivendor/view/screens/auth/widget/condition_check_box.dart';
import 'package:efood_multivendor/view/screens/auth/widget/guest_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phone_number/phone_number.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  SignInScreen({@required this.exitFromApp});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final FocusNode _phoneFocus = FocusNode();

  final FocusNode _passwordFocus = FocusNode();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  String _phone = '';
  bool _isLoading = false;
  bool hasInternetConnction = false;

  void validateInput() async {
    await InternetConnectionChecker().hasConnection.then((value) {
      setState(() {
        hasInternetConnction = value;
      });
    });
    setState(() {
      _isLoading = false;
    });

    if (_phone.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (_phone.length < 9) {
      showCustomSnackBar('invalid_phone_number'.tr);
    } else if (hasInternetConnction == false) {
      showSimpleNotification(
        Text(
          'No internet conncetion',
          style: TextStyle(color: Colors.white),
        ),
        background: Colors.red,
        context: context,
      );
    } else {
      Get.to(() => OTPScreen(
            exitFromApp: widget.exitFromApp,
            phone: _phone,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    String _countryDialCode =
        Get.find<AuthController>().getUserCountryCode().isNotEmpty
            ? Get.find<AuthController>().getUserCountryCode()
            : CountryCode.fromCountryCode(
                    Get.find<SplashController>().configModel.country)
                .dialCode;
    _phoneController.text = Get.find<AuthController>().getUserNumber() ?? '';
    _passwordController.text =
        Get.find<AuthController>().getUserPassword() ?? '';
    bool _canExit = false;

    return WillPopScope(
      onWillPop: () async {
        if (widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
            return Future.value(false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr,
                  style: TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
              margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
            ));
            _canExit = true;
            Timer(Duration(seconds: 2), () {
              _canExit = false;
            });
            return Future.value(false);
          }
        } else {
          return true;
        }
      },
      child: Scaffold(
        body: SafeArea(
            child: Center(
          child: Scrollbar(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
              child: Center(
                child: SizedBox(
                  width: 1170,
                  child: GetBuilder<AuthController>(builder: (authController) {
                    return Column(children: [
                      Image.asset(Images.logo, width: 100),
                      SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),
                      Text('Verify your phone number',
                          style: robotoBlack.copyWith(fontSize: 20)),
                      SizedBox(height: 50),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey[Get.isDarkMode ? 800 : 200],
                                spreadRadius: 1,
                                blurRadius: 5)
                          ],
                        ),
                        child: Column(children: [
                          Row(children: [
                            CodePickerWidget(
                              onChanged: (CountryCode countryCode) {
                                _countryDialCode = countryCode.dialCode;
                              },
                              initialSelection: _countryDialCode != null
                                  ? _countryDialCode
                                  : Get.find<LocalizationController>()
                                      .locale
                                      .countryCode,
                              favorite: [_countryDialCode],
                              showDropDownButton: true,
                              padding: EdgeInsets.zero,
                              showFlagMain: true,
                              flagWidth: 30,
                              textStyle: robotoRegular.copyWith(
                                fontSize: Dimensions.fontSizeLarge,
                                color:
                                    Theme.of(context).textTheme.bodyText1.color,
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: CustomTextField(
                                  hintText: 'phone'.tr,
                                  controller: _phoneController,
                                  onChanged: (val) {
                                    _phone = val;
                                  },
                                  focusNode: _phoneFocus,
                                  nextFocus: _passwordFocus,
                                  inputType: TextInputType.phone,
                                  divider: false,
                                )),
                          ]),
                          Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: Dimensions.PADDING_SIZE_LARGE),
                              child: Divider(height: 1)),

                          // CustomTextField(
                          //   hintText: 'password'.tr,
                          //   controller: _passwordController,
                          //   focusNode: _passwordFocus,
                          //   inputAction: TextInputAction.done,
                          //   inputType: TextInputType.visiblePassword,
                          //   prefixIcon: Images.lock,
                          //   isPassword: true,
                          //   onSubmit: (text) => (GetPlatform.isWeb && authController.acceptTerms)
                          //       ? _login(authController, _countryDialCode) : null,
                          // ),
                        ]),
                      ),
                      SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                      ConditionCheckBox(authController: authController),
                      SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      !authController.isLoading
                          ? Row(children: [
                              Expanded(
                                  child: CustomButton(
                                buttonText: 'Send code',
                                onPressed: authController.acceptTerms
                                    ? () {
                                        validateInput();
                                      }
                                    : null,
                              )),
                            ])
                          : Center(child: CircularProgressIndicator()),
                      SizedBox(height: 30),
                      GuestButton(),
                    ]);
                  }),
                ),
              ),
            ),
          ),
        )),
      ),
    );
  }
}
