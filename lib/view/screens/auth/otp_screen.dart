import 'dart:async';
import 'dart:io';
import 'package:country_code_picker/country_code.dart';
import 'package:efood_multivendor/controller/auth_controller.dart';
import 'package:efood_multivendor/controller/splash_controller.dart';
import 'package:efood_multivendor/controller/wishlist_controller.dart';
import 'package:efood_multivendor/helper/route_helper.dart';
import 'package:efood_multivendor/util/dimensions.dart';
import 'package:efood_multivendor/util/images.dart';
import 'package:efood_multivendor/util/styles.dart';
import 'package:efood_multivendor/view/base/custom_button.dart';
import 'package:efood_multivendor/view/base/custom_snackbar.dart';
import 'package:efood_multivendor/view/base/custom_text_field.dart';
import 'package:efood_multivendor/view/screens/auth/sign_up_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:phone_number/phone_number.dart';

class OTPScreen extends StatefulWidget {
  final bool exitFromApp;
  final String phone;
  OTPScreen({@required this.exitFromApp, @required this.phone});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final FocusNode _phoneFocus = FocusNode();
  String _otpCode = '';
  final FocusNode _passwordFocus = FocusNode();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  String _verificationId = '';
  final _auth = FirebaseAuth.instance;
  Future<void> verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
        phoneNumber: '+966' + widget.phone,
        verificationCompleted: (PhoneAuthCredential credential) {},
        codeSent: (String verificationId, [int forceSendCode]) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        timeout: Duration(seconds: 60),
        verificationFailed: (FirebaseAuthException e) {
          print('===================>' + _verificationId);
          showDialog(
              context: context,
              builder: (context) {
                if (Platform.isIOS) {
                  return CupertinoAlertDialog(
                    title: Text('Error'),
                    content: e.message.contains('network error')
                        ? Text('Please check your network connection')
                        : Text(e.message.toString()),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'))
                    ],
                  );
                } else {
                  return AlertDialog(
                    title: Text('Error'),
                    content: e.message.contains('quota')
                        ? Text('Unknown error')
                        : Text(e.message.toString()),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'))
                    ],
                  );
                }
              });
        },
        codeAutoRetrievalTimeout: (String autoRet) {});
  }

  @override
  void initState() {
    verifyPhoneNumber();

    super.initState();
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
        appBar: widget.exitFromApp
            ? AppBar(
                leading: IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back_ios_rounded,
                      color: Theme.of(context).textTheme.bodyText1.color),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent)
            : null,
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
                      Text('Enter the OTP code sent to ${widget.phone}',
                          style: robotoBlack.copyWith(fontSize: 12)),
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
                            Expanded(
                                flex: 1,
                                child: CustomTextField(
                                  onSubmit: () {
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                  },
                                  hintText: 'Code',
                                  // controller: _phoneController,
                                  focusNode: _phoneFocus,
                                  // nextFocus: _passwordFocus,
                                  inputType: TextInputType.number,
                                  divider: false,
                                  onChanged: (val) {
                                    setState(() {
                                      _otpCode = val;
                                    });
                                  },
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
                      SizedBox(height: 10),
                      SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                      SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      !authController.isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: CustomButton(
                                  buttonText: 'Confirm',
                                  onPressed: _otpCode.length >= 6
                                      ? () async {
                                          final credential =
                                              PhoneAuthProvider.credential(
                                                  verificationId:
                                                      _verificationId,
                                                  smsCode: _otpCode);
                                          try {
                                            await _auth.signInWithCredential(
                                                credential);
                                            // _login(authController,
                                            //     _countryDialCode);
                                            if (credential != null) {
                                              _login(authController, '+966');
                                            }
                                          } on FirebaseAuthException catch (e) {
                                            showDialog(
                                                context: context,
                                                builder: (_) {
                                                  if (Platform.isIOS) {
                                                    return CupertinoAlertDialog(
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                            child: Text('Ok'))
                                                      ],
                                                      title: Text('Error'),
                                                      content: e.message
                                                              .contains('empty')
                                                          ? Text(
                                                              'Please enter the code!')
                                                          : e.message.contains(
                                                                  'invalid')
                                                              ? Text(
                                                                  'Invalid code!')
                                                              : Text(
                                                                  'Unkown error!'),
                                                    );
                                                  } else
                                                    return AlertDialog(
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () =>
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(),
                                                            child: Text('Ok'))
                                                      ],
                                                      title: Text('Error'),
                                                      content: e.message
                                                              .contains('empty')
                                                          ? Text(
                                                              'Please enter the code!')
                                                          : e.message.contains(
                                                                  'invalid')
                                                              ? Text(
                                                                  'Invalid code!')
                                                              : Text(
                                                                  'Unkown error!'),
                                                    );
                                                });
                                          }

                                          // _login(
                                          //     authController, _countryDialCode);
                                        }
                                      : null,
                                )),
                              ],
                            )
                          : Center(
                              child: Platform.isIOS
                                  ? CupertinoActivityIndicator()
                                  : CircularProgressIndicator()),
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

  void _login(AuthController authController, String countryDialCode) async {
    // String _password = _passwordController.text.trim();
    String _numberWithCountryCode = countryDialCode + widget.phone;
    bool _isValid = false;
    try {
      PhoneNumber phoneNumber =
          await PhoneNumberUtil().parse(_numberWithCountryCode);
      _numberWithCountryCode =
          '+' + phoneNumber.countryCode + phoneNumber.nationalNumber;
      _isValid = true;
    } catch (e) {}
    if (_otpCode.isEmpty) {
      showCustomSnackBar('Enter Code');
    } else {
      authController.login(_numberWithCountryCode).then((status) async {
        if (status.isSuccess) {
          if (authController.isActiveRememberMe) {
            authController.saveUserNumberAndPassword(
                widget.phone, countryDialCode);
          } else {
            authController.clearUserNumberAndPassword();
          }
          await Get.find<WishListController>().getWishList();
          String _token = status.message.substring(1, status.message.length);
          if (Get.find<SplashController>().configModel.customerVerification &&
              int.parse(status.message[0]) == 0) {
            // List<int> _encoded = utf8.encode(_password);
            // String _data = base64Encode(_encoded);
            Get.toNamed(RouteHelper.getVerificationRoute(
                _numberWithCountryCode, _token, RouteHelper.signUp));
          } else {
            Get.toNamed(RouteHelper.getAccessLocationRoute('sign-in'));
          }
        } else {
          Get.to(
            () => SignUpScreen(phone: widget.phone.trim()),
          );
          // showCustomSnackBar(status.message);
        }
      });
    }
  }

  // void _login(AuthController authController, String countryDialCode) async {
  //   String _phone = _phoneController.text.trim();
  //   // String _password = _passwordController.text.trim();
  //   String _numberWithCountryCode = countryDialCode + _phone;
  //   bool _isValid = false;
  //   try {
  //     PhoneNumber phoneNumber =
  //         await PhoneNumberUtil().parse(_numberWithCountryCode);
  //     _numberWithCountryCode =
  //         '+' + phoneNumber.countryCode + phoneNumber.nationalNumber;
  //     _isValid = true;
  //   } catch (e) {}
  //   if (_phone.isEmpty) {
  //     showCustomSnackBar('enter_phone_number'.tr);
  //   } else if (!_isValid) {
  //     showCustomSnackBar('invalid_phone_number'.tr);
  //   } else {
  //     authController.login(_numberWithCountryCode).then((status) async {
  //       if (status.isSuccess) {
  //         if (authController.isActiveRememberMe) {
  //           authController.saveUserNumberAndPassword(_phone, countryDialCode);
  //         } else {
  //           authController.clearUserNumberAndPassword();
  //         }
  //         await Get.find<WishListController>().getWishList();
  //         String _token = status.message.substring(1, status.message.length);
  //         if (Get.find<SplashController>().configModel.customerVerification &&
  //             int.parse(status.message[0]) == 0) {
  //           // List<int> _encoded = utf8.encode(_password);
  //           // String _data = base64Encode(_encoded);
  //           Get.toNamed(RouteHelper.getVerificationRoute(
  //               _numberWithCountryCode, _token, RouteHelper.signUp));
  //         } else {
  //           Get.toNamed(RouteHelper.getAccessLocationRoute('sign-in'));
  //         }
  //       } else {
  //         showCustomSnackBar(status.message);
  //       }
  //     });
  //   }
  // }

}
