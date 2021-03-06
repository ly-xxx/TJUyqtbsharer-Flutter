package com.twt.service.widget

import android.content.Context
import android.util.Log
import org.json.JSONObject
import java.util.*
import kotlin.math.ceil
import kotlin.math.roundToInt

fun readCourseList(context: Context): List<Course> {
    val courseList = mutableListOf<Course>()

    // 这里的name是flutter的shared_preferences源码中的, 下面的`flutter.`前缀也是
    val pref = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)

    val nightMode = pref.getBoolean("flutter.nightMode", false) &&
            (Calendar.getInstance().get(Calendar.HOUR_OF_DAY) >= 21)

    val day = Calendar.getInstance().get(Calendar.DAY_OF_WEEK)

    val nowDay = day.let {
        val today = if (it == Calendar.SUNDAY) 7 else it - 1
        if (nightMode) (today + 1) % 7 else today
    }

    val nowTime: Int = (Calendar.getInstance().timeInMillis / 1000).toInt()
    val termStart: Int = pref.getLong("flutter.termStart", 0).toInt()
    val weeks: Double = (nowTime - termStart) / 604800.0

    val nowWeek = ceil(weeks).roundToInt().let {
        if (nightMode && day == Calendar.SUNDAY) it + 1 else it
    }

    // 假期里这个nowWeek可能为负或者超出周数上限，这里判断负数，超上限的判断在flag2那里
    if (nowWeek <= 0) return courseList

    pref.getString("flutter.scheduleData", "")?.let {
        if ("" == it) return emptyList()
        val obj = JSONObject(it)
        val list = obj.getJSONArray("courses")
        for (i in 0 until list.length()) {
            val scheduleCourse = list.getJSONObject(i)
            var courseName = scheduleCourse.getString("courseName")
            if (courseName.length > 15) courseName = courseName.substring(0, 15) + "..."
            val arrange = scheduleCourse.getJSONObject("arrange")
            var room = arrange.getString("room").replace("-", "楼")
            if (room == "") room = "————"
            val start = arrange.getString("start")
            val end = arrange.getString("end")
            val time = "第${start}-${end}节"
            val flag1 = nowDay == arrange.getString("day").toInt()
            val flag2 = arrange.getString("binStr").let { str ->
                if (str.length <= nowWeek) false else str[nowWeek] == '1'
            }
            if (flag1 && flag2) courseList.add(Course(courseName, room, time))
        }
    }
    courseList.sortWith { a, b -> a.time.compareTo(b.time) }
    return courseList
}

class Course(val courseName: String = "", val room: String = "", val time: String = "")