//
//  JYGeoLocatedRequest.m
//  JYGeographyKitExample
//
//  Created by djy on 2017/6/24.
//  Copyright © 2017年 Jiny. All rights reserved.
//

#import "JYGeoLocatedRequest.h"
#import "JYGeoLocatedManager.h"



@interface JYGeoLocatedRequest ()
@property (nonatomic, readwrite) BOOL hasTimeOut;
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

- (void) startTimeOutIfNotStart
{
    if (self.startRequestTimeintervalFrom1970<1.0) {
        self.startRequestTimeintervalFrom1970 = [[NSDate date] timeIntervalSince1970];
    }
}

#pragma mark - Read Only Property
- (BOOL)isRecurringRequest
{
    return self.requestType == JYGeoLocationRequestTypeSignificantChanges || self.requestType == JYGeoLocatedRequesTypeSubscription;
}

- (CLLocationAccuracy)horizontalAccuracyThreshold
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

-(CLLocationAccuracy)updateTimeStaleThreshold
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
#pragma mark -
- (void)dealloc
{
    self.completaionblock = nil;
}

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
