package com.twt.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.Message
import android.util.Log
import androidx.work.*
import com.google.gson.Gson
import com.igexin.sdk.PushManager
import com.twt.service.message.server.PushCIdWorker
import com.umeng.analytics.MobclickAgent
import com.umeng.commonsdk.UMConfigure
import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

class WBYApplication : FlutterApplication() {
    companion object {
        lateinit var appContext: Context
        private val handler = MyHandler()
        var activity: WeakReference<MainActivity>? = null

        var tempCid = ""
        var eventList = mutableListOf<Event>().apply { add(Event(-1, "null")) }

        fun sendMessage(msg: Message) = handler.sendMessage(msg)

        class MyHandler : Handler(Looper.getMainLooper()) {
            companion object {
                const val RECEIVE_MESSAGE_DATA = 0
                const val RECEIVE_CLIENT_ID = 1
            }

            override fun handleMessage(msg: Message) {
                when (msg.what) {
                    RECEIVE_CLIENT_ID -> {
                        val cId = msg.obj.toString()
                        tempCid = cId
                        val workManager = WorkManager.getInstance(appContext)
                        val constraints = Constraints.Builder()
                            .setRequiredNetworkType(NetworkType.CONNECTED)
                            .setRequiresStorageNotLow(true)
                            .build()
                        val task = OneTimeWorkRequest.Builder(PushCIdWorker::class.java)
                            .addTag("1")
                            .setInputData(workDataOf("cid" to cId))
                            .setConstraints(constraints)
                            .build()
                        workManager.enqueueUniqueWork("download", ExistingWorkPolicy.KEEP, task)
                    }
                    RECEIVE_MESSAGE_DATA -> {
                        val data = msg.obj.toString()
                        Log.d("WBY", data)
                        Log.d("WBY", (activity?.get()?.messageChannel == null).toString())
                        val formData = try {
                            Gson().fromJson(data, BaseMessage::class.java)
                        } catch (e: Exception) {
                            Log.d("WBYException", data)
                            BaseMessage(type = MessageType.ErrorMessage.type, data = "null")
                        }
                        Log.d("WBY", formData.toString())
                        when (formData.type) {
                            MessageType.ReceiveFeedbackReply.type -> {
                                Log.d("WBY", Gson().toJson(formData.data))
                                val feedbackMessage = try {
                                    Gson().fromJson(
                                        Gson().toJson(formData.data),
                                        FeedbackMessage::class.java
                                    )
                                } catch (e: Exception) {
                                    FeedbackMessage(
                                        title = "null",
                                        content = "null",
                                        question_id = -1
                                    )
                                }
                                Log.d("WBY", feedbackMessage.toString())

                                feedbackMessage?.takeIf { it.question_id != -1 }?.let { message ->
                                    activity?.get()?.let {
                                        it.showNotification(message)
//                                        postId = -1
                                        activity?.get()?.messageChannel?.invokeMethod(
                                            "refreshFeedbackMessageCount",
                                            null,
                                            object : MethodChannel.Result {
                                                override fun success(result: Any?) {
                                                    Log.d("WBY", "refreshFeedbackMessageCount")
                                                }

                                                override fun error(
                                                    errorCode: String?,
                                                    errorMessage: String?,
                                                    errorDetails: Any?
                                                ) {
                                                    Log.d(
                                                        "WBY",
                                                        "refreshFeedbackMessageCount error"
                                                    )
                                                }

                                                override fun notImplemented() {
                                                    Log.d(
                                                        "WBY",
                                                        "refreshFeedbackMessageCount notImplemented"
                                                    )
                                                }
                                            })
                                    }
                                }
                            }
                            MessageType.ReceiveWBYPushMessageWithHtml.type -> {
                                Log.d("WBY", Gson().toJson(formData.data))
                                val pushMessage = try {
                                    Gson().fromJson(
                                        Gson().toJson(formData.data),
                                        WBYPushMessage::class.java
                                    )
                                } catch (e: Exception) {
                                    WBYPushMessage(title = "null", content = "null", url = "")
                                }
                                Log.d("WBY", pushMessage.toString())

                                activity?.get()?.showNotification(pushMessage)
                            }
                            MessageType.ReceiveWBYPushMessageOnlyText.type -> {
                                eventList.add(Event(IntentEvent.WBYPushOnlyText.type, data))
                                activity?.get()?.let {
                                    it.showNotification(
                                        WBYPushMessage(
                                            title = "??????",
                                            content = data,
                                            url = ""
                                        )
                                    )
                                    it.messageChannel?.invokeMethod(
                                        "showMessageDialogOnlyText",
                                        mapOf("data" to data),
                                        object : MethodChannel.Result {
                                            override fun success(result: Any?) {
                                                Log.d("WBY", "refreshFeedbackMessageCount")
                                            }

                                            override fun error(
                                                errorCode: String?,
                                                errorMessage: String?,
                                                errorDetails: Any?
                                            ) {
                                                Log.d("WBY", "refreshFeedbackMessageCount error")
                                            }

                                            override fun notImplemented() {
                                                Log.d(
                                                    "WBY",
                                                    "refreshFeedbackMessageCount notImplemented"
                                                )
                                            }
                                        })
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    override fun onCreate() {
        super.onCreate()
        appContext = this
        initSdk()
        // ???????????????
        UMConfigure.init(
            this,
            "60464782b8c8d45c1390e7e3",
            "Umeng",
            UMConfigure.DEVICE_TYPE_PHONE,
            ""
        )
        UMConfigure.setLogEnabled(true)
        MobclickAgent.setPageCollectionMode(MobclickAgent.PageMode.AUTO)
        Log.i("UMLog", "UMConfigure.init@MainApplication")
        createNotificationChannel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "aaa"
            val description = "bbb"
            //???????????????????????????????????????????????????
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel("1", name, importance)
            channel.description = description
            channel.setSound(null, null)
            channel.vibrationPattern = longArrayOf(0, 1000, 500, 1000)
            channel.enableVibration(true)
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }

    private fun initSdk() {
        Log.d("WBY", "initializing sdk...")
        PushManager.getInstance().initialize(this)
        if (BuildConfig.DEBUG) {
            //????????? release ???????????????????????????
            PushManager.getInstance().setDebugLogger(this) { s -> Log.i("PUSH_LOG", s) }
        }
        // PushManager.getInstance().turnOffPush(this)
        // ???????????????????????????????????????
    }
}

data class BaseMessage(
    val type: Int,
    val data: Any,
)

interface MessageData

data class FeedbackMessage(
    val title: String,
    val content: String,
    val question_id: Int,
) : MessageData

data class WBYPushMessage(
    val title: String,
    val content: String,
    val url: String,
) : MessageData

enum class MessageType(val type: Int) {
    ReceiveFeedbackReply(1),
    ReceiveWBYPushMessageWithHtml(2),
    ReceiveWBYPushMessageOnlyText(0),
    ErrorMessage(-1),
}

data class Event(
    val type: Int,
    val data: Any
)