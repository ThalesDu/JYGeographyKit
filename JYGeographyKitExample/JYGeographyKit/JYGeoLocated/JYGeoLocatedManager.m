//
//  JYGeoLocatedManager.m
//  JYGeographyKitExample
//
//  Created by djy on 2017/6/24.
//  Copyright © 2017年 Jiny. All rights reserved.
//

#import "JYGeoLocatedManager.h"
#import "JYGeoLocatedReachability.h"
#import "JYGeoLocatedRequest.h"


dispatch_queue_t data_queue ()
{
    static dispatch_queue_t dataSerialqueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataSerialqueue = dispatch_queue_create("com.JYGeograyhyKit.locationDataQueue", NULL);
    });
    return dataSerialqueue;
}

@interface JYGeoLocatedManager() <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *p_locationManager;
@property (nonatomic, strong) NSMutableArray<JYGeoLocatedRequest *> *m_requests;

@property (nonatomic, strong)CLLocation *currentLocation;
@property (nonatomic, assign) BOOL isUpdatingLocation;
@property (nonatomic, assign) BOOL isMonitoringSignificantLocationChanges;
@property (nonatomic, assign) BOOL isLastLocatedFailed;
@end

@implementation JYGeoLocatedManager
+ (void) load
{
    [self sharedInstance];
}

+ (instancetype) sharedInstance
{
    static JYGeoLocatedManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JYGeoLocatedManager alloc] initInner];
    });
    return instance;
}

- (instancetype)init
{
    NSAssert(nil, @"Only one instance of JYGeoLocatedManager should be created. Use +[JYGeoLocatedManager sharedInstance] instead.");
    return nil;
}
- (instancetype) initInner
{
    self = [super init];
    if (!self) {
        return nil;
    }
    JYGEOLog(@"Init isMainThread : %@",[NSThread isMainThread]?@"YES":@"NO");
    _p_locationManager = ({
        CLLocationManager *manager = [[CLLocationManager alloc] init];
        manager.delegate = self;
#ifdef __IPHONE_8_4
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4
        /* iOS 9 requires setting allowsBackgroundLocationUpdates to YES in order to receive background location updates.
         We only set it to YES if the location background mode is enabled for this app, as the documentation suggests it is a
         fatal programmer error otherwise. */
        NSArray *backgroundModes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
        if ([backgroundModes containsObject:@"location"]) {
            if ([_p_locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
                [_p_locationManager setAllowsBackgroundLocationUpdates:YES];
            }
        }
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4 */
#endif /* __IPHONE_8_4 */
        manager;
    });
    
    _m_requests = [[NSMutableArray alloc] init];
    _isUpdatingLocation = NO;
    return self;
}


- (void) locatiedWithRequest:(JYGeoLocatedRequest *) request
{
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (![self checkRequest:request]) {
            return;
        }
        [self addLocationRequest:request];
    });
    
}

- (void) updateCurrentAccurancyWithNewAccurancy:(CLLocationAccuracy)newAccurancy type:(JYGeoLocatedRequesType) type
{
    __block CLLocationAccuracy minimumDesiredAccuracy = kJYGeoHorizontalAccuracyThresholdCity;
    dispatch_async(data_queue(), ^{
        NSArray *arr = self.m_requests.copy;
        for (JYGeoLocatedRequest *locationRequest in arr) {
            if (locationRequest.requestType == type && locationRequest.desiredAccuracy < minimumDesiredAccuracy) {
                minimumDesiredAccuracy = locationRequest.desiredAccuracy;
            }
        }
    });
    
    // Take the max of the maximum desired accuracy for all existing location requests and the desired accuracy of the new request we're currently adding
    minimumDesiredAccuracy = MIN(newAccurancy, minimumDesiredAccuracy);
    // change Accurancy
    if (minimumDesiredAccuracy > kJYGeoHorizontalAccuracyThresholdCity) {
        if (self.p_locationManager.desiredAccuracy != kCLLocationAccuracyThreeKilometers) {
            self.p_locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            JYGEOLog(@"Changing location services accuracy level to: low (minimum).");
        }
    } else if(minimumDesiredAccuracy <= kJYGeoHorizontalAccuracyThresholdCity &&
              minimumDesiredAccuracy >= kJYGeoHorizontalAccuracyThresholdNeighborhood){
        if (self.p_locationManager.desiredAccuracy != kCLLocationAccuracyKilometer) {
            self.p_locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
            JYGEOLog(@"Changing location services accuracy level to: medium low.");
        }
    }
    else if(minimumDesiredAccuracy <= kJYGeoHorizontalAccuracyThresholdNeighborhood &&
            minimumDesiredAccuracy >= kJYGeoHorizontalAccuracyThresholdBlock){
        if (self.p_locationManager.desiredAccuracy != kCLLocationAccuracyHundredMeters) {
            self.p_locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            JYGEOLog(@"Changing location services accuracy level to: medium.");
        }
    }else if(minimumDesiredAccuracy <= kJYGeoHorizontalAccuracyThresholdBlock &&
             minimumDesiredAccuracy >= kJYGeoHorizontalAccuracyThresholdHouse){
        if (self.p_locationManager.desiredAccuracy != kCLLocationAccuracyNearestTenMeters) {
            self.p_locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            JYGEOLog(@"Changing location services accuracy level to: medium high.");
        }
    }else if(minimumDesiredAccuracy <= kJYGeoHorizontalAccuracyThresholdHouse &&
             minimumDesiredAccuracy >= 0.f){
        if (self.p_locationManager.desiredAccuracy != kCLLocationAccuracyBest) {
            self.p_locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            JYGEOLog(@"Changing location services accuracy level to: high (maximum).");
        }
    }
}


