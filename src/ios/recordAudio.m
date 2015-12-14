//
//  recordAudio.m
//  myPushApp
//
//  Created by LEIBI on 10/27/15.
//
//

#import "recordAudio.h"

@implementation recordAudio

- (void)startRecord:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to start record!");
    
    NSError *audioSessionError;
    NSError *recorderInitError;
    
    NSString *errorStr = [[NSString alloc] init];
    NSString *callbackID = [command callbackId];
    CDVPluginResult *pluginResult;
    
    operatePlist *readPlist = [[operatePlist alloc] init];
    generateIDCode *idcode = [[generateIDCode alloc] init];
    NSString *userID = [[NSString alloc] init];
    
    if (self.recorder.isRecording) {
        errorStr = @"recorder is alread working!";
    } else {
        NSLog(@"ready to record!");
        
        [KVNProgress showWithStatus:@"正在录音"];
        
        if ([command argumentAtIndex:0] != nil) {
            self.recordFileName = [command argumentAtIndex:0];
        }
        else {
            userID = [[readPlist read:@"userinfo"] objectForKey:@"user_id"];
            self.recordFileName = [idcode idCode:@"LY" withUserID:userID withDevID:@"" withNumber:0];
        }
        //获取路径
        self.recordFilePath = [self GetPathByFileName:self.recordFileName ofType:@"wav"];
        NSLog(@"record file path is: %@", self.recordFilePath);
        
        //初始化录音
        self.recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:self.recordFilePath]
                                                   settings:[VoiceConverter GetAudioRecorderSettingDict]
                                                      error:&recorderInitError];
        
        //准备录音
        if ([self.recorder prepareToRecord]) {
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord
                                                   error:&audioSessionError];
            [[AVAudioSession sharedInstance] setActive:YES
                                                 error:&audioSessionError];
            //开始录音
            [self.recorder record];
        }
    }
    
    if (errorStr.length > 0) {
        NSLog(@"recorder is alread working!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorStr];
    } else if (recorderInitError) {
        NSLog(@"recorder initial fail!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:[recorderInitError localizedDescription]];
    } else if (audioSessionError) {
        NSLog(@"audio session set is fail!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:[audioSessionError localizedDescription]];
    } else {
        NSLog(@"record is ok!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
}

- (void)stopRecord:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to stop record!");
    
    NSError *playerInitError;
    
    NSString *callbackID = [command callbackId];
    NSMutableDictionary *audioParam = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSString *amrPath = [[NSString alloc] init];
    NSString *errorStr = [[NSString alloc] init];
    NSString *fullPath;
    NSString *duration;
    NSString *voiceID;
    CDVPluginResult *pluginResult;
    
    if (self.recorder.isRecording) {//录音中
        //停止录音
        [self.recorder stop];
        
        //开始转换格式
        amrPath = [self GetPathByFileName:self.recordFileName ofType:@"amr"];
        
        self.player = [self.player initWithContentsOfURL:[NSURL URLWithString:self.recordFilePath]
                                                   error:&playerInitError];
        
#pragma wav转amr
        [VoiceConverter ConvertWavToAmr:self.recordFilePath amrSavePath:amrPath];
        
        attributes = [self getVoiceFileInfoByPath:self.recordFilePath];
        fullPath = [[NSString alloc] initWithFormat:@"file://%@", amrPath];
        duration = [attributes objectForKey:@"duration"];
        voiceID = [[NSString alloc] initWithString:self.recordFileName];
        NSLog(@"fullPath: %@", fullPath);
        NSLog(@"duration: %@", duration);
        NSLog(@"voiceID: %@", voiceID);
        
        NSString *progressStatus = [[NSString alloc] initWithFormat:@"录音时长为%@秒", duration];
        [KVNProgress showSuccessWithStatus: progressStatus];
        
        [audioParam setObject:fullPath forKey:@"fullPath"];
        [audioParam setObject:duration forKey:@"duration"];
        [audioParam setObject:voiceID forKey:@"voiceID"];
    } else {
        errorStr = @"recorder is not working!";
    }
    
    if (errorStr.length > 0) {
        NSLog(@"recorder is not working!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorStr];
    } else if (playerInitError) {
        NSLog(@"player initial fail!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:[playerInitError localizedDescription]];
    } else {
        NSLog(@"recoder is stoped!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsDictionary:audioParam];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
}

- (void)playAudio:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to play audio file!");
    
    NSError *audioSessionError;
    NSError *playerInitError;
    
    NSFileManager *file = [NSFileManager defaultManager];
    NSMutableString *fileURL;
    NSMutableString *wavFilePath;
    CDVPluginResult *pluginResult;
    NSString *callbackID = [command callbackId];
    NSString *errorStr = [[NSString alloc] init];
    
    if ([[[command arguments] objectAtIndex:0] isKindOfClass:[NSString class]]) {
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
            
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                                   error:&audioSessionError];
            [[AVAudioSession sharedInstance] setActive:YES
                                                 error:&audioSessionError];
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:fileURL]
                                                                 error:&playerInitError];
            NSLog(@"audio file URL: %@", fileURL);
            [self.player play];
        } else if (wavRange.length > 0) {
            [fileURL deleteCharactersInRange:NSMakeRange(0, 7)];
            
            if ([file fileExistsAtPath:fileURL]) {
                [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                                       error:&audioSessionError];
                [[AVAudioSession sharedInstance] setActive:YES
                                                     error:&audioSessionError];
                self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:fileURL]
                                                                     error:&playerInitError];
                NSLog(@"%@", fileURL);
                [self.player play];
            } else {
                errorStr = @"file is not exist!";
            }
        } else {
            errorStr = @"file URL is wrong!";
        }
    } else {
        errorStr = @"audio URL must be a string variable!";
    }
    
    if (errorStr.length > 0) {
        NSLog(@"errorStr: %@", errorStr);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:errorStr];
    } else if (audioSessionError) {
        NSLog(@"audio session set is fail!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:[audioSessionError localizedDescription]];
    } else if (playerInitError) {
        NSLog(@"player initial fail!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:[playerInitError localizedDescription]];
    } else {
        NSLog(@"play audio is OK!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
}

- (void)convertToAmr:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to convert audio to amr");
    
    NSString *callbackID = [command callbackId];
    NSString *errorStr = [[NSString alloc] init];
    NSFileManager *file = [NSFileManager defaultManager];
    NSMutableDictionary *audioParam = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSMutableString *amrFilePath;
    NSMutableString *amrFileName;
    NSMutableString *fileURL;
    CDVPluginResult *pluginResult;
    NSString *fullPath;
    NSString *duration;
    NSString *voiceID;
    
    if ([[[command arguments] objectAtIndex:0] isKindOfClass:[NSString class]]) {
        fileURL = [[NSMutableString alloc] initWithString:[[command arguments] objectAtIndex:0]];
        NSRange amrRange = [fileURL rangeOfString:@"wav"];
        if ((amrRange.length > 0) & [fileURL hasPrefix:@"file://"]) {
            [fileURL deleteCharactersInRange:NSMakeRange(0, 7)];
            amrFilePath = [[NSMutableString alloc] initWithString:[fileURL stringByReplacingOccurrencesOfString:@"wav" withString:@"amr"]];
            if ([file fileExistsAtPath:fileURL]) {
                [VoiceConverter ConvertWavToAmr:fileURL amrSavePath:amrFilePath];
                attributes = [self getVoiceFileInfoByPath:fileURL];
                fullPath = [[NSString alloc] initWithFormat:@"file://%@", amrFilePath];
                duration = [attributes objectForKey:@"duration"];
                amrFileName = [NSMutableString stringWithString:[amrFilePath lastPathComponent]];
                [amrFileName deleteCharactersInRange:[amrFileName rangeOfString:@".amr"]];
                voiceID = [[NSString alloc] initWithString:amrFileName];
                NSLog(@"fullPath: %@", fullPath);
                NSLog(@"duration: %@", duration);
                NSLog(@"voiceID: %@", voiceID);
                
                [audioParam setObject:fullPath forKey:@"fullPath"];
                [audioParam setObject:duration forKey:@"duration"];
                [audioParam setObject:voiceID forKey:@"voiceID"];
            } else {
                errorStr = @"amr file is not exist!";
            }
        } else {
            errorStr = @"file URL is wrong!";
        }
    } else {
        errorStr = @"audio URL must be a string variable!";
    }
    
    if (errorStr.length != 0) {
        NSLog(@"errorStr: %@", errorStr);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:errorStr];
    } else {
        NSLog(@"convert audio is OK!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsDictionary:audioParam];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
}

- (void)convertToWav:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to convert audio to wav");
    
    NSString *callbackID = [command callbackId];
    NSString *errorStr = [[NSString alloc] init];
    NSFileManager *file = [NSFileManager defaultManager];
    NSMutableDictionary *audioParam = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSMutableString *wavFilePath;
    NSMutableString *wavFileName;
    NSMutableString *fileURL;
    CDVPluginResult *pluginResult;
    NSString *fullPath;
    NSString *duration;
    NSString *voiceID;
    
    if ([[[command arguments] objectAtIndex:0] isKindOfClass:[NSString class]]) {
        fileURL = [[NSMutableString alloc] initWithString:[[command arguments] objectAtIndex:0]];
        NSRange amrRange = [fileURL rangeOfString:@"amr"];
        if ((amrRange.length > 0) & [fileURL hasPrefix:@"file://"]) {
            [fileURL deleteCharactersInRange:NSMakeRange(0, 7)];
            wavFilePath = [[NSMutableString alloc] initWithString:[fileURL stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
            if ([file fileExistsAtPath:fileURL]) {
                [VoiceConverter ConvertAmrToWav:fileURL wavSavePath:wavFilePath];
                attributes = [self getVoiceFileInfoByPath:wavFilePath];
                fullPath = [[NSString alloc] initWithFormat:@"file://%@", wavFilePath];
                duration = [attributes objectForKey:@"duration"];
                wavFileName = [NSMutableString stringWithString:[wavFilePath lastPathComponent]];
                [wavFileName deleteCharactersInRange:[wavFileName rangeOfString:@".wav"]];
                voiceID = [[NSString alloc] initWithString:wavFileName];
                NSLog(@"fullPath: %@", fullPath);
                NSLog(@"duration: %@", duration);
                NSLog(@"voiceID: %@", voiceID);
                
                [audioParam setObject:fullPath forKey:@"fullPath"];
                [audioParam setObject:duration forKey:@"duration"];
                [audioParam setObject:voiceID forKey:@"voiceID"];
            } else {
                errorStr = @"wav file is not exist!";
            }
        } else {
            errorStr = @"file URL is wrong!";
        }
    } else {
        errorStr = @"audio URL must be a string variable!";
    }
    
    if (errorStr.length != 0) {
        NSLog(@"errorStr: %@", errorStr);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR
                                         messageAsString:errorStr];
    } else {
        NSLog(@"convert audio is OK!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                     messageAsDictionary:audioParam];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
}

- (void)deleteAudio:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to delete audio file!");
    
    NSString *callbackID = [command callbackId];
    NSString *errorStr = [[NSString alloc] init];
    NSFileManager * file = [NSFileManager defaultManager];
    NSMutableString *wavFilePath;
    NSMutableString *fileURL;
    CDVPluginResult *pluginResult;
    NSError * error;
    
    fileURL = [[NSMutableString alloc] initWithString:[[command arguments] objectAtIndex:0]];
    NSRange amrRange = [fileURL rangeOfString:@"amr"];
    NSRange wavRange = [fileURL rangeOfString:@"wav"];
    if ((amrRange.length > 0) & [fileURL hasPrefix:@"file://"]) {
        [fileURL deleteCharactersInRange:NSMakeRange(0, 7)];
        wavFilePath = [[NSMutableString alloc] initWithString:[fileURL stringByReplacingOccurrencesOfString:@"amr" withString:@"wav"]];
        if ([file fileExistsAtPath:fileURL]) {
            [file removeItemAtPath:fileURL error:&error];
            if ([file fileExistsAtPath:wavFilePath]) {
                [file removeItemAtPath:wavFilePath error:&error];
            } else {
                NSLog(@"amr was deleted, but wav file is not exist!");
            }
        } else {
            errorStr = @"amr file is not exist!";
        }
    } else if ((wavRange.length > 0) & [fileURL hasPrefix:@"file://"]) {
        [fileURL deleteCharactersInRange:NSMakeRange(0, 7)];
        if ([file fileExistsAtPath:fileURL]) {
            [file removeItemAtPath:fileURL error:&error];
        } else {
            errorStr = @"wav file is not exist!";
        }
    } else {
        errorStr = @"file URL is wrong!";
    }
    
    if (errorStr.length != 0) {
        NSLog(@"errorStr: %@", errorStr);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:errorStr];
    } else if (error) {
        NSLog(@"error description: %@", [error localizedDescription]);
        NSLog(@"error failure reason: %@", [error localizedFailureReason]);
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:[error localizedDescription]];
    } else {
        NSLog(@"delete audio is OK!");
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackID];
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