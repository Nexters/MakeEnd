//
//  MainViewController.h
//  MakeEnd_IOS
//
//  Created by Rangken on 2014. 5. 13..
//  Copyright (c) 2014년 Nexters. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
@interface MainViewController : UIViewController < CLLocationManagerDelegate, MKMapViewDelegate>
@property (nonatomic, strong) NSString* localCode;
@end
