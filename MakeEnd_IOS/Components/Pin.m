//
//  Pin.m
//  Vobble_IOS
//
//  Created by Rangken on 2014. 2. 25..
//  Copyright (c) 2014년 Nexters. All rights reserved.
//

#import "Pin.h"
@implementation Pin
- (id)initWithCoordinates:(CLLocationCoordinate2D)location
                 withData:(NSDictionary*)dic{
    self = [super init];
    if (self != nil) {
        _coordinate = location;
        _title = [dic objectForKey:@"title"];
        _phoneNumber = [dic objectForKey:@"phoneNumber"];
    }
    return self;
}
- (MKMapItem*)mapItem {
    
    MKPlacemark *placemark = [[MKPlacemark alloc]
                              initWithCoordinate:self.coordinate
                              addressDictionary:NULL];
    
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = self.title;
    
    return mapItem;
}
@end
