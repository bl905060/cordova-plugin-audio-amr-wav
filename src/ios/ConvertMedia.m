//
//  ConvertMedia.m
//  myPushApp
//
//  Created by LEIBI on 10/27/15.
//
//

#import "KVNProgress.h"
#import "VoiceConverter.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ConvertMedia.h"

@implementation ConvertMedia

- (void)startRecord:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to start record!");
    [KVNProgress showWithStatus:@"正在录音"];
    
    self.recordFileName = [self GetCurrentTimeString];
    //获取路径
    self.recordFilePath = [self GetPathByFileName:self.recordFileName ofType:@"wav"];
    NSLog(@"%@", self.recordFilePath);
    
    //初始化录音
    self.recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:self.recordFilePath]
                                               settings:[VoiceConverter GetAudioRecorderSettingDict]
                                                  error:nil];
    
    //准备录音
    if ([self.recorder prepareToRecord]) {
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayAndRecord error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        //开始录音
        [self.recorder record];
    }
}

- (void)stopRecord:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to stop record!");
    
    NSString *callbackID = [command callbackId];
    
    if (self.recorder.isRecording){//录音中
        //停止录音
        [self.recorder stop];
        [KVNProgress showSuccessWithStatus:@"录音完成"];
        
        //开始转换格式
        NSString *amrPath = [self GetPathByFileName:self.recordFileName ofType:@"amr"];
        
        self.player = [self.player initWithContentsOfURL:[NSURL URLWithString:self.recordFilePath] error:nil];
        
#pragma wav转amr
        [VoiceConverter ConvertWavToAmr:self.recordFilePath amrSavePath:amrPath];
    }
}

- (void)playAudio:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to play audio file!");
}

- (void)convertToAmr:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to convert audio to amr");
}

- (void)convertToWav:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to convert audio to wav");
}

#pragma mark - 生成当前时间字符串
- (NSString*)GetCurrentTimeString{
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
}

#pragma mark - 生成文件路径
- (NSString*)GetPathByFileName:(NSString *)_fileName ofType:(NSString *)_type {
    NSFileManager *filePath = [NSFileManager defaultManager];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    directory = [directory stringByAppendingString:@"/audio"];
    
    if (![filePath fileExistsAtPath:directory]) {
        [filePath createDirectoryAtPath:directory
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:nil];
    }
    
    NSString *fileDirectory = [[[directory stringByAppendingPathComponent:_fileName]
                                stringByAppendingPathExtension:_type]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return fileDirectory;
}

#pragma mark - 获取音频文件信息
- (NSString *)getVoiceFileInfoByPath:(NSString *)aFilePath convertTime:(NSTimeInterval)aConTime{
    
    NSInteger size = [self getFileSize:aFilePath]/1024;
    NSString *info = [NSString stringWithFormat:@"文件名:%@\n文件大小:%ldkb\n",aFilePath.lastPathComponent,(long)size];
    
    NSRange range = [aFilePath rangeOfString:@"wav"];
    if (range.length > 0) {
        AVAudioPlayer *play = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:aFilePath] error:nil];
        info = [info stringByAppendingFormat:@"文件时长:%f\n",play.duration];
    }
    
    if (aConTime > 0)
        info = [info stringByAppendingFormat:@"转换时间:%f",aConTime];
    return info;
}

#pragma mark - 获取文件大小
- (NSInteger) getFileSize:(NSString*) path{
    NSFileManager * filemanager = [[NSFileManager alloc]init];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else{
        return -1;
    }
}
@end