//
//  AQTaskNumberToBusy.m
//  Thermopylae
//
//  Created by Albert Martin on 8/23/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "AQTaskNumberToBusy.h"

@implementation AQTaskNumberToBusy

+ (Class)transformedValueClass
{
    return [NSNumber class];
}

- (id)transformedValue:(id)value
{
    if (value == nil) return nil;
    
    if ([value intValue] >= 1) {
        return [NSNumber numberWithBool: YES];
    } else {
        return [NSNumber numberWithBool: NO];
    }
}

@end
