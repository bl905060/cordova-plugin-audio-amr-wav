//
//  recordAudio.m
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

@implementation recordAudio

- (void)startRecord:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to start record!");
    
    NSError *recordError = [[NSError alloc] init];
    NSString *callbackID = [command callbackId];
    CDVPluginResult *pluginResult;
    
    if (self.recorder.isRecording) {
        NSLog(@"recorder is alread working!");
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"recorder is alread working!"];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
    } else {
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
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryRecord error:&recordError];
            [[AVAudioSession sharedInstance] setActive:YES error:&recordError];
            //开始录音
            [self.recorder record];
            
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
        }
    }
}

- (void)stopRecord:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to stop record!");
    
    NSString *callbackID = [command callbackId];
    NSMutableDictionary *audioParam = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSString *amrPath = [[NSString alloc] init];
    NSString *fullPath;
    NSString *duration;
    NSString *voiceID;
    CDVPluginResult *pluginResult;
    
    if (self.recorder.isRecording) {//录音中
        //停止录音
        [self.recorder stop];
        [KVNProgress showSuccessWithStatus:@"录音完成"];
        
        //开始转换格式
        amrPath = [self GetPathByFileName:self.recordFileName ofType:@"amr"];
        
        self.player = [self.player initWithContentsOfURL:[NSURL URLWithString:self.recordFilePath] error:nil];
        
#pragma wav转amr
        [VoiceConverter ConvertWavToAmr:self.recordFilePath amrSavePath:amrPath];
        
        attributes = [self getVoiceFileInfoByPath:self.recordFilePath];
        fullPath = [[NSString alloc] initWithFormat:@"file://%@", amrPath];
        duration = [attributes objectForKey:@"duration"];
        voiceID = [[NSString alloc] initWithString:self.recordFileName];
        NSLog(@"fullPath: %@", fullPath);
        NSLog(@"duration: %@", duration);
        NSLog(@"voiceID: %@", voiceID);
        
        [audioParam setObject:fullPath forKey:@"fullPath"];
        [audioParam setObject:duration forKey:@"duration"];
        [audioParam setObject:voiceID forKey:@"voiceID"];
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsDictionary:audioParam];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
    } else {
        NSLog(@"recorder is not working!");
        
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:@"recorder is not working!"];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
    }
}

- (void)playAudio:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to play audio file!");
    
    NSFileManager *file = [NSFileManager defaultManager];
    NSMutableString *fileURL;
    NSMutableString *wavFilePath;
    CDVPluginResult *pluginResult;
    NSString *callbackID = [command callbackId];
    NSString *errorStr = [[NSString alloc] init];
    
    fileURL = [[NSMutableString alloc] initWithString:[[command arguments] objectAtIndex:0]];
    NSRange amrRange = [fileURL rangeOfString:@"amr"];
    NSRange wavRange = [fileURL rangeOfString:@"wav"];
    if (amrRange.length > 0) {
        [fileURL deleteCharactersInRange:NSMakeRange(0, 7)];
        wavFilePath = [[NSMutableString alloc] initWithString:[fileURL stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
        NSLog(@"audioURL: %@", fileURL);
        NSLog(@"wavFilePath: %@", wavFilePath);
        
        if ([file fileExistsAtPath:wavFilePath]) {
            fileURL = wavFilePath;
        } else {
            [VoiceConverter ConvertAmrToWav:fileURL wavSavePath:wavFilePath];
            fileURL = wavFilePath;
        }
        
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:fileURL] error:nil];
        NSLog(@"%@", fileURL);
        [self.player play];
    } else if (wavRange.length > 0) {
        [fileURL deleteCharactersInRange:NSMakeRange(0, 7)];
        
        if ([file fileExistsAtPath:fileURL]) {
            [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
            [[AVAudioSession sharedInstance] setActive:YES error:nil];
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:fileURL] error:nil];
            NSLog(@"%@", fileURL);
            [self.player play];
        } else {
            errorStr = @"file is not exist!";
        }
    } else {
        errorStr = @"file URL is wrong!";
    }
    
    if (errorStr != nil) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorStr];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
    }
}

