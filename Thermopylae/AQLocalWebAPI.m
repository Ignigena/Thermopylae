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
    
    response = [NSMutableDictionary dictionaryWithObject:@"success" forKey:@"thermopylae"];

    if (![[pathComponents objectAtIndex:1] isEqualToString: @""]) {
        if (![[[(AQAppDelegate *)[[NSApplication sharedApplication] delegate] customerData] sitename] isEqualToString: [pathComponents objectAtIndex:1]]) {
            [(AQAppDelegate *)[[NSApplication sharedApplication] delegate] loadCustomerDataForCustomer: [pathComponents objectAtIndex:1]];
        }
        [response setObject:[pathComponents objectAtIndex:1] forKey:@"subscription"];
        
        while ([[(AQAppDelegate *)[[NSApplication sharedApplication] delegate] customerData] tasks] != 0) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
        }
        
        [response setObject:[[(AQAppDelegate *)[[NSApplication sharedApplication] delegate] customerData] environment] forKey:@"response"];
    }

    return [[HTTPDataResponse alloc] initWithData:[response JSONData]];
}

@end
