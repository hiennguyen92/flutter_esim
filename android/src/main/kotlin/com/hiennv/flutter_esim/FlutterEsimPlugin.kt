package com.hiennv.flutter_esim

import android.annotation.SuppressLint
import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Context.EUICC_SERVICE
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.telephony.euicc.DownloadableSubscription
import android.telephony.euicc.EuiccManager
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.ref.WeakReference


/** FlutterEsimPlugin */
class FlutterEsimPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    companion object {

        private fun <T, C : MutableCollection<WeakReference<T>>> C.reapCollection(): C {
            this.removeAll {
                it.get() == null
            }
            return this
        }

        @SuppressLint("StaticFieldLeak")
        private lateinit var instance: FlutterEsimPlugin

        private val methodChannels = mutableMapOf<BinaryMessenger, MethodChannel>()
        private val eventChannels = mutableMapOf<BinaryMessenger, EventChannel>()
        private val eventHandlers = mutableListOf<WeakReference<EventCallbackHandler>>()

        fun sendEvent(event: String, body: Map<String, Any>) {
            eventHandlers.reapCollection().forEach {
                it.get()?.send(event, body)
            }
        }

        fun initSharedInstance(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
            if (!::instance.isInitialized) {
                instance = FlutterEsimPlugin()
                instance.context = flutterPluginBinding.applicationContext
            }

            val channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_esim")
            methodChannels[flutterPluginBinding.binaryMessenger] = channel
            channel.setMethodCallHandler(instance)

            val events = EventChannel(flutterPluginBinding.binaryMessenger, "flutter_esim_events")
            val handler = EventCallbackHandler()
            eventHandlers.add(WeakReference(handler))
            events.setStreamHandler(handler)
            eventChannels[flutterPluginBinding.binaryMessenger] = events
        }


    }

    private var activity: Activity? = null
    private var context: Context? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        initSharedInstance(flutterPluginBinding)
    }

    private val REQUEST_CODE_INSTALL = 999
    private val ACTION_DOWNLOAD_SUBSCRIPTION = "download_subscription"

    private var mgr: EuiccManager? = null


    private val receiver: BroadcastReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            if (ACTION_DOWNLOAD_SUBSCRIPTION != intent.action) {
                return
            }

            if (resultCode == EuiccManager.EMBEDDED_SUBSCRIPTION_RESULT_RESOLVABLE_ERROR && mgr != null) {
                handleResolvableError(intent)
            } else if (resultCode == EuiccManager.EMBEDDED_SUBSCRIPTION_RESULT_OK) {
                sendEvent("success", HashMap())
            } else if (resultCode == EuiccManager.EMBEDDED_SUBSCRIPTION_RESULT_ERROR) {
                sendEvent("fail", HashMap())
            } else {
                // Unknown Error
                sendEvent("unknown", HashMap())
            }
        }
    }

    @SuppressLint("UnspecifiedRegisterReceiverFlag")
    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "isSupportESim" -> {
                    Log.d("isSupportESim", "")
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        result.success(mgr?.isEnabled)
                    }else {
                        result.success(false)
                    }
                }

                "installEsimProfile" -> {
                    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
                        sendEvent("unsupport", HashMap())
                        return
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P && mgr != null && !mgr!!.isEnabled) {
                        sendEvent("unsupport", HashMap())
                        return
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        context?.registerReceiver(
                            receiver,
                            IntentFilter(ACTION_DOWNLOAD_SUBSCRIPTION),
                            null,
                            null,
                            Context.RECEIVER_NOT_EXPORTED
                        )
                    } else {
                        context?.registerReceiver(
                            receiver,
                            IntentFilter(ACTION_DOWNLOAD_SUBSCRIPTION),
                            null,
                            null
                        )
                    }
                    val eSimProfile = (call.arguments as HashMap<*, *>)["profile"] as String
                    val sub = DownloadableSubscription.forActivationCode(eSimProfile)
                    val explicitIntent = Intent(ACTION_DOWNLOAD_SUBSCRIPTION);
                    explicitIntent.apply {
                        `package` = context?.packageName
                    }
                    val callbackIntent = PendingIntent.getBroadcast(
                        context,
                        REQUEST_CODE_INSTALL,
                        explicitIntent,
                        PendingIntent.FLAG_UPDATE_CURRENT or
                                PendingIntent.FLAG_MUTABLE
                    )
                    mgr?.downloadSubscription(sub, true, callbackIntent)
                }

                "instructions" -> {
                    Log.d("installEsimProfile", "")
                    result.success("1. Save QR Code\n" +
                    "2. Go to Settings on your device\n" +
                    "3. TAP Connections\n" +
                    "4. TAP SIM Manager\n" +
                    "5. TAP Add eSIM\n" +
                    "6. TAP Scan QR code from service provider\n" +
                    "7. TAP Enter activation code\n"+
                    "8. ENTER the activation code found in the eSIM details\n"+
                    "9. TAP Connect\n" +
                    "10. TAP Add")
                }
            }
        } catch (error: Exception) {
            result.notImplemented()
        }
    }


    private fun handleResolvableError(intent: Intent) {
        try {
            val explicitIntent = Intent(ACTION_DOWNLOAD_SUBSCRIPTION);
            explicitIntent.apply {
                `package` = context?.packageName
            }
            val callbackIntent = PendingIntent.getBroadcast(
                context, REQUEST_CODE_INSTALL,
                explicitIntent, PendingIntent.FLAG_UPDATE_CURRENT or
                        PendingIntent.FLAG_MUTABLE
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                mgr!!.startResolutionActivity(
                    activity,
                    REQUEST_CODE_INSTALL,
                    intent,
                    callbackIntent
                )
            }
        } catch (e: java.lang.Exception) {
        }
    }


    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannels.remove(binding.binaryMessenger)?.setMethodCallHandler(null)
        eventChannels.remove(binding.binaryMessenger)?.setStreamHandler(null)
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        instance.context = binding.activity.applicationContext
        instance.activity = binding.activity
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            instance.mgr = instance.context?.getSystemService(EUICC_SERVICE) as EuiccManager
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {

    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        instance.context = binding.activity.applicationContext
        instance.activity = binding.activity
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            instance.mgr = instance.context?.getSystemService(EUICC_SERVICE) as EuiccManager
        }
    }

    override fun onDetachedFromActivity() {

    }


    class EventCallbackHandler : EventChannel.StreamHandler {

        private var eventSink: EventChannel.EventSink? = null

        override fun onListen(arguments: Any?, sink: EventChannel.EventSink) {
            eventSink = sink
        }

        fun send(event: String, body: Map<String, Any>) {
            val data = mapOf(
                "event" to event,
                "body" to body
            )
            Handler(Looper.getMainLooper()).post {
                eventSink?.success(data)
            }
        }

        override fun onCancel(arguments: Any?) {
            eventSink = null
        }
    }


}
