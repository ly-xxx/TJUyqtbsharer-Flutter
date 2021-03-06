import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:we_pei_yang_flutter/commons/res/color.dart';
import 'package:we_pei_yang_flutter/schedule/extension/logic_extension.dart';
import 'package:we_pei_yang_flutter/schedule/model/schedule_notifier.dart';
import 'package:we_pei_yang_flutter/schedule/model/school/school_model.dart';
import 'package:we_pei_yang_flutter/commons/util/router_manager.dart';
import 'package:we_pei_yang_flutter/generated/l10n.dart';
import 'package:we_pei_yang_flutter/commons/util/font_manager.dart';

class TodayCoursesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ScheduleNotifier>(builder: (context, notifier, _) {
      List<ScheduleCourse> todayCourses = _getTodayCourses(notifier);
      return Column(
        children: [
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, ScheduleRouter.schedule),
            child: Container(
              padding: const EdgeInsets.fromLTRB(25, 20, 0, 12),
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(S.current.schedule,
                      style: FontManager.YaQiHei.copyWith(
                          fontSize: 16,
                          color: Color.fromRGBO(100, 103, 122, 1.0),
                          fontWeight: FontWeight.bold)),
                  Expanded(child: Text("")),
                  Padding(
                    padding: const EdgeInsets.only(right: 25.0, top: 2),
                    child: (todayCourses.length == 0)
                        ? Container()
                        : DefaultTextStyle(
                            style: FontManager.YaHeiRegular.copyWith(
                                fontSize: 12,
                                color: Color.fromRGBO(100, 103, 122, 1.0)),
                            child: Text.rich(TextSpan(children: [
                              TextSpan(
                                  text: (notifier.nightMode &&
                                          DateTime.now().hour >= 21)
                                      ? "?????? "
                                      : "?????? "),
                              TextSpan(
                                  text: todayCourses.length.toString(),
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: " ?????? "),
                              TextSpan(
                                  text: ">", style: TextStyle(fontSize: 15))
                            ])),
                          ),
                  )
                ],
              ),
            ),
          ),
          _getDisplayWidget(notifier, todayCourses, context)
        ],
      );
    });
  }

  /// ??????????????????????????????????????????????????????
  List<ScheduleCourse> _getTodayCourses(ScheduleNotifier notifier) {
    /// ???????????????????????????????????????
    if (notifier.isOneDayBeforeTermStart) return [];
    List<ScheduleCourse> todayCourses = [];
    int today = DateTime.now().weekday;
    bool nightMode = notifier.nightMode;
    if (DateTime.now().hour < 21) nightMode = false;
    bool flag;
    notifier.coursesWithNotify.forEach((course) {
      if (nightMode)
        flag = judgeActiveTomorrow(
            notifier.currentWeek, today, notifier.weekCount, course);
      else
        flag = judgeActiveInDay(
            notifier.currentWeek, today, notifier.weekCount, course);
      if (flag) todayCourses.add(course);
    });
    return todayCourses;
  }

  /// ???????????????????????????widget
  Widget _getDisplayWidget(ScheduleNotifier notifier,
      List<ScheduleCourse> todayCourses, BuildContext context) {
    if (todayCourses.length == 0) {
      // ??????????????????????????????????????????
      return GestureDetector(
        onTap: () => Navigator.pushNamed(context, ScheduleRouter.schedule),
        child: Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
                color: Color.fromRGBO(236, 238, 237, 1),
                borderRadius: BorderRadius.circular(15)),
            child: Center(
              child: Text(
                  (notifier.nightMode && DateTime.now().hour >= 21)
                      ? "??????????????????"
                      : "??????????????????",
                  style: FontManager.YaHeiLight.copyWith(
                      color: Color.fromRGBO(207, 208, 212, 1),
                      fontSize: 14,
                      letterSpacing: 0.5)),
            )),
      );
    }

    /// ?????????????????????
    todayCourses.sort((a, b) => a.arrange.start.compareTo(b.arrange.start));
    return Container(
      height: 185,
      child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: todayCourses.length,
          itemBuilder: (context, i) {
            return Container(
              height: 185,
              width: 140,
              padding: const EdgeInsets.fromLTRB(7, 0, 7, 7),
              child: Material(
                color: FavorColors.homeSchedule[i % 5],
                borderRadius: BorderRadius.circular(15),
                elevation: 2,
                child: InkWell(
                  onTap: () =>
                      Navigator.pushNamed(context, ScheduleRouter.schedule),
                  borderRadius: BorderRadius.circular(15),
                  splashFactory: InkRipple.splashFactory,
                  splashColor: Color.fromRGBO(179, 182, 191, 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: 95,
                          alignment: Alignment.centerLeft,
                          child: Text(formatText(todayCourses[i].courseName),
                              style: FontManager.YaHeiBold.copyWith(
                                  fontSize: 15,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                              getCourseTime(todayCourses[i].arrange.start,
                                  todayCourses[i].arrange.end),
                              style: FontManager.Aspira.copyWith(
                                  fontSize: 11.5, color: Colors.white)),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(top: 15),
                          child: Text(
                              replaceBuildingWord(todayCourses[i].arrange.room),
                              style: FontManager.Aspira.copyWith(
                                  fontSize: 12.5,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
