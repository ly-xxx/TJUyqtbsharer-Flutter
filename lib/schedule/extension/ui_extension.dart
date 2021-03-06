import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/commons/preferences/common_prefs.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/schedule/extension/animation_executor.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/school/school_model.dart';
import 'package:we_pei_yang_flutter/schedule/view/course_dialog.dart';

final activeNameStyle = FontManager.YaQiHei.copyWith(
    color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold);
final activeTeacherStyle =
    FontManager.YaHeiLight.copyWith(color: Colors.white, fontSize: 8);
final activeClassroomStyle =
    FontManager.Texta.copyWith(color: Colors.white, fontSize: 11);

const Color quietBackColor = Color.fromRGBO(236, 238, 237, 1);
const Color quiteFrontColor = Color.fromRGBO(205, 206, 210, 1);

final quietNameStyle = FontManager.YaQiHei.copyWith(
    color: quiteFrontColor, fontSize: 10, fontWeight: FontWeight.bold);
final quietHintStyle =
    FontManager.YaHeiRegular.copyWith(color: quiteFrontColor, fontSize: 9);

/// 为ActiveCourse生成随机颜色
Color generateColor(ScheduleCourse course) {
  var now = DateTime.now(); // 加点随机元素，以防一学期都是一个颜色
  int hashCode = course.courseName.hashCode + now.day;
  return FavorColors.scheduleColor[hashCode % FavorColors.scheduleColor.length];
}

/// 返回本周无需上的课（灰色）
Widget getQuietCourse(double height, double width, ScheduleCourse course) {
  return (CommonPreferences().otherWeekSchedule.value)
      ? Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: quietBackColor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              children: [
                Expanded(child: Text("")),
                Icon(Icons.lock, color: quiteFrontColor, size: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(formatText(course.courseName),
                      style: quietNameStyle, textAlign: TextAlign.center),
                ),
                Text(S.current.not_this_week,
                    style: quietHintStyle, textAlign: TextAlign.center),
                Expanded(child: Text(""))
              ],
            ),
          ),
        )
      : Container();
}

/// 返回本周需要上的课（亮色）
class AnimatedActiveCourse extends StatelessWidget {
  static const duration = const Duration(milliseconds: 375);
  final List<ScheduleCourse> courses;
  final double width;
  final double height;

  AnimatedActiveCourse(this.courses, this.width, this.height);

  @override
  Widget build(BuildContext context) {
    var start = int.parse(courses[0].arrange.start) - 1;
    var day = int.parse(courses[0].arrange.day) - 1;
    return AnimationExecutor(
      duration: duration,
      delay: _stagger(start, day),
      builder: (BuildContext context, Animation<double> animation) {
        var curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.ease,
        );

        return Transform.scale(
          scale: Tween<double>(begin: 0.5, end: 1.0)
              .animate(curvedAnimation)
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 0.0, end: 1.0)
                .animate(curvedAnimation)
                .value,
            child: getCourseDetail(context),
          ),
        );
      },
    );
  }

  Widget getCourseDetail(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Material(
        color: generateColor(courses[0]),
        borderRadius: BorderRadius.circular(5),
        child: InkWell(
          onTap: () => showCourseDialog(context, courses),
          borderRadius: BorderRadius.circular(5),
          splashFactory: InkRipple.splashFactory,
          splashColor: Color.fromRGBO(179, 182, 191, 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Column(
              children: [
                Spacer(),
                Text(formatText(courses[0].courseName),
                    style: activeNameStyle, textAlign: TextAlign.center),
                SizedBox(height: 2),
                Text(removeParentheses(courses[0].teacher),
                    style: activeTeacherStyle, textAlign: TextAlign.center),
                courses[0].arrange.room == ""
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                            replaceBuildingWord(courses[0].arrange.room),
                            style: activeClassroomStyle,
                            textAlign: TextAlign.center),
                      ),
                courses.length == 1
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Image.asset('assets/images/schedule_warn.png',
                            width: 20, height: 20),
                      ),
                Spacer()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Duration _stagger(int start, int day) => Duration(
      milliseconds: (start * 3 + day * 2) * duration.inMilliseconds ~/ 18);
}
