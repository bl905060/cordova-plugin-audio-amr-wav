//
//  ConvertMedia.m
//  myPushApp
//
//  Created by LEIBI on 7/22/15.
//
//

#import "ConvertMedia.h"

//-(void) wmaToAmr: (CDVInvokedUrlCommand*) command
//{
//    NSlog(@"This is wma to amr plugin!");
//}
//
//-(void) amrToWma: (CDVInvokedUrlCommand*) command
//{
//    NSlog(@"This is amr to wma plugin!");
//}


@implementation ConvertMedia

- (void) greet:(CDVInvokedUrlCommand*)command
{
    
    NSString* callbackId = [command callbackId];
    NSString* name = [[command arguments] objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat: @"Hello, %@", name];
    
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus:CDVCommandStatus_OK
                               messageAsString:msg];
    
    NSLog(@"this is my first plugin!");
    
    [self success:result callbackId:callbackId];
}

@end