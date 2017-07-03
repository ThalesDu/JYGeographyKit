//
//  JYGeoLocatedRequest.h
//  JYGeographyKitExample
//
//  Created by djy on 2017/6/24.
//  Copyright © 2017年 Jiny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYGeoLocatedDefine.h"
typedef NS_ENUM(NSInteger, JYGeoLocatedRequesType)
{
    //fetch location at once
    JYGeoLocatedRequesTypeSignle,
    //monitor the location change with Block
    JYGeoLocatedRequesTypeSubscription,
    //moitor the location change when location changed significant.
    JYGeoLocationRequestTypeSignificantChanges
};

@interface JYGeoLocatedRequest : NSObject<NSCopying>
@property (nonatomic, assign) JYGeoHorizontalAccuracy desiredAccuracy;
@property (nonatomic, assign) JYGeoLocatedRequesType requestType;
@property (nonatomic, assign) NSTimeInterval timeOut; //!<  单次定位才有超时时间默认是10s
@property (nonatomic, copy) JYGeoLocatedCompletionBlock completaionblock;


@property (nonatomic, readonly) CLLocationAccuracy horizontalAccuracyThreshold;
@property (nonatomic, readonly) CLLocationAccuracy updateTimeStaleThreshold;
@property (nonatomic, assign, readonly) BOOL hasTimeOut;
//是否是持续定位的请求
@property (nonatomic, readonly, getter = isRecurringRequest) BOOL recurringRequest;
@property (nonatomic, assign) NSTimeInterval startRequestTimeintervalFrom1970;

@property (nonatomic, assign) BOOL delayUntilAuthorized;
- (void) resume;
- (void) cancel;

- (void) forceTimeout;


- (void) startTimeOutIfNotStart;

-(instancetype)initWithType : (JYGeoLocatedRequesType) requestType
             desiredAccuracy:(JYGeoHorizontalAccuracy)desiredAccuracy
             timeOutInterval:(NSTimeInterval) timeout
                  completion:(JYGeoLocatedCompletionBlock) completeBlock NS_DESIGNATED_INITIALIZER ;



@end
