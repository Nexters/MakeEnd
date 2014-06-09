//
//  SearchView.h
//  MakeEnd_IOS
//
//  Created by Rangken on 2014. 5. 28..
//  Copyright (c) 2014년 Nexters. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MainViewController;
@interface SearchView : UIView
{
    BOOL isOpen[100];
}
- (void)initView;
@property (nonatomic, weak) MainViewController* mainViewCont;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@property (nonatomic, weak) IBOutlet UIView* backgroundColorView;
@property (nonatomic, strong) NSArray* locationArray;
@property (nonatomic, strong) NSMutableDictionary* searchDic;
@end
