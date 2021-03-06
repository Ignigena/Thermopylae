//
//  AQLocalWebAPI.m
//  Thermopylae
//
//  Created by Albert Martin on 9/18/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "AQLocalWebAPI.h"
#import "HTTPErrorResponse.h"
#import "HTTPDataResponse.h"
#import "HTTPLogging.h"
#import "JSONKit.h"
#import "AQAppDelegate.h"
#import "AQCustomer.h"

@implementation AQLocalWebAPI

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
    
    if ([[pathComponents objectAtIndex:1] isEqualToString: @"favicon.ico"] || [[pathComponents objectAtIndex:1] isEqualToString: @"ACQUIA_MONITOR"]) {
        return [[HTTPErrorResponse alloc] initWithErrorCode:404];
    }
    
    NSMutableDictionary *response;
    
    response = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"thermopylae"];

    if (![[pathComponents objectAtIndex:1] isEqualToString: @""]) {
        if (![[[(AQAppDelegate *)[[NSApplication sharedApplication] delegate] customerData] sitename] isEqualToString: [pathComponents objectAtIndex:1]]) {
            [(AQAppDelegate *)[[NSApplication sharedApplication] delegate] loadCustomerDataForCustomer: [pathComponents objectAtIndex:1]];
        }
        [response setObject:[pathComponents objectAtIndex:1] forKey:@"subscription"];
        
        while ([[(AQAppDelegate *)[[NSApplication sharedApplication] delegate] customerData] tasks] != 0) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        }
        
        NSMutableDictionary *environment = [[NSMutableDictionary alloc] initWithDictionary:[[(AQAppDelegate *)[[NSApplication sharedApplication] delegate] customerData] environment]];
        NSDictionary *contacts = [[(AQAppDelegate *)[[NSApplication sharedApplication] delegate] customerData] contacts];
        [environment setObject:contacts forKey:@"contacts"];
        if (environment) {
            [response setObject:environment forKey:@"response"];
        } else {
            [response setObject:[NSNumber numberWithBool:NO] forKey:@"thermopylae"];
        }
    }

    return [[HTTPDataResponse alloc] initWithData:[response JSONData]];
}

@end