- (void) removeLocationReuqest:(JYGeoLocatedRequest *) locationRequest
{
    [self.m_requests removeObject:locationRequest];
    
    switch (locationRequest.requestType) {
        case JYGeoLocatedRequesTypeSignle:
        case JYGeoLocatedRequesTypeSubscription:
            [self updateCurrentAccurancyWithNewAccurancy:locationRequest.desiredAccuracy type:locationRequest.requestType];
            [self stopUpdatingLocationIfPossible];
            break;
            
        case JYGeoLocationRequestTypeSignificantChanges:
            [self stopMonitoringSignificantLocationChangesIfNeeded];
            break;
    }
}

- (void) cancleLocationWithRequest:(JYGeoLocatedRequest *)request
{
    [self removeLocationReuqest:request];
}

- (void) addLocationRequest:(JYGeoLocatedRequest *)locationRequest
{
    JYGeoLocatedReachabilityStatus locationServicesState = [JYGeoLocatedReachability sharedInstance].currentStatus;
    if (locationServicesState == JYGeoLocatedReachabilityStatusDisabled ||
        locationServicesState == JYGeoLocatedReachabilityStatusDenied ||
        locationServicesState == JYGeoLocatedReachabilityStatusRestricted) {
        // No need to add this location request, because location services are turned off device-wide, or the user has denied this app permissions to use them
        [self completeLocationRequest:locationRequest];
        return;
    }
    if (!locationRequest.delayUntilAuthorized) {
        [locationRequest startTimeOutIfNotStart];
    }
    switch (locationRequest.requestType) {
        case JYGeoLocatedRequesTypeSignle:
        case JYGeoLocatedRequesTypeSubscription:
        {
            [self updateCurrentAccurancyWithNewAccurancy:locationRequest.requestType type:locationRequest.requestType];
            [self startUpdatingLocationIfNeeded];
        }
            break;
        case JYGeoLocationRequestTypeSignificantChanges:
            [self startMonitoringSignificantLocationChangesIfNeeded];
            break;
    }
    dispatch_sync(data_queue(), ^{
        [self.m_requests addObject:locationRequest];
    });
    
    JYGEOLog(@"Location Request added with ID: %@", locationRequest);
    
    // Process all location requests now, as we may be able to immediately complete the request just added above
    // if a location update was recently received (stored in self.currentLocation) that satisfies its criteria.
    [self processLocationRequests];
}

- (void) processLocationRequests
{
    CLLocation *mostRecentLocation = self.currentLocation;
    if (!mostRecentLocation) {
        return;
    }
    
    dispatch_sync(data_queue(), ^{
        NSArray *requests = self.m_requests.copy;
        for (JYGeoLocatedRequest *request in requests) {
            if (request.hasTimeOut) {
                [self completeLocationRequest:request];
                continue;
            }
            if (mostRecentLocation != nil) {
                if (request.isRecurringRequest) {
                    //处理持续定位请求
                    [self processRecurringRequest:request];
                    continue;
                } else {
                    //处理单次定位请求
                    [self processSignelRequest:request];
                    continue;
                }
            }
        }
    });
}

- (void) processRecurringRequest:(JYGeoLocatedRequest *) request
{
    NSAssert(request.isRecurringRequest, @"The Request isn't Recurring Request");
    JYGeoLocatedStatus status = [self statusForLocatedRequset:request];
    CLLocation *locaiton = self.currentLocation;
    dispatch_async(dispatch_get_main_queue(), ^{
        request.completaionblock(locaiton, status);
    });
}

