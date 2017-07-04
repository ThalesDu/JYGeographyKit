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
@property (nonatomic, assign) JYGeoHorizontalAccuracy desiredAccuracy;//!< 定位期望的精度。决定耗电量等等因素。但不能保证返回的定位的精度完全比这个高。
@property (nonatomic, assign, readonly) JYGeoLocatedRequesType requestType;//!< 定位的类型，1、单次定位 2、持续定位 3、显著位置变化的监听。
@property (nonatomic, assign, readonly) NSTimeInterval timeOut; //!<  单次定位才有超时时间默认是10s
@property (nonatomic, assign, readonly) BOOL hasTimeOut;
@property (nonatomic, assign) BOOL delayUntilAuthorized;//!<是否在完成授权之后再开始超时计时；

/**
 * @brief 开始定位的方法
 */
- (void) resume;
/**
 * @brief 取消定位的方法。持续定位停止。
 */
- (void) cancel;
/**
 * @brief 强制超时
 */
- (void) forceTimeout;

/**
 * @brief 初始化方法
 * @param requestType 指明定位的类型，包括3中类型：1、单次定位 2、持续定位 3、显著位置变化的监听
 * @param desiredAccuracy 期望的精度范围，当然只是期望，决定耗电量等等因素。但受到GPS模块信号等等因素影响，不能保证返回的定位的精度完全比这个高。
 * @param timeout 超时时间默认10s;
 * @param completeBlock 完成的回调；
 * @return 一个实例；
 */
- (instancetype) initWithType:(JYGeoLocatedRequesType) requestType
              desiredAccuracy:(JYGeoHorizontalAccuracy)desiredAccuracy
              timeOutInterval:(NSTimeInterval) timeout
                   completion:(JYGeoLocatedCompletionBlock) completeBlock NS_DESIGNATED_INITIALIZER ;



@end
