//
//  JYGeoLocatedRequest.m
//  JYGeographyKitExample
//
//  Created by djy on 2017/6/24.
//  Copyright © 2017年 Jiny. All rights reserved.
//

#import "JYGeoLocatedRequest.h"
#import "JYGeoLocatedManager.h"
#import "JYGeoLocatedRequest+Manager.h"

@interface JYGeoLocatedRequest ()
@property (nonatomic, assign, readwrite) JYGeoLocatedRequesType requestType;//!< 定位的类型，1、单次定位 2、持续定位 3、显著位置变化的监听。
@property (nonatomic, assign, readwrite) NSTimeInterval timeOut; //!<  单次定位才有超时时间默认是10s
@property (nonatomic, assign) NSInteger requestId;
@end

@implementation JYGeoLocatedRequest

+(NSInteger) getUniqueRequestID
{
    static NSInteger currentIDMax = 0;
    return currentIDMax++;
}

- (instancetype)init
{
    return [self initWithType:JYGeoLocatedRequesTypeSignle desiredAccuracy:JYGeoHorizontalAccuracyNone timeOutInterval:10.0f completion:nil];
}

- (instancetype)initWithType : (JYGeoLocatedRequesType) requestType
             desiredAccuracy:(JYGeoHorizontalAccuracy)desiredAccuracy
             timeOutInterval:(NSTimeInterval) timeout
                  completion:(JYGeoLocatedCompletionBlock) completeBlock
{
    self = [super init];
    if (self) {
        _requestType = requestType;
        _desiredAccuracy = desiredAccuracy;
        _timeOut = timeout;
        _completaionblock = [completeBlock copy];
        _hasTimeOut = NO;
        _startRequestTimeintervalFrom1970 = 0.f;
        _delayUntilAuthorized = YES;
        _requestId = [self.class getUniqueRequestID];
    }
    return self;
    
}

- (void)resume
{
    [[JYGeoLocatedManager sharedInstance] locatiedWithRequest:self];
}
- (void)cancel
{
    [[JYGeoLocatedManager sharedInstance] cancleLocationWithRequest:self];
}

#pragma mark - NSCopy Protocol
- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    if (((JYGeoLocatedRequest *)object).requestId == self.requestId) {
        return YES;
    }
    return NO;
}

- (NSUInteger)hash
{
    return [NSString stringWithFormat:@"%ld", (long)self.requestId].hash;
}

-(id)copyWithZone:(NSZone *)zone
{
    typeof(self) copySelf = [[JYGeoLocatedRequest allocWithZone:zone] initWithType:self.requestType
                                                                   desiredAccuracy:self.desiredAccuracy
                                                                   timeOutInterval:self.timeOut
                                                                        completion:self.completaionblock];
    copySelf.requestId = self.requestId;
 
    return copySelf;
}


#pragma mark - Time out
-(BOOL)hasTimeOut
{
    if (self.timeOut > 0 && self.isRecurringRequest == NO) {
        NSTimeInterval nowTimeIntervalSince1970 = [[NSDate date] timeIntervalSince1970];
        return _hasTimeOut?YES:nowTimeIntervalSince1970-self.startRequestTimeintervalFrom1970 < self.timeOut;
    }
    return NO;
}

-(void)forceTimeout
{
    if (self.isRecurringRequest == NO) {
        _hasTimeOut = YES;
    }
}

#pragma mark -
-(NSString *)description
{
    NSString *typeString;
    switch (self.requestType) {
        case JYGeoLocatedRequesTypeSignle:
            typeString = @"Type-Signle";
            break;
        case JYGeoLocatedRequesTypeSubscription:
            typeString = @"Type-Subscription";
            break;
        case JYGeoLocationRequestTypeSignificantChanges:
            typeString = @"Type-SignificantChanges";
            break;
        default:
            break;
    }
    return [NSString stringWithFormat:@"JYGeoLocatedRequest %p : hasTimeOut = %@, Type = %@, timeOutInterval = %.2f",self,self.hasTimeOut?@"YES":@"NO",typeString,self.timeOut];
}



@end
