//
//  ConvertMedia.h
//  myPushApp
//
//  Created by LEIBI on 10/27/15.
//
//

#import <Cordova/CDV.h>

@interface ConvertMedia : CDVPlugin

- (void)startRecord:(CDVInvokedUrlCommand*)command;
- (void)stopRecord:(CDVInvokedUrlCommand*)command;
- (void)playAudio:(CDVInvokedUrlCommand*)command;

- (void)convertToAmr:(CDVInvokedUrlCommand*)command;
- (void)convertToWav:(CDVInvokedUrlCommand*)command;

@end