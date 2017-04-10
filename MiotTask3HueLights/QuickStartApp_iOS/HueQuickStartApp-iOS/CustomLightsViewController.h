//
//  CustomLightsViewController.h
//  HueQuickStartApp-iOS
//
//  Created by Lee, John on 4/9/17.
//  Copyright © 2017 Philips. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHHueSDK;

@interface CustomLightsViewController : UIViewController

- (id)initWithHueSDK:(PHHueSDK *)hueSdk;
- (void)setColorWithHue:(NSNumber*)hue sat:(NSNumber*)sat lum:(NSNumber*)lum;

@end
