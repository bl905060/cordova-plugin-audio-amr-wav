//
//  ConvertMedia.h
//  myPushApp
//
//  Created by LEIBI on 7/22/15.
//
//

#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVInvokeUrlCommand.h>
#import <Foundation/Foundation.h>

@interface CDVConvertMedia : CDVPlugin

-(void) wmaToAmr: (CDVInvokedUrlCommand*) command;
-(void) amrToWma: (CDVInvokedUrlCommand*) command;


@end
