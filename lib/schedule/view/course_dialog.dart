import 'package:flutter/material.dart';
import 'package:we_pei_yang_flutter/main.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/school/school_model.dart';
import 'package:we_pei_yang_flutter/schedule/extension/ui_extension.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';

void showCourseDialog(BuildContext context, List<ScheduleCourse> courses) =>
    showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Color.fromRGBO(255, 255, 255, 0.7),
        builder: (BuildContext context) => CourseDialog(courses));

class CourseDialog extends Dialog {
  final List<ScheduleCourse> courses;

  CourseDialog(this.courses);

  static final nameStyle = FontManager.YaQiHei.copyWith(
      fontSize: 24,
      color: Colors.white,
      decoration: TextDecoration.none,
      fontWeight: FontWeight.bold);

  static final teacherStyle = FontManager.YaHeiRegular.copyWith(
      fontSize: 14, color: Colors.white, decoration: TextDecoration.none);

  static final hintNameStyle = FontManager.YaHeiRegular.copyWith(
      fontSize: 10,
      color: Colors.white,
      decoration: TextDecoration.none,
      letterSpacing: 1);

  static final hintValueStyle = FontManager.Montserrat.copyWith(
      fontSize: 9,
      color: Colors.white,
      letterSpacing: 0.5,
      decoration: TextDecoration.none);

  @override
  Widget build(BuildContext context) {
    double width = WePeiYangApp.screenWidth - 120;
    return Center(
      child: Container(
        height: 340,
        child: courses.length == 1
            ? _getSingleCard(context, width, courses[0])
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                itemCount: courses.length,
                itemBuilder: (context, i) =>
                    _getSingleCard(context, width, courses[i])),
      ),
    );
  }

  Widget _getSingleCard(BuildContext context, double width,
          ScheduleCourse course) =>
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        width: width,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/icon_peiyang.png'),
                fit: BoxFit.cover,
                alignment: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(15),
            color: generateColor(course)),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 35, 20, 35),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.courseName, style: nameStyle),
                Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: Text(course.teacher, style: teacherStyle),
                ),
                Expanded(child: Text("")),
                _getRow1(course),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _getRow2(course),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _getRow3(course),
                )
              ],
            ),
          ),
        ),
      );

  Widget _getRow1(ScheduleCourse course) => Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 1),
                child: Text('ID', style: hintNameStyle),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(course.courseId, style: hintValueStyle),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.current.class_id, style: hintNameStyle),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(course.classId, style: hintValueStyle),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.current.campus,
                    style: hintNameStyle.copyWith(letterSpacing: 3)),
                Padding(
                  padding: const EdgeInsets.only(top: 1, left: 1),
                  child: Text(
                      "${course.campus}${course.campus.isNotEmpty ? "??????" : ""}",
                      style: hintValueStyle.copyWith(fontSize: 10)),
                )
              ],
            ),
          )
        ],
      );

  Widget _getRow2(ScheduleCourse course) => Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.current.arrange_room, style: hintNameStyle),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(replaceBuildingWord(course.arrange.room),
                    style: hintValueStyle),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.current.arrange_week, style: hintNameStyle),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text("${course.week.start}-${course.week.end}",
                      style: hintValueStyle),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(S.current.credit,
                    style: hintNameStyle.copyWith(letterSpacing: 3)),
                Padding(
                  padding: const EdgeInsets.only(top: 3, left: 2),
                  child: Text(course.credit, style: hintValueStyle),
                )
              ],
            ),
          )
        ],
      );

  Widget _getRow3(ScheduleCourse course) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.current.time, style: hintNameStyle.copyWith(letterSpacing: 3)),
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(getCourseTime(course.arrange.start, course.arrange.end),
                style: hintValueStyle),
          )
        ],
      );
}