- (void) processSignelRequest:(JYGeoLocatedRequest *) locationRequest
{
    NSAssert(locationRequest, @"processSignelRequest:Request can't be nil");
    if ([self currentLocationAccuracySuitForRequest:locationRequest]) {
        // The request's desired accuracy has been reached, complete it
        [self completeLocationRequest:locationRequest];
    }
}

-(BOOL) currentLocationAccuracySuitForRequest: (JYGeoLocatedRequest *) locationRequest
{
    NSAssert(locationRequest, @"currentLocationAccuracySuitForRequest:Request can't be nil");
    CLLocation *mostRecentLocation = self.currentLocation;
    NSTimeInterval currentLocationTimeSinceUpdate = fabs([mostRecentLocation.timestamp timeIntervalSinceNow]);
    CLLocationAccuracy currentLocationHorizontalAccuracy = mostRecentLocation.horizontalAccuracy;
    NSTimeInterval staleThreshold = locationRequest.updateTimeStaleThreshold;
    CLLocationAccuracy horizontalAccuracyThreshold = locationRequest.horizontalAccuracyThreshold;
    if (currentLocationTimeSinceUpdate <= staleThreshold &&
        currentLocationHorizontalAccuracy <= horizontalAccuracyThreshold) {
        return YES;
    }
    return NO;
}

#pragma mark - Location Manager Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
      // Received update successfully, so clear any previous errors
      self.isLastLocatedFailed = NO;
      
      CLLocation *mostRecentLocation = [locations lastObject];
      self.currentLocation = mostRecentLocation;
      
      // Process the location requests using the updated location
      [self processLocationRequests];


}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    JYGEOLog(@"Location services error: %@", [error localizedDescription]);
    self.isLastLocatedFailed = YES;
    
    dispatch_sync(data_queue(), ^{
        for (JYGeoLocatedRequest *locationRequest in self.m_requests) {
            if (locationRequest.isRecurringRequest) {
                // Keep the recurring request alive
                [self processRecurringRequest:locationRequest];
            } else {
                // Fail any non-recurring requests
                [self completeLocationRequest:locationRequest];
            }
        }
    });
}

/**
 Immediately completes all active location requests.
 Used in cases such as when the location services authorization status changes to Denied or Restricted.
 */
-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        // Clear out any active location requests (which will execute the blocks with a status that reflects
        // the unavailability of location services) since we now no longer have location services permissions
        [self completeAllLocationRequests];
    } else if(
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
              status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse
#else
              status == kCLAuthorizationStatusAuthorized
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1 */
              ){
        dispatch_sync(data_queue(), ^{
            for (JYGeoLocatedRequest *locationRequest in self.m_requests) {
                [locationRequest startTimeOutIfNotStart];
            }
            
        });
    }
}

#pragma mark - Priviate

-(void)completeAllLocationRequests
{
    dispatch_sync(data_queue(), ^{
        NSArray *array = self.m_requests.copy;
        for (JYGeoLocatedRequest *locationRequest in array) {
            [self completeLocationRequest:locationRequest];
        }
    });
    JYGEOLog(@"Finished completing all location requests.");
}


- (void) completeLocationRequest:(JYGeoLocatedRequest *) request
{
    if (!request) {
        return;
    }
    dispatch_async(data_queue(), ^{
        [self removeLocationReuqest:request];
    });
    
    JYGeoLocatedStatus status = [self statusForLocatedRequset:request];
    CLLocation *locaiton = self.currentLocation;
    dispatch_async(dispatch_get_main_queue(), ^{
        request.completaionblock(locaiton, status);
    });
}

- (JYGeoLocatedStatus) statusForLocatedRequset:(JYGeoLocatedRequest *)requset
{
    JYGeoLocatedStatus status = JYGeoLocatedStatusSuccessed;
    
    switch ([JYGeoLocatedReachability sharedInstance].currentStatus) {
        case JYGeoLocatedReachabilityStatusDisabled:
            status = JYGeoLocatedStatusServicesDisabled;
        case JYGeoLocatedReachabilityStatusDenied:
            status = JYGeoLocatedStatusServicesDenied;
            break;
        case JYGeoLocatedReachabilityStatusRestricted:
            status = JYGeoLocatedStatusServicesRestricted;
            break;
        case JYGeoLocatedReachabilityStatusNotDetermined:
            status = JYGeoLocatedStatusServicesNotDetermined;
            break;
        default:
            break;
    }
    if (self.isLastLocatedFailed) {
        status = JYGeoLocatedStatusSystemError;
    }
    if (requset.hasTimeOut) {
        status = JYGeoLocatedStatusTimeOut;
    }
    return status;
}

#pragma mark - Start & Stop Location Service
/**
 Inform CLLocationManager to start monitoring significant location changes.
 */
