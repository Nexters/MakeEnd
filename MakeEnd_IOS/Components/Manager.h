//
//  Manager.h
//  MakeEnd_IOS
//
//  Created by Rangken on 2014. 6. 9..
//  Copyright (c) 2014년 Nexters. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Manager : NSObject
{
    
}
@property (nonatomic, strong) NSMutableDictionary* searchDic;
+ (Manager *)sharedSingleton;
@end
