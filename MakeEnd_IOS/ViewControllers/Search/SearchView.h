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
- (void)initView;
@property (nonatomic, weak) MainViewController* mainViewCont;
@property (nonatomic, weak) IBOutlet UITableView* tableView;
@end