- (void)startMonitoringSignificantLocationChangesIfNeeded
{
    [self requestAuthorizationIfNeeded];
    __block NSArray *locationRequests;
    dispatch_sync(data_queue(), ^{
        locationRequests  = [self.m_requests filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(JYGeoLocatedRequest *evaluatedObject, NSDictionary *bindings) {
            return evaluatedObject.requestType == JYGeoLocationRequestTypeSignificantChanges;
        }]];
    });
    if (locationRequests.count == 0) {
        [self.p_locationManager startMonitoringSignificantLocationChanges];
        if (self.isMonitoringSignificantLocationChanges == NO) {
            JYGEOLog(@"Significant location change monitoring has started.")
        }
        self.isMonitoringSignificantLocationChanges = YES;
    }
}

/**
 Inform CLLocationManager to start sending us updates to our location.
 */
- (void)startUpdatingLocationIfNeeded
{
    [self requestAuthorizationIfNeeded];
    
    __block NSArray *locationRequests;
    dispatch_sync(data_queue(), ^{
        locationRequests = [self.m_requests filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(JYGeoLocatedRequest *evaluatedObject, NSDictionary *bindings) {
            return evaluatedObject.requestType != JYGeoLocationRequestTypeSignificantChanges;
        }]];
    });
    
    if (locationRequests.count == 0) {
        [self.p_locationManager startUpdatingLocation];
        if (self.isUpdatingLocation == NO) {
            JYGEOLog(@"Location services updates have started.");
        }
        self.isUpdatingLocation = YES;
    }
}

- (void)stopUpdatingLocationIfPossible
{
    __block NSArray *locationRequests;
    dispatch_async(data_queue(), ^{
        locationRequests = [self.m_requests filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(JYGeoLocatedRequest *evaluatedObject, NSDictionary *bindings) {
            return evaluatedObject.requestType != JYGeoLocationRequestTypeSignificantChanges;
        }]];
    });
   
    if (locationRequests.count == 0) {
        [self.p_locationManager stopUpdatingLocation];
        if (self.isUpdatingLocation) {
            JYGEOLog(@"Location services updates have stopped.");
        }
        self.isUpdatingLocation = NO;
    }
}


- (void) stopMonitoringSignificantLocationChangesIfNeeded
{
    
    __block NSArray * locationRequests;
    dispatch_sync(data_queue(), ^{
        locationRequests = [self.m_requests filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(JYGeoLocatedRequest *evaluatedObject, NSDictionary *bindings) {
            return evaluatedObject.requestType == JYGeoLocationRequestTypeSignificantChanges;
        }]];
    });
    if (locationRequests.count == 0) {
        [self.p_locationManager stopMonitoringSignificantLocationChanges];
        if (self.isMonitoringSignificantLocationChanges) {
            JYGEOLog(@"Significant location change monitoring has stopped.");
        }
        self.isMonitoringSignificantLocationChanges = NO;
    }
}

#pragma mark - Verify Request
- (BOOL) checkRequest : (JYGeoLocatedRequest *)request
{
    if (!request.completaionblock) {
        JYGEOLog(@"Request:%@ not have complete callBack",request);
    }
    
    if (request.requestType != JYGeoLocatedRequesTypeSignle &&
        request.requestType != JYGeoLocatedRequesTypeSubscription &&
        request.requestType != JYGeoLocationRequestTypeSignificantChanges) {
        !request.completaionblock ? : request.completaionblock(nil, JYGeoLocatedStatusHaveErrorPorperty);
        JYGEOLog(@"Request:%@ type is not in JYGeoLocatedRequest",request);
    }
    return YES;
}

/**
 Requests permission to use location services on devices with iOS 8+.
 */
- (void)requestAuthorizationIfNeeded
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    // As of iOS 8, apps must explicitly request location services permissions. INTULocationManager supports both levels, "Always" and "When In Use".
    // INTULocationManager determines which level of permissions to request based on which description key is present in your app's Info.plist
    // If you provide values for both description keys, the more permissive "Always" level is requested.
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1 && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        BOOL hasAlwaysKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil;
        BOOL hasWhenInUseKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
        if (hasAlwaysKey) {
            [self.p_locationManager requestAlwaysAuthorization];
        } else if (hasWhenInUseKey) {
            [self.p_locationManager requestWhenInUseAuthorization];
        } else {
            // At least one of the keys NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription MUST be present in the Info.plist file to use location services on iOS 8+.
            NSAssert(hasAlwaysKey || hasWhenInUseKey, @"To use location services in iOS 8+, your Info.plist must provide a value for either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription.");
        }
    }
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1 */
}

@end
