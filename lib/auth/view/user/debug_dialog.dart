import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';

class DebugDialog extends Dialog {
  static final _hintStyle = FontManager.YaQiHei.copyWith(
      fontSize: 15,
      color: Color.fromRGBO(98, 103, 123, 1),
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.none);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color.fromRGBO(237, 240, 244, 1)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text("确定要进入日志页面吗？",
                  style: FontManager.YaHeiRegular.copyWith(
                      color: Color.fromRGBO(79, 88, 107, 1),
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      decoration: TextDecoration.none)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(S.current.cancel, style: _hintStyle),
                  ),
                ),
                Container(width: 30),
                GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, AuthRouter.debug),
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(S.current.ok, style: _hintStyle),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
