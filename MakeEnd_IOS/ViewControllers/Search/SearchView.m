//
//  SearchView.m
//  MakeEnd_IOS
//
//  Created by Rangken on 2014. 5. 28..
//  Copyright (c) 2014년 Nexters. All rights reserved.
//

#import "SearchView.h"
#import "SearchTableViewCell.h"
#import "SearchLocationTableViewCell.h"
#import "MainViewController.h"
#import "BusinessUtil.h"
#import "Manager.h"
@implementation SearchView

- (id) initWithCoder:(NSCoder *)aCoder{
    if(self = [super initWithCoder:aCoder]){
    }
    return self;
}

- (void)initView{
    for (int i=0; i < 100; i++) {
        isOpen[i] = 0;
    }
    _searchDic = [Manager sharedSingleton].searchDic;
    
    _locationArray = [BusinessUtil locationAddressesArray];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup)];
    tapRecognizer.numberOfTapsRequired = 1;
    //tapRecognizer.delegate = self;
    [self.backgroundColorView addGestureRecognizer:tapRecognizer];
    if ([_searchDic count] != 0) {
        
    }
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:_mainViewCont.localCode forKey:@"locCode"];
    [[AFAppDotNetAPIClient sharedClient] postPath:@"MakeEndQuickList.asp" parameters:parameters success:^(AFHTTPRequestOperation *response, id responseObject) {
        NSDictionary* dic = [NSDictionary dictionaryWithXMLData:responseObject];
#ifdef __DEBUG_LOG__
        JY_LOG(@"MakeEndQuickList.asp: %@",[dic objectForKey:@"quicklist"]);
#endif
        NSMutableArray* arr = [dic objectForKey:@"quicklist"];
        if ([arr count] == 0) {
            return ;
        }
        NSString* currentLocationCode = [[arr objectAtIndex:0] objectForKey:@"locationcode"];
        NSMutableArray* currentLocationArr = [NSMutableArray new];
        for (NSDictionary* searchDic in arr) {
            if (![currentLocationCode isEqualToString:[searchDic objectForKey:@"locationcode"]]
                || [searchDic isEqual:[arr lastObject]]) {
                [_searchDic setObject:currentLocationArr forKey:currentLocationCode];
                currentLocationCode = [searchDic objectForKey:@"locationcode"];
                currentLocationArr = [NSMutableArray new];
            }
            [currentLocationArr addObject:searchDic];
        }
        JY_LOG(@"_searchDic count : %ld",[_searchDic count]);
        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation,NSError *error) {
#ifdef __DEBUG_LOG__
        JY_LOG(@"MakeEndQuickList.asp [HTTPClient Error]: %@", error.localizedDescription);
#endif
    }];
}

- (void)dismissPopup {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        [self removeFromSuperview];
    }];
}

#pragma mark UITableViewDelegate UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (isOpen[section]) {
        return 2;
    }
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [_locationArray count];;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    if (indexPath.row == 0) {
        NSString* locationName = [_locationArray objectAtIndex:indexPath.section];
        SearchLocationTableViewCell *cell = (SearchLocationTableViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil){
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SearchLocationTableViewCell" owner:nil options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        //NSDictionary* searchDic = [_searchList objectAtIndex:indexPath.row];
        cell.locationNameLabel.textColor = [UIColor whiteColor];
        cell.locationNameLabel.text = locationName;
        return cell;
    }else{
        NSString* locationName = [_locationArray objectAtIndex:indexPath.section];
        SearchTableViewCell *cell = (SearchTableViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil){
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SearchTableViewCell" owner:nil options:nil];
            cell = [topLevelObjects objectAtIndex:0];
        }
        //NSDictionary* searchDic = [_searchList objectAtIndex:indexPath.row];
        cell.innNameLabel.textColor = [UIColor whiteColor];
        cell.innNameLabel.text = locationName;
        return cell;
    }
    return NULL;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JY_LOG(@"didSelectRowAtIndexPath");
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


@end
