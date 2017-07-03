//
//  JYGeoLocatedManager.h
//  JYGeographyKitExample
//
//  Created by djy on 2017/6/24.
//  Copyright © 2017年 Jiny. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JYGeoLocatedDefine.h"

@class JYGeoLocatedRequest;

@interface JYGeoLocatedManager : NSObject
+ (instancetype) sharedInstance;

- (void) locatiedWithRequest:(JYGeoLocatedRequest *) request;
- (void) cancleLocationWithRequest:(JYGeoLocatedRequest *) request;
@end
