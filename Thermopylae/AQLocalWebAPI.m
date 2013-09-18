//
//  AQLocalWebAPI.m
//  Thermopylae
//
//  Created by Albert Martin on 9/18/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "AQLocalWebAPI.h"
#import "HTTPDataResponse.h"
#import "HTTPLogging.h"
#import "JSONKit.h"

@implementation AQLocalWebAPI

- (NSObject<HTTPResponse> *)httpResponseForMethod:(NSString *)method URI:(NSString *)path
{
    NSArray *pathComponents = [path componentsSeparatedByString:@"/"];
    NSDictionary *response;
    
    response = [NSDictionary dictionaryWithObject:@"success" forKey:@"thermopylae"];

    return [[HTTPDataResponse alloc] initWithData:[response JSONData]];
}

@end
