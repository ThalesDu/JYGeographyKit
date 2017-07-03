//
//  JYGeoLocatedReachability.h
//  JYGeographyKitExample
//
//  Created by djy on 2017/6/25.
//  Copyright © 2017年 Jiny. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYGeoLocatedDefine.h"
@interface JYGeoLocatedReachability : NSObject

@property (readonly, nonatomic, assign) JYGeoLocatedReachabilityStatus currentStatus; //!< 定位模块的授权状态

@property (readonly, nonatomic, assign) JYGeoGpsSignalStrength currentSignalStrength; //!< 当前的GPS型号强度， 更据定位的精度计算出来的。

@property (readonly, nonatomic, class) JYGeoLocatedReachability *sharedInstance; //!< 当前单例累的实例

@end
