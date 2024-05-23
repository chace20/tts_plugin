import 'dart:async';
// import 'dart:collection';
// import 'dart:convert';
// import 'dart:typed_data';

import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http;
// import 'package:uuid/uuid.dart';
// import 'package:crypto/crypto.dart';

class TTSData {
  Uint8List data; //音频数据
  String text; //合成文本
  String? utteranceId; //合成传入标识
  TTSData(this.data, this.text, this.utteranceId);
}

class TTSError implements Exception {
  int code = 0; // 错误码
  String message = ""; // 错误信息
  String? serverMessage; // 服务端错误信息
}

class TTSControllerConfig {
  String secretId = ""; // 腾讯云 secretId
  String secretKey = ""; //腾讯云 secretKey
  double voiceSpeed = 0; // 语速,详情见API文档
  double voiceVolume = 1; // 音量,详情见API文档
  int voiceType = 1001; // 音色,详情见API文档
  int voiceLanguage = 1; // 语音,详情见API文档
  String codec = "mp3"; // 编码,详情见API文档
  int connectTimeout = 15 * 1000; //连接超时，范围：[500,30000]，单位ms，默认15000ms
  int readTimeout = 30 * 1000; //读取超时，范围：[2200,60000]，单位ms ，默认30000ms

  Map toMap() {
    return {
      "secretId": secretId,
      "secretKey": secretKey,
      "voiceSpeed": voiceSpeed,
      "voiceVolume": voiceVolume,
      "voiceType": voiceType,
      "voiceLanguage": voiceLanguage,
      "codec": codec,
      "connectTimeout": connectTimeout,
      "readTimeout": readTimeout
    };
  }
}

class TTSController {
  final MethodChannel _methodChannel = const MethodChannel('tts_plugin');
  final StreamController<TTSData> _streamCtl =
      StreamController<TTSData>.broadcast();

  set config(TTSControllerConfig config) {
    _methodChannel.invokeMethod("TTSController.config", config.toMap());
  }

  Stream<TTSData> get listener {
    return _streamCtl.stream;
  }

  static TTSController instance = TTSController();

  TTSController() {
    _methodChannel.setMethodCallHandler((call) async {
      if (call.method == "onSynthesizeData") {
        var data = call.arguments["data"];
        var text = call.arguments["text"];
        var utteranceId = call.arguments["utteranceId"];
        _streamCtl.add(TTSData(data, text, utteranceId));
      } else if (call.method == "onError") {
        var ttsError = TTSError();
        var info = Map<String, dynamic>.from(call.arguments as Map);
        ttsError.code = call.arguments["code"];
        ttsError.message = call.arguments["message"];
        if (info.containsKey("serverMessage")) {
          ttsError.serverMessage = info['serverMessage'];
        }
        _streamCtl.addError(ttsError);
        _streamCtl.add(TTSData(Uint8List(0), "", ""));
      }
    });
  }

  synthesize(String text, String? utteranceId) async {
    await _methodChannel.invokeMethod("TTSController.init", null);
    await _methodChannel.invokeMethod("TTSController.synthesize", {
      "text": text,
      "utteranceId": utteranceId,
    });
  }

  cancel() async {
    await _methodChannel.invokeMethod("TTSController.cancel", null);
  }

  release() async {
    await _methodChannel.invokeMethod("TTSController.release");
  }
}

// class RealTimeTTSData {
//   Uint8List data;
//   RealTimeTTSData(this.data);
// }

// class RealTimeTTSError {
//   int code;
//   String message;
//   RealTimeTTSError(this.code, this.message);
// }

// class RealTimeTTSControllerConfig {
//   String get action => "TextToStreamAudio";
//   int get modelType => 1;
//   int get primaryLanguage => 1;
//   int get sampleRate => 16000;

//   int appId = 0;
//   String secretId = "";
//   String secretKey = "";
//   String text = "";
//   num volume = 0;
//   num speed = 0;
//   int projectId = 0;
//   int voiceType = 1001;
//   String codec = "mp3";
//   int segmentRate = 0;

