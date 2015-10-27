//
//  ConvertMedia.m
//  myPushApp
//
//  Created by LEIBI on 10/27/15.
//
//

#import "ConvertMedia.h"

@implementation ConvertMedia

- (void)startRecord:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to start record!");
}

- (void)stopRecord:(CDVInvokedUrlCommand *)command {
    NSLog(@"begin to stop record!");
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

@end