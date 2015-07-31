//
//  ConvertMedia.m
//  myPushApp
//
//  Created by LEIBI on 7/22/15.
//
//

#import "ConvertMedia.h"

@implementation CDVConvertMedia

-(void) wmaToAmr: (CDVInvokedUrlCommand*) command
{
    NSlog(@"This is wma to amr plugin!");
}

-(void) amrToWma: (CDVInvokedUrlCommand*) command
{
    NSlog(@"This is amr to wma plugin!");
}

@end
