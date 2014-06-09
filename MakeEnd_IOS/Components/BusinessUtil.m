//
//  BusinessUtil.m
//  MakeEnd_IOS
//
//  Created by Rangken on 2014. 5. 22..
//  Copyright (c) 2014년 Nexters. All rights reserved.
//

#import "BusinessUtil.h"

@implementation BusinessUtil
+ (NSString*)localCodeFromAddress:(NSString*)address{
    if ([address rangeOfString:@"서울"].location != NSNotFound) {
        return @"01";
    }else if ([address rangeOfString:@"부산"].location != NSNotFound) {
        return @"02";
    }else if ([address rangeOfString:@"대구"].location != NSNotFound) {
        return @"03";
    }else if ([address rangeOfString:@"인천"].location != NSNotFound) {
        return @"04";
    }else if ([address rangeOfString:@"광주"].location != NSNotFound) {
        return @"05";
    }else if ([address rangeOfString:@"대전"].location != NSNotFound) {
        return @"06";
    }else if ([address rangeOfString:@"울산"].location != NSNotFound) {
        return @"07";
    }else if ([address rangeOfString:@"세종"].location != NSNotFound) {
        return @"08";
    }else if ([address rangeOfString:@"강원"].location != NSNotFound) {
        return @"09";
    }else if ([address rangeOfString:@"경기"].location != NSNotFound) {
        return @"10";
    }else if ([address rangeOfString:@"경상남도"].location != NSNotFound) {
        return @"11";
    }else if ([address rangeOfString:@"경상북도"].location != NSNotFound) {
        return @"12";
    }else if ([address rangeOfString:@"전라남도"].location != NSNotFound) {
        return @"13";
    }else if ([address rangeOfString:@"전라북도"].location != NSNotFound) {
        return @"14";
    }else if ([address rangeOfString:@"제주"].location != NSNotFound) {
        return @"15";
    }else if ([address rangeOfString:@"충청남도"].location != NSNotFound) {
        return @"16";
    }else if ([address rangeOfString:@"충청북도"].location != NSNotFound) {
        return @"17";
    }
    return @"1";
}
+ (NSArray*)locationAddressesArray{
    return @[@"서울특별시",@"부산광역시",@"대구광역시",
             @"인천광역시",@"광주광역시",@"대전광역시",
             @"울산광역시",@"세종특별자치시",@"강원도",
             @"경기도",@"경상남도",@"경상북도",
             @"전라남도",@"전라북도",@"제주특별자치도",
             @"충청남도",@"충청북도"];
}

@end
