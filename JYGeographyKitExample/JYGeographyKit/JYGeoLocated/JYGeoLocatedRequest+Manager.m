//
//  JYGeoLocatedRequest+Manager.m
//  JYGeographyKitExample
//
//  Created by djy on 2017/7/3.
//  Copyright © 2017年 Jiny. All rights reserved.
//

#import "JYGeoLocatedRequest+Manager.h"

@implementation JYGeoLocatedRequest (Manager)

#pragma mark - Timeout Base;
- (void) startTimeOutIfNotStart
{
    if (self.startRequestTimeintervalFrom1970<1.0) {
        self.startRequestTimeintervalFrom1970 = [[NSDate date] timeIntervalSince1970];
    }
}
#pragma mark - Readonly Property;
- (BOOL) isRecurringRequest
{
    return self.requestType == JYGeoLocationRequestTypeSignificantChanges || self.requestType == JYGeoLocatedRequesTypeSubscription;
}

- (CLLocationAccuracy) horizontalAccuracyThreshold
{
    switch (self.desiredAccuracy) {
        case JYGeoHorizontalAccuracyThresholdCity:
            return kJYGeoHorizontalAccuracyThresholdCity;
            break;
        case JYGeoHorizontalAccuracyThresholdNeighborhood:
            return kJYGeoHorizontalAccuracyThresholdNeighborhood;
            break;
        case JYGeoHorizontalAccuracyThresholdBlock:
            return kJYGeoHorizontalAccuracyThresholdBlock;
            break;
        case JYGeoHorizontalAccuracyThresholdHouse:
            return kJYGeoHorizontalAccuracyThresholdHouse;
            break;
        case JYGeoHorizontalAccuracyThresholdRoom:
            return kJYGeoHorizontalAccuracyThresholdRoom;
            break;
        default:
            NSAssert(NO, @"Unknown desired accuracy.");
            return 0.0;
            break;
            
    }
}

- (CLLocationAccuracy) updateTimeStaleThreshold
{
    switch (self.desiredAccuracy) {
        case JYGeoHorizontalAccuracyThresholdCity:
            return kJYGeoTimeintervalThresholdCity;
            break;
        case JYGeoHorizontalAccuracyThresholdNeighborhood:
            return kJYGeoTimeintervalThresholdNeighborhood;
            break;
        case JYGeoHorizontalAccuracyThresholdBlock:
            return kJYGeoTimeintervalThresholdBlock;
            break;
        case JYGeoHorizontalAccuracyThresholdHouse:
            return kJYGeoTimeintervalThresholdHouse;
            break;
        case JYGeoHorizontalAccuracyThresholdRoom:
            return kJYGeoTimeintervalThresholdRoom;
            break;
        default:
            NSAssert(NO, @"Unknown desired accuracy.");
            return 0.0;
            break;
    }
}
@end
