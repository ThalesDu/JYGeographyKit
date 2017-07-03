//
//  JYGeoLocatedDefine.h
//  JYGeographyKitExample
//
//  Created by djy on 2017/6/24.
//  Copyright © 2017年 Jiny. All rights reserved.
//

#ifndef JYGeoLocatedDefine_h
#define JYGeoLocatedDefine_h

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#ifndef JYGEO_ENABLE_LOGGING
#   ifdef DEBUG
#       define JYGEO_ENABLE_LOGGING 1
#   else
#       define JYGEO_ENABLE_LOGGING 0
#   endif /* DEBUG */
#endif /* JYGEO_ENABLE_LOGGING */


#if JYGEO_ENABLE_LOGGING
#   define JYGEOLog(...)          NSLog(@"JYGeoLocatiedLog: %@", [NSString stringWithFormat:__VA_ARGS__]);
#else
#   define JYGEOLog(...)
#endif /* JYGEO_ENABLE_LOGGING */


@class CLLocation;
typedef NS_ENUM(NSInteger, JYGeoLocatedStatus) {
    JYGeoLocatedStatusSuccessed = 0,
    JYGeoLocatedStatusTimeOut,
    JYGeoLocatedStatusHaveErrorPorperty,
    //Authentication Error
    //第一次打开App，用户还没有响应允许此应用访问位置服务的对话框
    JYGeoLocatedStatusServicesNotDetermined,
    //用户已经明确的拒绝此应用访问位置服务的权限，需要提醒用户在App设置中允许访问地理位置
    JYGeoLocatedStatusServicesDenied,
    //用户无法启动定位服务（如家长控制：parental controls，公司策略： corporate policy 等等）
    JYGeoLocatedStatusServicesRestricted,
    //用户已经在App中关闭了设备的定位服务的总开关
    JYGeoLocatedStatusServicesDisabled,
    //这个标志系统定位出错。
    JYGeoLocatedStatusSystemError
};
/**
 * @brief complete Located Call Back
 * @param location This is from GPS Module, coordinate is allow WGS_84 coordinate system. 
 *        In China, if you want to show it in mapView, you need to convert to GCJ02 coordinate。
 */
typedef void(^JYGeoLocatedCompletionBlock)(CLLocation *location, JYGeoLocatedStatus status);

//GPS目前的状态
typedef NS_ENUM(NSInteger, JYGeoLocatedReachabilityStatus) {
    JYGeoLocatedReachabilityStatusAvailable = 0,
    //Authentication Error
    JYGeoLocatedReachabilityStatusNotDetermined,
    JYGeoLocatedReachabilityStatusDenied,
    JYGeoLocatedReachabilityStatusRestricted,
    JYGeoLocatedReachabilityStatusDisabled
};

//信号强度
typedef NS_ENUM(NSInteger, JYGeoGpsSignalStrength) {
    JYGeoGpsSignalStrengthUnKnow = 0,
    JYGeoGpsSignalStrengthHigh,
    JYGeoGpsSignalStrengthMedium,
    JYGeoGpsSignalStrengthLow
};

typedef NS_ENUM(NSInteger, JYGeoHorizontalAccuracy)
{
    /** Inaccurate (>5000 meters, and/or received >10 minutes ago). */
    JYGeoHorizontalAccuracyNone = 0,
    /** 5000 meters or better, and received within the last 10 minutes. Lowest accuracy. */
    JYGeoHorizontalAccuracyThresholdCity,
    /** 1000 meters or better, and received within the last 5 minutes. */
    JYGeoHorizontalAccuracyThresholdNeighborhood,
    /** 100 meters or better, and received within the last 1 minute. */
    JYGeoHorizontalAccuracyThresholdBlock,
    /** 15 meters or better, and received within the last 15 seconds. */
    JYGeoHorizontalAccuracyThresholdHouse,
    /** 5 meters or better, and received within the last 5 seconds. Highest accuracy. */
    JYGeoHorizontalAccuracyThresholdRoom
    
};


static const CLLocationAccuracy kJYGeoHorizontalAccuracyThresholdCity =         5000.0;  //!< 5000 meters
static const CLLocationAccuracy kJYGeoHorizontalAccuracyThresholdNeighborhood = 1000.0;  //!< 1000 meters
static const CLLocationAccuracy kJYGeoHorizontalAccuracyThresholdBlock =         100.0;  //!< 100  meters
static const CLLocationAccuracy kJYGeoHorizontalAccuracyThresholdHouse =          15.0;  //!< 15 meters
static const CLLocationAccuracy kJYGeoHorizontalAccuracyThresholdRoom =            5.0;  //!< 5 meters

static const CLLocationAccuracy kJYGeoTimeintervalThresholdCity =         600.0;  //!< 600 seconds
static const CLLocationAccuracy kJYGeoTimeintervalThresholdNeighborhood = 300.0;  //!< 300 seconds
static const CLLocationAccuracy kJYGeoTimeintervalThresholdBlock =         60.0;  //!<  60 seconds
static const CLLocationAccuracy kJYGeoTimeintervalThresholdHouse =         15.0;  //!<  15 seconds
static const CLLocationAccuracy kJYGeoTimeintervalThresholdRoom =           5.0;  //!<   5 seconds


//用户改变了定位的链接或者授权状态。
static NSString * const kJYGeoReachabilityChangeNotification = @"kJYGeoReachabilityChangeNotification";
//只要是通过JYGeoLocationKit完成的坐标坐标变化就会呼叫这个Notification
static NSString * const kJYGeoLocationgChangeNotificaiton = @"kJYGeoLocationgChangeNotificaiton";
//信号强度的Key
static NSString * const kJYGeoNotificationKeySingleStrengthLevel = @"kJYGeoSingleStrengthLevel";

//通过监听坐标变化时候的精度变化来挑战GPS型号强度
static NSString * const kJYGeoSingleStrengthChangeNotification = @"kJYGeoSingleStrengthChangeNotification";
//UserInfo 中的key值
static NSString * const kJYGeoSingleStrengthLevel = @"kJYGeoSingleStrengthLevel";

#endif /* JYGeoLocatedDefine_h */
