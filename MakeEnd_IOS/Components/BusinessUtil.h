//
//  BusinessUtil.h
//  MakeEnd_IOS
//
//  Created by Rangken on 2014. 5. 22..
//  Copyright (c) 2014년 Nexters. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusinessUtil : NSObject
+ (NSString*)localCodeFromAddress:(NSString*)address;
+ (NSArray*)locationAddressesArray;
@end