//   RealTimeTTSController build() {
//     return RealTimeTTSController(this);
//   }
// }

// class RealTimeTTSController {
//   static var server_url = 'tts.cloud.tencent.com';
//   static var server_path = 'stream';

//   RealTimeTTSControllerConfig _config;

//   RealTimeTTSController(this._config);

//   String _genSignature(Map<String, dynamic> params) {
//     var sortedparams = SplayTreeMap.from(params);
//     var concatparams = sortedparams.keys.map((key) {
//       return '$key=${sortedparams[key]}';
//     }).join('&');
//     concatparams = 'POST$server_url/$server_path?$concatparams';
//     var hmac = Hmac(sha1, utf8.encode(_config.secretKey));
//     return base64Encode(hmac.convert(utf8.encode(concatparams)).bytes);
//   }

//   Stream<RealTimeTTSData> synthesize(String text) async* {
//     var is_opus = _config.codec == "opus";
//     Map<String, dynamic> params = {
//       "Action": _config.action,
//       "AppId": _config.appId,
//       "SecretId": _config.secretId,
//       "Timestamp": DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       "Expired": DateTime.now()
//               .add(const Duration(seconds: 3600))
//               .millisecondsSinceEpoch ~/
//           1000,
//       "Text": text,
//       "SessionId": Uuid().v1(),
//       "ModelType": _config.modelType,
//       "Volume": _config.volume,
//       "Speed": _config.speed,
//       "ProjectId": _config.projectId,
//       "VoiceType": _config.voiceType,
//       "PrimaryLanguage": _config.primaryLanguage,
//       "SampleRate": _config.sampleRate,
//       "Codec": _config.codec,
//       "SegmentRate": _config.segmentRate,
//     };
//     String signature = _genSignature(params);
//     String body = json.encode(params);
//     var url = Uri.https(server_url, server_path);
//     var request = http.Request("POST", url);
//     request.headers.addEntries({
//       "Content-Type": "application/json",
//       "Authorization": signature,
//     }.entries);
//     request.body = body;
//     var stream_resp = await request.send();
//     if (stream_resp.headers["content-type"] != "application/octet-stream") {
//       var resp = await http.Response.fromStream(stream_resp);
//       throw RealTimeTTSError(-1, resp.body);
//     }
//     int len = 0;
//     int index = 0;
//     int state = 0;
//     Uint8List tmp_data = Uint8List(0);
//     List<int> remain = [];
//     await for (final val in stream_resp.stream) {
//       if (is_opus) {
//         int cur = 0;
//         remain.addAll(val);
//         while (true) {
//           if (state == 0) {
//             if (cur + 12 > remain.length) {
//               remain = remain.sublist(cur);
//               break;
//             }
//             var opus_str = utf8.decode(remain.sublist(cur, cur + 4));
//             if (opus_str != "opus") {
//               var error = TTSError();
//               error.code = -1;
//               error.message = "Except opus,but get $opus_str";
//               throw error;
//             }
//             var bytedata = ByteData.view(
//                 Uint8List.fromList(remain.sublist(cur + 4, cur + 12)).buffer);
//             len = bytedata.getInt32(4, Endian.little);
//             index = bytedata.getInt32(0);
//             cur += 12;
//             state = 1;
//           } else if (state == 1) {
//             if (cur + len > remain.length) {
//               remain = remain.sublist(cur);
//               break;
//             }
//             var base64_str = utf8.decode(remain.sublist(cur, len + cur));
//             cur += len;
//             tmp_data = const Base64Decoder().convert(base64_str);
//             yield RealTimeTTSData(tmp_data);
//             state = 0;
//           }
//         }
//       } else {
//         yield RealTimeTTSData(Uint8List.fromList(val));
//       }
//     }
//     return;
//   }
// }
