//
//  AQAppDelegate.m
//  Titan
//
//  Created by Albert Martin on 7/24/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "AQAppDelegate.h"
#import "AQCustomer.h"
#import "ITSidebar.h"
#import "ITSidebarItemCell.h"
#import "HTTPServer.h"
#import "AQLocalWebAPI.h"

@implementation AQAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Initalize our http server
	httpServer = [[HTTPServer alloc] init];
	[httpServer setConnectionClass:[AQLocalWebAPI class]];
    [httpServer setType:@"_http._tcp."];
	[httpServer setPort:47051];
    [httpServer start:nil];
    
    [self.sidebar addItemWithImage:[NSImage imageNamed:@"watch-pushed"] alternateImage:[NSImage imageNamed:@"watch"] target:self action:@selector(watchClicked:)];
    [self.sidebar addItemWithImage:[NSImage imageNamed:@"push-pushed"] alternateImage:[NSImage imageNamed:@"push"] target:self action:@selector(pushClicked:)];

    self.sidebar.allowsEmptySelection = NO;
}

- (IBAction)findIt:(id)sender {
    [self.customerData clearCustomer];
    
    NSString *customerName = [self performRegex:@"^\\@(.*)" onString:[self.searchField stringValue]];
    NSString *domainName = [self performRegex:@"^[^\\@].*\\..*" onString:[self.searchField stringValue]];
    
    if (customerName) {
        [self.customerData loadCustomerBySitename: customerName];
    } else if (domainName) {
        [self.customerData findCustomerByDomain: domainName];
    }
}

- (void)loadCustomerDataForCustomer:(NSString *)customer {
    [self.searchField setStringValue:[NSString stringWithFormat:@"@%@", customer]];
    [self.customerData loadCustomerBySitename: customer];
}

- (NSString *)performRegex:(NSString *)regex onString:(NSString *)string
{
    NSError *error = NULL;
    
    NSRegularExpression *regexSearch = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:&error];
    
    NSTextCheckingResult *regexMatch = [regexSearch firstMatchInString:string
                                                                       options:0
                                                                         range:NSMakeRange(0, [string length])];
    
    if (regexMatch) {
        return [string substringWithRange:[regexMatch range]];
    } else {
        return nil;
    }
}

@end
