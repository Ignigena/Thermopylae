//
//  AQCustomer.m
//  Thermopylae
//
//  Created by Albert Martin on 7/24/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "AQCustomer.h"

@implementation AQCustomer

@synthesize tasks;
@synthesize sitename;
@synthesize uuid;
@synthesize rawHostingSetup;

- (void)loadCustomerBySitename:(NSString *)site {
    self.sitename = [site stringByReplacingOccurrencesOfString:@"@" withString:@""];
    [self generateCustomerUuid];
    [self getHostedDetails];
}

- (void)findCustomerByDomain:(NSString *)domain {    
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:[[NSBundle mainBundle] pathForResource:@"aht" ofType:@""]];
    [task setArguments:[NSArray arrayWithObjects: @"fd", domain, nil]];
    task.standardOutput = [NSPipe pipe];
    
    [[task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        NSData *data = [file availableData]; // this will read to EOF, so call only once
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSRegularExpression *docrootMatch = [NSRegularExpression regularExpressionWithPattern:@"[^  ]*\\.[a-z]{3,}" options:NSRegularExpressionCaseInsensitive error:nil];
        if ([docrootMatch numberOfMatchesInString:result
                                      options:0
                                        range:NSMakeRange(0, [result length])] >= 1) {
            NSTextCheckingResult *docrootNameMatch = [docrootMatch firstMatchInString:result options:0
                                                                            range:NSMakeRange(0, [result length])];
            [self loadCustomerBySitename:[result substringWithRange:[docrootNameMatch range]]];
        }
    }];
    [task setTerminationHandler:^(NSTask *task) {
        self.tasks--;
        [task.standardOutput fileHandleForReading].readabilityHandler = nil;
        
        if (!self.sitename) {
            [self performSelectorOnMainThread:@selector(alertCustomerNotFound) withObject:nil waitUntilDone:NO];
        }
    }];
    
    [task launch];
    self.tasks++;
}

- (void)clearCustomer {
    self.sitename = nil;
    self.uuid = nil;
    self.repository = nil;
}

- (void)generateCustomerUuid {
    NSTask *task = [[NSTask alloc] init];
    
    [task setLaunchPath:[[NSBundle mainBundle] pathForResource:@"aht" ofType:@""]];
    [task setArguments:[NSArray arrayWithObjects: [NSString stringWithFormat:@"@%@", self.sitename], @"sub", nil]];
    task.standardOutput = [NSPipe pipe];
    
    [[task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        NSData *data = [file availableData];
        NSArray *uuidByUrl = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString:@"/"];
        
        if ([uuidByUrl count]>=5) {
            self.uuid = [uuidByUrl objectAtIndex:5];
        }
    }];
    
    [task setTerminationHandler:^(NSTask *task) {
        self.tasks--;
        [task.standardOutput fileHandleForReading].readabilityHandler = nil;
    }];
    
    [task launch];
    self.tasks++;
}

- (void)getHostedDetails {
    self.rawHostingSetup = @"";
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:[[NSBundle mainBundle] pathForResource:@"aht" ofType:@""]];
    [task setArguments:[NSArray arrayWithObject: [NSString stringWithFormat:@"@%@", self.sitename]]];
    task.standardOutput = [NSPipe pipe];
    [[task.standardOutput fileHandleForReading] setReadabilityHandler:^(NSFileHandle *file) {
        NSData *data = [file availableData]; // this will read to EOF, so call only once
        NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([result isEqualToString: @"Could not find sitegroup or environment.\r\n"]) {
            [self performSelectorOnMainThread:@selector(alertCustomerNotFound) withObject:nil waitUntilDone:NO];
        }
        
        NSString *gitURL = [self performRegex:@".*@svn-\\d+\\..*\\.acquia\\.com:.*\\.git" onString:result withCaptureGroup:NO];
        
        if (gitURL) {
            self.repository = gitURL;
        }
        
        NSRegularExpression *aceMatch = [NSRegularExpression regularExpressionWithPattern:@".+\\.prod.hosting.acquia.com(:|\\/)(.+)" options:NSRegularExpressionCaseInsensitive error:nil];
        if ([aceMatch numberOfMatchesInString:result
                                      options:0
                                        range:NSMakeRange(0, [result length])] >= 1) {
            NSLog(@"Customer is ACE!");
        }
        self.rawHostingSetup = [self.rawHostingSetup stringByAppendingString:result];
    }];
    
    [task setTerminationHandler:^(NSTask *task) {
        [self processHostingSetupResponse];
        [task.standardOutput fileHandleForReading].readabilityHandler = nil;
    }];
    
    [task launch];
    self.tasks++;
}

- (IBAction)loadSubscription:(id)sender {
    NSString *urlToOpen;
    
    if ([[sender title] isEqualToString:@"Subscription"]) {
        urlToOpen = [NSString stringWithFormat:@"https://insight.acquia.com/node/uuid/%@/cloud", self.uuid];
    } else if ([[sender title] isEqualToString:@"CCI"]) {
        urlToOpen = [NSString stringWithFormat:@"https://cci.acquia.com/cci_sub_bounce/%@", self.uuid];
    }
    
    if (![urlToOpen isEqualToString:@""]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:urlToOpen]];
    }
}

- (void)processHostingSetupResponse
{
    self.hostingSetup = [[NSMutableDictionary alloc] init];
    NSArray *hostingSetupSplit = [self.rawHostingSetup componentsSeparatedByString:@"\r\n\r\n"];
    for (NSString *object in hostingSetupSplit) {
        NSString *isEnvironment = [self performRegex:@"\\[\\w+:.*\\] \\[Repo Tag :.*\\] \\[PHP.*\\]" onString:object withCaptureGroup:NO];
        
        if (isEnvironment) {
            NSArray *allParse = [object componentsSeparatedByString:@"]"];
            NSArray *environmentParse = [[allParse objectAtIndex:0] componentsSeparatedByString:@":"];
            [self.hostingSetup setObject:[self sanitizeRawResponse:[environmentParse objectAtIndex:1]] forKey:[self sanitizeRawResponse:[environmentParse objectAtIndex:0]]];
        }
    }
    self.tasks--;
}

- (NSString *)sanitizeRawResponse:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"[" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"]" withString:@""];
    return string;
}

- (void)alertCustomerNotFound
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"No customer found."];
    [alert setInformativeText:@"Could not locate the customer.  Check the spelling of the sitegroup or domain and that the customer is actually being hosted by Acquia."];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:[NSApp keyWindow] modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (NSString *)performRegex:(NSString *)regex onString:(NSString *)string withCaptureGroup:(BOOL)group
{
    NSError *error = NULL;
    
    NSRegularExpression *regexSearch = [NSRegularExpression regularExpressionWithPattern:regex
                                                                                 options:NSRegularExpressionCaseInsensitive
                                                                                   error:&error];
    
    NSTextCheckingResult *regexMatch = [regexSearch firstMatchInString:string
                                                               options:0
                                                                 range:NSMakeRange(0, [string length])];
    
    if (regexMatch) {
        if (group) {
            return [string substringWithRange:[regexMatch rangeAtIndex:1]];
        } else {
            return [string substringWithRange:[regexMatch range]];
        }
    } else {
        return nil;
    }
}

@end
