//
//  recordAudio.h
//  myPushApp
//
//  Created by LEIBI on 10/27/15.
//
//

#import <Cordova/CDV.h>

@interface recordAudio : CDVPlugin

- (void)startRecord:(CDVInvokedUrlCommand*)command;
- (void)stopRecord:(CDVInvokedUrlCommand*)command;
- (void)playAudio:(CDVInvokedUrlCommand*)command;

- (void)convertToAmr:(CDVInvokedUrlCommand*)command;
- (void)convertToWav:(CDVInvokedUrlCommand*)command;

@property (strong, nonatomic)   AVAudioRecorder  *recorder;
@property (strong, nonatomic)   AVAudioPlayer    *player;
@property (strong, nonatomic)   NSString         *recordFileName;
@property (strong, nonatomic)   NSString         *recordFilePath;

@end