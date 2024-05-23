package com.tencent.cloud.tts.plugin.tts_plugin;

import android.app.Activity;
import android.os.Handler;
import android.os.Looper;

import androidx.annotation.NonNull;

import com.tencent.cloud.libqcloudtts.TtsController;
import com.tencent.cloud.libqcloudtts.TtsError;
import com.tencent.cloud.libqcloudtts.TtsMode;
import com.tencent.cloud.libqcloudtts.TtsResultListener;
import com.tencent.cloud.libqcloudtts.engine.offlineModule.auth.QCloudOfflineAuthInfo;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** TtsPlugin */
public class TtsPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Activity activity;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "tts_plugin");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    TtsController ttsController = TtsController.getInstance();
    if (call.method.equals("TTSController.config")) {
      String secretId = call.argument("secretId");
      String secretKey = call.argument("secretKey");
      float voiceSpeed = ((Double)call.argument("voiceSpeed")).floatValue();
      float voiceVolume = ((Double)call.argument("voiceVolume")).floatValue();
      int voiceType = call.argument("voiceType");
      int voiceLanguage = call.argument("voiceLanguage");
      String codec = call.argument("codec");
      int connectTimeout = call.argument("connectTimeout");
      int readTimeout = call.argument("readTimeout");
      ttsController.setSecretId(secretId);
      ttsController.setSecretKey(secretKey);
      ttsController.setOnlineVoiceSpeed(voiceSpeed);
      ttsController.setOnlineVoiceVolume(voiceVolume);
      ttsController.setOnlineVoiceType(voiceType);
      ttsController.setOnlineVoiceLanguage(voiceLanguage);
      ttsController.setOnlineCodec(codec);
      ttsController.setConnectTimeout(connectTimeout);
      ttsController.setReadTimeout(readTimeout);
    }
    else if (call.method.equals("TTSController.init")) {
      ttsController.init(activity.getApplicationContext(), TtsMode.ONLINE, new TtsResultListener() {
        @Override
        public void onSynthesizeData(byte[] bytes, String s, String s1, int i) {
          new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
              Map args = new HashMap();
              args.put("data", bytes);
              args.put("text", s1);
              args.put("utteranceId", s);
              channel.invokeMethod("onSynthesizeData", args);
            }
          });
        }

        @Override
        public void onError(TtsError ttsError, String s, String s1) {
          new Handler(Looper.getMainLooper()).post(new Runnable() {
            @Override
            public void run() {
              Map args = new HashMap();
              args.put("code", ttsError.getCode());
              args.put("message", ttsError.getMessage());
              if(ttsError.getServiceError() != null){
                args.put("serverMessage", ttsError.getServiceError().getResponse());
              }
              channel.invokeMethod("onError", args);
            }
          });
        }

        @Override
        public void onOfflineAuthInfo(QCloudOfflineAuthInfo qCloudOfflineAuthInfo) { }
      });
      result.success(null);
    }
    else if (call.method.equals("TTSController.synthesize")) {
      String text = call.argument("text");
      String utteranceId = call.argument("utteranceId");
      ttsController.synthesize(text, utteranceId);
      result.success(null);
    }
    else if (call.method.equals("TTSController.release")) {
      TtsController.release();
      result.success(null);
    }
    else if (call.method.equals("TTSController.cancel")) {
      ttsController.cancel();
      result.success(null);
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    activity = null;
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivity() {
    activity = null;
  }
}
