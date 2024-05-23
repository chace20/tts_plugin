// import 'dart:io';
// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:opus_dart/opus_dart.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:tts_plugin/tts_plugin.dart';
// import 'package:tts_plugin_example/config.dart';
// import 'package:tts_plugin_example/models/common.dart';
//
// class RealTTSView extends StatefulWidget {
//   const RealTTSView({super.key});
//
//   @override
//   State<RealTTSView> createState() => _RealTTSViewState();
// }
//
// class _RealTTSViewState extends State<RealTTSView> {
//   final List<VoiceType> _voices = [
//     VoiceType(1001, '智瑜(女)'),
//     VoiceType(101001, "智瑜(精品-女)"),
//     VoiceType(1002, "智聆(女)"),
//     VoiceType(101002, "智聆(精品-女)"),
//     VoiceType(1004, "智云(男)"),
//     VoiceType(101004, "智云(精品-男)"),
//     VoiceType(1005, "智莉(女)"),
//     VoiceType(101005, "智莉(精品-女)"),
//     VoiceType(101003, "智美(精品-女)"),
//     VoiceType(1007, "智娜(女)"),
//     VoiceType(101007, "智娜(精品-女)"),
//     VoiceType(101006, "智言(精品-女)"),
//     VoiceType(101014, "智宁(精品-男)"),
//     VoiceType(101016, "智甜(精品-女)"),
//     VoiceType(1017, "智蓉(女)"),
//     VoiceType(101017, "智蓉(精品-女)"),
//     VoiceType(1008, "智琪(女)"),
//     VoiceType(101008, "智琪(精品-女)"),
//     VoiceType(10510000, "智逍遥(男)"),
//   ];
//
//   final List<LanguageType> _languages = [
//     LanguageType(1, '中文'),
//     LanguageType(2, '英文'),
//   ];
//
//   final List<CodecType> _codecs = [
//     CodecType("opus", 'opus'),
//     CodecType("pcm", 'pcm'),
//     CodecType("mp3", 'mp3'),
//   ];
//
//   final _config = RealTimeTTSControllerConfig();
//   final _textController = TextEditingController();
//   String _text = "腾讯云语音合成技术可以将任意文本转化为语音，实现让机器和应用张口说话。";
//   int _state = 0;
//   var _synthesize_file_path = "";
//   var _result = "";
//
//   @override
//   void initState() {
//     super.initState();
//     _textController.text = _text;
//     _config.appId = appId;
//     _config.secretId = secretId;
//     _config.secretKey = secretKey;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//         home: Scaffold(
//             appBar: AppBar(
//               title: const Text('RealTTS'),
//               leading: BackButton(onPressed: () {
//                 Navigator.pop(context);
//               }),
//             ),
//             body: Listener(
//               onPointerDown: (evt) {
//                 FocusManager.instance.primaryFocus?.unfocus();
//               },
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ExpansionTile(
//                       title: const Text('设置'),
//                       children: [
//                         Row(
//                           children: [
//                             const Expanded(child: Text('音色')),
//                             DropdownButton(
//                                 value: _config.voiceType,
//                                 items: _voices.map<DropdownMenuItem>((e) {
//                                   return DropdownMenuItem(
//                                     value: e.id,
//                                     child: Text(e.label),
//                                   );
//                                 }).toList(),
//                                 onChanged: (e) {
//                                   setState(() {
//                                     _config.voiceType = e;
//                                   });
//                                 })
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             const Expanded(child: Text('编码')),
//                             DropdownButton(
//                                 value: _config.codec,
//                                 items: _codecs.map<DropdownMenuItem>((e) {
//                                   return DropdownMenuItem(
//                                     value: e.value,
//                                     child: Text(e.label),
//                                   );
//                                 }).toList(),
//                                 onChanged: (e) {
//                                   setState(() {
//                                     _config.codec = e;
//                                   });
//                                 })
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             const Expanded(child: Text('倍速')),
//                             Slider(
//                                 value: _config.speed.toDouble(),
//                                 label: '${_config.speed}',
//                                 max: 2,
//                                 min: -2,
//                                 divisions: 40,
//                                 onChanged: (e) {
//                                   setState(() {
//                                     _config.speed =
//                                         (e * 10).roundToDouble() / 10;
//                                   });
//                                 })
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             const Expanded(child: Text('音量')),
//                             Slider(
//                                 value: _config.volume.toDouble(),
//                                 label: '${_config.volume}',
//                                 max: 10,
//                                 min: 0,
//                                 divisions: 10,
//                                 onChanged: (e) {
//                                   setState(() {
//                                     _config.volume =
//                                         (e * 10).roundToDouble() / 10;
//                                   });
//                                 })
//                           ],
//                         ),
//                       ],
//                     ),
//                     const ListTile(title: Text('合成文本')),
//                     TextField(
//                         onChanged: (String text) async {
//                           _text = text;
//                         },
//                         controller: _textController,
//                         keyboardType: TextInputType.multiline,
//                         maxLines: null),
//                     Row(children: [
//                       ElevatedButton(
//                           onPressed: _state == 0
//                               ? () async {
//                                   setState(() {
//                                     _state = 1;
//                                     _result = "合成中...";
//                                   });
//                                   var tts = _config.build();
//                                   var is_opus = _config.codec == "opus";
//                                   var sample_rate = _config.sampleRate;
//                                   final dir = await getTemporaryDirectory();
//                                   var file = File(
//                                       "${dir.path}/tmp_${DateTime.now().millisecondsSinceEpoch}_${_config.voiceType}.${_config.codec == "opus" ? "pcm" : _config.codec}");
//                                   try {
//                                     Stream<Uint8List> stream;
//                                     if (is_opus) {
//                                       stream = tts
//                                           .synthesize(_text)
//                                           .map((event) => event.data)
//                                           .cast<Uint8List?>()
//                                           .transform(StreamOpusDecoder.bytes(
//                                               floatOutput: false,
//                                               sampleRate: sample_rate,
//                                               channels: 1))
//                                           .cast<Uint8List>();
//                                     } else {
//                                       stream = tts
//                                           .synthesize(_text)
//                                           .map((event) => event.data);
//                                     }
//                                     await for (final val in stream) {
//                                       file.writeAsBytesSync(val,
//                                           mode: FileMode.append, flush: true);
//                                     }
//                                     setState(() {
//                                       _synthesize_file_path =
//                                           file.absolute.path;
//                                       _result = "合成成功";
//                                     });
//                                   } catch (e) {
//                                     setState(() {
//                                       _result = e.toString();
//                                     });
//                                   } finally {
//                                     setState(() {
//                                       _state = 0;
//                                     });
//                                   }
//                                 }
//                               : null,
//                           child: const Text("合成")),
//                       const SizedBox(width: 10),
//                       const SizedBox(
//                         width: 10,
//                       ),
//                       ElevatedButton(
//                           onPressed: _state == 0 && _synthesize_file_path != ""
//                               ? () async {
//                                   await Share.shareFiles(
//                                       [_synthesize_file_path]);
//                                 }
//                               : null,
//                           child: const Text('分享'))
//                     ]),
//                     ListTile(title: Text('信息: $_result'))
//                   ],
//                 ),
//               ),
//             )));
//   }
// }
