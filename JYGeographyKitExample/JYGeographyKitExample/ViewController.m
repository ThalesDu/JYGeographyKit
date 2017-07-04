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
    CLGeocoder *code = [[CLGeocoder alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        JYGeoLocatedRequest * request = [[JYGeoLocatedRequest alloc] initWithType:JYGeoLocatedRequesTypeSubscription
                                                                  desiredAccuracy:JYGeoHorizontalAccuracyThresholdHouse
                                                                  timeOutInterval:60
                                                                       completion:^(CLLocation *location, JYGeoLocatedStatus status) {
                                                                           [code reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                                                                               if (placemarks.count>0) {
                                                                                   CLPlacemark *first =placemarks.firstObject;
                                                                                   NSString *string = first.description;
                                                                                   
                                                                                   NSLog(@"ReGepcodeRespond = %@", string);
                                                                               }
                                                                           }];
        }];
        
        [request resume];
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
