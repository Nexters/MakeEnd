//
//  SearchView.m
//  MakeEnd_IOS
//
//  Created by Rangken on 2014. 5. 28..
//  Copyright (c) 2014년 Nexters. All rights reserved.
//

#import "SearchView.h"
#import "SearchTableViewCell.h"
#import "MainViewController.h"
@implementation SearchView

- (id) initWithCoder:(NSCoder *)aCoder{
    if(self = [super initWithCoder:aCoder]){
        
    }
    return self;
}

- (void)initView{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup)];
    tapRecognizer.numberOfTapsRequired = 1;
    //tapRecognizer.delegate = self;
    [self addGestureRecognizer:tapRecognizer];
    NSLog(@"_mainViewCont.localCode : %@",_mainViewCont.localCode);
    NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
    [parameters setObject:_mainViewCont.localCode forKey:@"locCode"];
    [[AFAppDotNetAPIClient sharedClient] postPath:@"MakeEndQuickList.asp" parameters:parameters success:^(AFHTTPRequestOperation *response, id responseObject) {
        NSDictionary* dic = [NSDictionary dictionaryWithXMLData:responseObject];
#ifdef __DEBUG_LOG__
        JY_LOG(@"MakeEndQuickList.asp: %@",[dic objectForKey:@"quicklist"]);
#endif
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
    return 10;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    SearchTableViewCell *cell = (SearchTableViewCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil){
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SearchTableViewCell" owner:nil options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    cell.backgroundColor = [UIColor blackColor];
    cell.backgroundView.alpha = 0.7f;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.text = @"지역지역";
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}


@end
