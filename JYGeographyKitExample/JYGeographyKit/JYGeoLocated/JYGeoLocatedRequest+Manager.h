//
//  JYGeoLocatedRequest+Manager.h
//  JYGeographyKitExample
//
//  Created by djy on 2017/7/3.
//  Copyright © 2017年 Jiny. All rights reserved.
//

#import "JYGeoLocatedRequest.h"

@interface JYGeoLocatedRequest ()
@property (nonatomic, copy) JYGeoLocatedCompletionBlock completaionblock;
@property (nonatomic, readwrite) BOOL hasTimeOut;
@property (nonatomic, assign) NSTimeInterval startRequestTimeintervalFrom1970;
@end

@interface JYGeoLocatedRequest (Manager)
@property (nonatomic, readonly) CLLocationAccuracy horizontalAccuracyThreshold;
@property (nonatomic, readonly) CLLocationAccuracy updateTimeStaleThreshold;
@property (nonatomic, readonly, getter = isRecurringRequest) BOOL recurringRequest;//!< 是否是持续定位的请求
- (void) startTimeOutIfNotStart;
@end