- (void)convertToAmr:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to convert audio to amr");
    
    NSString *callbackID = [command callbackId];
    NSString *errorStr = [[NSString alloc] init];
    NSFileManager *file = [NSFileManager defaultManager];
    NSMutableString *amrFilePath;
    NSMutableString *fileURL;
    CDVPluginResult *pluginResult;
    
    fileURL = [[NSMutableString alloc] initWithString:[[command arguments] objectAtIndex:0]];
    NSRange amrRange = [fileURL rangeOfString:@"wav"];
    if (amrRange.length > 0) {
        [fileURL deleteCharactersInRange:NSMakeRange(0, 7)];
        amrFilePath = [[NSMutableString alloc] initWithString:[fileURL stringByReplacingOccurrencesOfString:@"wav" withString:@"amr"]];
        if ([file fileExistsAtPath:fileURL]) {
            [VoiceConverter ConvertWavToAmr:fileURL amrSavePath:amrFilePath];
        } else {
            errorStr = @"amr file is not exist!";
        }
    } else {
        errorStr = @"file URL is wrong!";
    }
    
    if (errorStr.length != 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorStr];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
    }
}

- (void)convertToWav:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to convert audio to wav");
    
    NSString *callbackID = [command callbackId];
    NSString *errorStr = [[NSString alloc] init];
    NSFileManager *file = [NSFileManager defaultManager];
    NSMutableString *wavFilePath;
    NSMutableString *fileURL;
    CDVPluginResult *pluginResult;
    
    fileURL = [[NSMutableString alloc] initWithString:[[command arguments] objectAtIndex:0]];
    NSRange amrRange = [fileURL rangeOfString:@"amr"];
    if (amrRange.length > 0) {
        [fileURL deleteCharactersInRange:NSMakeRange(0, 7)];
        wavFilePath = [[NSMutableString alloc] initWithString:[fileURL stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
        if ([file fileExistsAtPath:fileURL]) {
            [VoiceConverter ConvertAmrToWav:fileURL wavSavePath:wavFilePath];
        } else {
            errorStr = @"wav file is not exist!";
        }
    } else {
        errorStr = @"file URL is wrong!";
    }
    
    if (errorStr.length != 0) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorStr];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
    }
}

#pragma mark - 生成当前时间字符串
- (NSString *)GetCurrentTimeString{
    NSDateFormatter *dateformat = [[NSDateFormatter  alloc]init];
    [dateformat setDateFormat:@"yyyyMMddHHmmss"];
    return [dateformat stringFromDate:[NSDate date]];
}

#pragma mark - 生成文件路径
- (NSString *)GetPathByFileName:(NSString *)fileName ofType:(NSString *)type {
    NSFileManager *filePath = [NSFileManager defaultManager];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    
    directory = [directory stringByAppendingString:@"/audio"];
    
    if (![filePath fileExistsAtPath:directory]) {
        [filePath createDirectoryAtPath:directory
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:nil];
    }
    
    NSString *filePathStr = [[[directory stringByAppendingPathComponent:fileName]
                                stringByAppendingPathExtension:type]
                               stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return filePathStr;
}

#pragma mark - 获取音频文件信息
- (NSMutableDictionary *)getVoiceFileInfoByPath:(NSString *)filePath {
    NSFileManager *filemanager = [[NSFileManager alloc] init];
    NSMutableDictionary *attributes;
    NSString *duration;
    
    if ([filemanager fileExistsAtPath:filePath]) {
        attributes = [[NSMutableDictionary alloc] initWithDictionary:[filemanager attributesOfItemAtPath:filePath error:nil]];
    }
    
    NSRange range = [filePath rangeOfString:@"wav"];
    if (range.length > 0) {
        AVAudioPlayer *play = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:filePath] error:nil];
        duration = [[NSString alloc] initWithFormat:@"%d", (int)play.duration];
    }
    
    [attributes setObject:duration forKey:@"duration"];
    
    NSLog(@"%@", attributes);
    
    return attributes;
}
@end