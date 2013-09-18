//
//  AQAppDelegate.h
//  Titan
//
//  Created by Albert Martin on 7/24/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ITSidebar;
@class AQCustomer;
@class HTTPServer;

@interface AQAppDelegate : NSObject <NSApplicationDelegate>
{
    HTTPServer *httpServer;
}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet ITSidebar *sidebar;
@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (weak) IBOutlet AQCustomer *customerData;

- (void)loadCustomerDataForCustomer:(NSString *)customer;

@end
