//
//  Manager.m
//  MakeEnd_IOS
//
//  Created by Rangken on 2014. 6. 9..
//  Copyright (c) 2014년 Nexters. All rights reserved.
//

#import "Manager.h"

@implementation Manager
+ (Manager *)sharedSingleton{
    static Manager *singletonClass = nil;
    if(singletonClass == nil)
    {
        @synchronized(self)
        {
            if(singletonClass == nil)
            {
                singletonClass = [[self alloc] init];
                [singletonClass initVariable];
            }
        }
    }
    return singletonClass;
}
- (void)initVariable{
    _searchDic = [NSMutableDictionary new];
}
@end
