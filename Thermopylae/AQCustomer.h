//
//  AQCustomer.h
//  Thermopylae
//
//  Created by Albert Martin on 7/24/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AQCustomer : NSObject {
    NSString *sitename;
    NSString *uuid;
}

@property (nonatomic) int tasks;

@property (retain, nonatomic) NSString* sitename;
@property (retain, nonatomic) NSString* uuid;
@property (retain, nonatomic) NSString* repository;
@property (retain, nonatomic) NSString* rawHostingSetup;
@property (retain, nonatomic) NSMutableDictionary* hostingSetup;

- (void)loadCustomerBySitename:(NSString *)site;
- (void)findCustomerByDomain:(NSString *)domain;
- (void)clearCustomer;

- (IBAction)loadSubscription:(id)sender;

@end
