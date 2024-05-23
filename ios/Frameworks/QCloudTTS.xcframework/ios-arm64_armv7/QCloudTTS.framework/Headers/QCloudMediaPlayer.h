//
//  QCloudMediaPlayer.h
//  cloud-tts-sdk-ios
//
//  Created by renqiu on 2022/1/11.
//

#import <Foundation/Foundation.h>
#import <QCloudTTS/QCPlayerError.h>

@protocol QCloudPlayerDelegate <NSObject>
//播放开始
-(void) onTTSPlayStart;

//队列所有音频播放完成，音频等待中
-(void) onTTSPlayWait;

//恢复播放
-(void) onTTSPlayResume;

//暂停播放
-(void) onTTSPlayPause;

//播放中止
-(void)onTTSPlayStop;

//即将播放播放下一句，即将播放音频对应的句子，以及这句话utteranceId
/// 即将播放播放下一句，即将播放音频对应的句子，以及这句话utteranceId
/// @param text 当前播放句子的文本
/// @param utteranceId 当前播放音频对应的ID
-(void) onTTSPlayNextWithText:(NSString* _Nullable)text UtteranceId:(NSString* _Nullable)utteranceId;



//播放器异常
-(void)onTTSPlayError:(QCPlayerError* _Nullable)playError;

/// 当前播放的字符,当前播放的字符在所在的句子中的下标.
/// @param currentWord 当前读到的单个字，是一个估算值不一定准确
/// @param currentIdex 当前播放句子中读到文字的下标
-(void)onTTSPlayProgressWithCurrentWord:(NSString*_Nullable)currentWord CurrentIndex:(NSInteger)currentIdex;


@end
/// <#Description#>
@interface QCloudMediaPlayer : NSObject
@property (assign,nonnull)id <QCloudPlayerDelegate>playerDelegate;
//
/// 数据入队列
/// @param data 加入队列的音频
/// @param text 音频对应的文本
/// @param utteranceId 音频对应的ID
-(void)enqueueWithData:(NSData* _Nonnull )data Text:(NSString* _Nullable)text UtteranceId:(NSString* _Nullable)utteranceId;
/// 数据入队列
/// @param file 加入队列的音频文件
/// @param text 音频文件对应的文本
/// @param utteranceId 音频文件对应的ID
-(void)enqueueWithFile:(NSURL* _Nullable)file Text:(NSString* _Nullable)text UtteranceId:(NSString* _Nullable)utteranceId;
//
/// 停止播放
-(QCPlayerError* _Nullable)StopPlay;
/// 暂停播放
-(QCPlayerError* _Nullable)PausePlay;
/// 恢复播放
-(QCPlayerError* _Nullable)ResumePlay;
-(NSInteger)getAudioQueueSize;

@end


@interface QCloudTTSProxy : NSProxy
- (instancetype _Nullable )initWithObjc:(id _Nullable)object;
@end

