//
//  AQEnvironmentVisualizer.h
//  Thermopylae
//
//  Created by Albert Martin on 8/24/13.
//  Copyright (c) 2013 Albert Martin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/CoreAnimation.h>

@interface AQEnvironmentVisualizer : NSView {
    CALayer *rootLayer;
    CAGradientLayer *gradientLayer;
    int vertical;
}
    
@end
