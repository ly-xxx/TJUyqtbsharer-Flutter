import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/auth/network/auth_service.dart';
import 'package:we_pei_yang_flutter/commons/util/toast_provider.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/main.dart';

class AddInfoWidget extends StatefulWidget {
  @override
  _AddInfoWidgetState createState() => _AddInfoWidgetState();
}

class _AddInfoWidgetState extends State<AddInfoWidget> {
  String email = "";
  String phone = "";
  String code = "";
  bool isPress = false;

  _fetchCaptcha() async {
    if (phone == "") {
      ToastProvider.error("手机号码不能为空");
      return;
    }
    AuthService.getCaptchaOnRegister(phone,
        onSuccess: () {
          setState(() => isPress = true);
        },
        onFailure: (e) => ToastProvider.error(e.error.toString()));
  }

  _submit() async {
    if (email == "")
      ToastProvider.error("E-mail不能为空");
    else if (phone == "")
      ToastProvider.error("手机号码不能为空");
    else if (code == "")
      ToastProvider.error("短信验证码不能为空");
    else {
      AuthService.addInfo(phone, code, email,
          onSuccess: () {
            ToastProvider.success("登录成功");
            Navigator.pushNamedAndRemoveUntil(
                context, HomeRouter.home, (route) => false);
          },
          onFailure: (e) => ToastProvider.error(e.error.toString()));
    }
  }

  FocusNode _emailFocus = FocusNode();
  FocusNode _phoneFocus = FocusNode();

  static final TextStyle _hintStyle = FontManager.YaHeiRegular.copyWith(
      color: Color.fromRGBO(201, 204, 209, 1), fontSize: 13);

  @override
  Widget build(BuildContext context) {
    double width = WePeiYangApp.screenWidth - 80;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
          backgroundColor: Color.fromRGBO(250, 250, 250, 1),
          elevation: 0,
          brightness: Brightness.light,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15),
            child: GestureDetector(
                child: Icon(Icons.arrow_back,
                    color: Color.fromRGBO(98, 103, 123, 1), size: 35),
                onTap: () => Navigator.pop(context)),
          )),
      body: Column(
        children: [
          Container(
            alignment: Alignment.center,
            child: Text(S.current.add_info_hint,
                style: FontManager.YaHeiRegular.copyWith(
                    color: Color.fromRGBO(98, 103, 123, 1),
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 30, 30, 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 55,
              ),
              child: TextField(
                textInputAction: TextInputAction.next,
                focusNode: _emailFocus,
                decoration: InputDecoration(
                    hintText: S.current.email,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => email = input),
                onEditingComplete: () {
                  _emailFocus.unfocus();
                  FocusScope.of(context).requestFocus(_phoneFocus);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 55,
              ),
              child: TextField(
                focusNode: _phoneFocus,
                decoration: InputDecoration(
                    hintText: S.current.phone,
                    hintStyle: _hintStyle,
                    filled: true,
                    fillColor: Color.fromRGBO(235, 238, 243, 1),
                    isCollapsed: true,
                    contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none)),
                onChanged: (input) => setState(() => phone = input),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 0),
            child: Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 50,
                    maxWidth: width / 2 + 20,
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                        hintText: S.current.text_captcha,
                        hintStyle: _hintStyle,
                        filled: true,
                        fillColor: Color.fromRGBO(235, 238, 243, 1),
                        isCollapsed: true,
                        contentPadding: EdgeInsets.fromLTRB(15, 18, 0, 18),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none)),
                    onChanged: (input) => setState(() => code = input),
                  ),
                ),
                Container(
                    height: 55,
                    width: width / 2 - 20,
                    margin: const EdgeInsets.only(left: 20),
                    child: isPress
                        ? StreamBuilder<int>(
                            stream: Stream.periodic(
                                    Duration(seconds: 1), (time) => time + 1)
                                .take(60),
                            builder: (context, snap) {
                              var time = 60 - (snap.data ?? 0);
                              if (time == 0)
                                WidgetsBinding.instance.addPostFrameCallback(
                                    (_) => setState(() => isPress = false));
                              return RaisedButton(
                                onPressed: () {},
                                color: Colors.grey[300],
                                splashColor: Colors.grey[300],
                                child: Text('$time秒后重试',
                                    style: FontManager.YaHeiRegular.copyWith(
                                        color: Color.fromRGBO(98, 103, 123, 1),
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold)),
                                elevation: 5.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              );
                            })
                        : RaisedButton(
                            onPressed: _fetchCaptcha,
                            color: Color.fromRGBO(53, 59, 84, 1.0),
                            splashColor: Color.fromRGBO(103, 110, 150, 1.0),
                            child: Text(S.current.fetch_captcha,
                                style: FontManager.YaHeiRegular.copyWith(
                                    color: Colors.white, fontSize: 13)),
                            elevation: 5.0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          )),
              ],
            ),
          ),
          Container(
              height: 50.0,
              width: 400.0,
              margin: EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 0.0),
              child: RaisedButton(
                onPressed: _submit,
                color: Color.fromRGBO(53, 59, 84, 1.0),
                splashColor: Color.fromRGBO(103, 110, 150, 1.0),
                child: Text(S.current.login2,
                    style: FontManager.YaHeiRegular.copyWith(
                        color: Colors.white, fontSize: 13)),
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
              )),
        ],
      ),
    );
  }
}
