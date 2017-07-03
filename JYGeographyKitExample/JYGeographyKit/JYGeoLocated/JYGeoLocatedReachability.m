//
//  JYGeoLocatedReachability.m
//  JYGeographyKitExample
//
//  Created by djy on 2017/6/25.
//  Copyright © 2017年 Jiny. All rights reserved.
//

#import "JYGeoLocatedReachability.h"


@interface JYGeoLocatedReachability()

@property (readwrite, nonatomic, assign) JYGeoGpsSignalStrength currentSignalStrength; //!< 当前的GPS型号强度， 更据定位的精度计算出来的。

@end

@interface JYGeoLocatedReachability (privite)

- (void) registNotification;
- (void) removeObserver;
@end



@implementation JYGeoLocatedReachability

+ (instancetype) sharedInstance
{
    static JYGeoLocatedReachability *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JYGeoLocatedReachability alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _currentSignalStrength = JYGeoGpsSignalStrengthUnKnow;
        [self registNotification];
    }
    return self;
}

- (JYGeoLocatedReachabilityStatus)currentStatus
{
    if ([CLLocationManager locationServicesEnabled] == NO) {
        return JYGeoLocatedReachabilityStatusDisabled;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        return JYGeoLocatedReachabilityStatusNotDetermined;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        return JYGeoLocatedReachabilityStatusDenied;
    }
    else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return JYGeoLocatedReachabilityStatusRestricted;
    }
    
    return JYGeoLocatedReachabilityStatusAvailable;
}

-(void)dealloc
{
    [self removeObserver];
}
@end

@implementation JYGeoLocatedReachability (privite)

-(void) registNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveLocationChange:) name:kJYGeoLocationgChangeNotificaiton object:nil];
}

- (void) receiveLocationChange:(NSNotification *) notification
{
    //FIXME: Jiny : 从notification获取定位精度
    CLLocationAccuracy horizontalAccuracy = 0;
    JYGeoGpsSignalStrength strengthLevel = JYGeoGpsSignalStrengthUnKnow;
    if (horizontalAccuracy>0) {
        if (horizontalAccuracy >= 500) {
            strengthLevel = JYGeoGpsSignalStrengthLow;
        }
        if (horizontalAccuracy<500 && horizontalAccuracy>50) {
            strengthLevel = JYGeoGpsSignalStrengthMedium;
        }
        if (horizontalAccuracy < 50) {
            strengthLevel = JYGeoGpsSignalStrengthHigh;
        }
    }
    self.currentSignalStrength  = strengthLevel;
    [[NSNotificationCenter defaultCenter] postNotificationName:kJYGeoSingleStrengthChangeNotification object:nil userInfo:@{
                                                                                                                            kJYGeoSingleStrengthLevel:@(strengthLevel)
                                                                                                                            }];
}

- (void) removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end



