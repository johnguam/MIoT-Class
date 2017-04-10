//
//  CustomLightsViewController.m
//  HueQuickStartApp-iOS
//
//  Created by Lee, John on 4/9/17.
//  Copyright © 2017 Philips. All rights reserved.
//

#import "CustomLightsViewController.h"
#import "ISColorWheel.h"

#import <HueSDK_iOS/HueSDK.h>

#define MAX_HUE 65535
#define MAX_SAT 254
#define MAX_LUM 254

@interface CustomLightsViewController () <ISColorWheelDelegate>

@property (nonatomic, strong) PHHueSDK *phHueSDK;
@property (nonatomic,weak) IBOutlet UIButton *setColorsButton;
@property (nonatomic, strong) ISColorWheel* colorWheel;
@property (nonatomic, strong) UILabel *colorLabel;

- (void)colorWheelDidChangeColor:(ISColorWheel*)colorWheel;
- (void)addColorWheel;
- (void)addColorLabel;

@end

@implementation CustomLightsViewController

- (id)initWithHueSDK:(PHHueSDK *)hueSdk {
    self = [super init];
    if (self) {
        self.phHueSDK = hueSdk;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self addColorWheel];
    [self addColorLabel];
    
    self.colorWheel.delegate = self;

    [self updateColorLabel];
    
}

- (void)addColorLabel {
    CGSize labelSize = CGSizeMake(200.0, 200.0);
    self.colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
    
    [self.view addSubview:self.colorLabel];

    self.colorLabel.textAlignment = NSTextAlignmentCenter;
    self.colorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.colorLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.colorLabel.topAnchor constraintEqualToAnchor:self.colorWheel.bottomAnchor constant:20.0].active = YES;
}

- (void)addColorWheel {
    CGSize wheelSize = CGSizeMake(250.0, 250.0);

    // Need to initWithFrame to ensure color selector dot is centered. Frame data will be overwritten by the below constraint logic
    self.colorWheel = [[ISColorWheel alloc] initWithFrame:CGRectMake(0, 0, wheelSize.width, wheelSize.height)];
    
    // Turned off continous color updating so Philips Hue light will update to new color more quickly
    //self.colorWheel.continuous = YES;
    
    // Need to add to subview prior to setting constraints
    [self.view addSubview:self.colorWheel];
    
    // Turning off Autoresizing Mask but you lose width and height from frame data
    self.colorWheel.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Manually provide width and height as ColorWheel
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self.colorWheel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:NULL attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:wheelSize.width];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.colorWheel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:NULL attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:wheelSize.height];
    
    [self.colorWheel addConstraint:widthConstraint];
    [self.colorWheel addConstraint:heightConstraint];
    
    [self.colorWheel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.colorWheel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:50.0].active = YES;
    
}

- (void)updateColorLabel {
    CGFloat hue = 0;
    CGFloat sat = 0;
    CGFloat lum = 0;
    CGFloat alpha = 0;
    
    [self.colorWheel.currentColor getHue:&hue saturation:&sat brightness:&lum alpha:&alpha];
    
    // Oddly, the Philips Hue lights set the max to a 16-bit hex versus an 8-bit, 255 max value
    NSInteger hueInt = (NSInteger)(hue * 0xffff) % MAX_HUE;
    NSInteger satInt = (NSInteger)(sat * 0xff);
    NSInteger lumInt = (NSInteger)(lum * 0xff);
    
    // Oddly, the Philips Hue lights do not work if a value of 255 is passed in
    if (satInt > MAX_SAT) {
        satInt = MAX_SAT;
    }

    if (lumInt > MAX_LUM) {
        lumInt = MAX_LUM;
    }
    
    NSString *hueString = [@(hueInt) stringValue];
    NSString *satString = [@(satInt) stringValue];
    NSString *lumString = [@(lumInt) stringValue];

    NSString *colorText = [NSString stringWithFormat:@"Hue: %@, Sat: %@, Lum: %@", hueString, satString, lumString];
    [self.colorLabel setText: colorText];
    
    NSNumber *hueNum = [[NSNumber alloc] initWithInteger:hueInt];
    NSNumber *satNum = [[NSNumber alloc] initWithInteger:satInt];
    NSNumber *lumNum = [[NSNumber alloc] initWithInteger:lumInt];
    
    [self setColorWithHue:hueNum sat:satNum lum:lumNum];
}


- (void)setColorWithHue:(NSNumber*)hue sat:(NSNumber*)sat lum:(NSNumber*)lum {
    PHBridgeResourcesCache *cache = [PHBridgeResourcesReader readBridgeResourcesCache];
    PHBridgeSendAPI *bridgeSendAPI = [[PHBridgeSendAPI alloc] init];
    
    for (PHLight *light in cache.lights.allValues) {
        PHLightState *lightState = [[PHLightState alloc] init];
        
        [lightState setHue:hue];
        [lightState setSaturation:sat];
        [lightState setBrightness:lum];
        
        // Send lightstate to light
        [bridgeSendAPI updateLightStateForId:light.identifier withLightState:lightState completionHandler:^(NSArray *errors) {
            if (errors != nil) {
                NSString *message = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Errors", @""), errors != nil ? errors : NSLocalizedString(@"none", @"")];
                
                NSLog(@"Response: %@",message);
            }
        }];
    }
}

#pragma mark - ColorWheel delegate

- (void)colorWheelDidChangeColor:(ISColorWheel*)colorWheel {
    [self updateColorLabel];
}

@end
