//
//  AQEnvironmentVisualizer.m
//  Thermopylae
//
//  Created by Albert Martin on 8/24/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import "AQEnvironmentVisualizer.h"

@implementation AQEnvironmentVisualizer

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Create the root layer
        rootLayer = [CALayer layer];
        rootLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
        
        vertical = [self frame].size.height-30;
        
        [self setLayer:rootLayer];
        [self setWantsLayer:YES];
        
        [self buildLoadBalancers:2];
    }
    
    return self;
}

- (void)buildLoadBalancers:(int)count
{
    int i = 0;
    while (i < count) {
        CAGradientLayer *loadBalancer = [CAGradientLayer layer];
        
        //Package the colors in a NSArray and add it to the layer
        NSArray *colors = [NSArray arrayWithObjects:(__bridge id)CGColorCreateGenericRGB(0.0, 1.0, 0.0, 1), (__bridge id)CGColorCreateGenericRGB(0.0, 0.0, 1.0, 1), nil];
        loadBalancer.colors = colors;
        loadBalancer.borderWidth = 1.0;
        
        //Set the size and position of the gradient layer
        loadBalancer.frame = CGRectMake(0, 0, [self frame].size.width, 30);
        loadBalancer.anchorPoint = CGPointMake(0, 0);
        loadBalancer.position = CGPointMake(0, vertical);
        
        [self.layer addSublayer:loadBalancer];
        
        loadBalancer.autoresizingMask = kCALayerWidthSizable | kCALayerMinYMargin;
        
        vertical -= loadBalancer.frame.size.height+5;
        i++;
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
