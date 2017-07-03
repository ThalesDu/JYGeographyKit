//
//  ViewController.m
//  JYGeographyKitExample
//
//  Created by djy on 2017/6/23.
//  Copyright © 2017年 Jiny. All rights reserved.
//

#import "ViewController.h"
#import "JYGeoLocatedHeader.h"
#import <MapKit/MapKit.h>
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        JYGeoLocatedRequest * request = [[JYGeoLocatedRequest alloc] initWithType:JYGeoLocationRequestTypeSignificantChanges
                                                                  desiredAccuracy:JYGeoHorizontalAccuracyThresholdHouse
                                                                  timeOutInterval:60
                                                                       completion:^(CLLocation *location, JYGeoLocatedStatus status) {
            NSLog(@"located At location :%@  state : %ld",location, (long)status);
        }];
        
        [request resume];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
