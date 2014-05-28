//
//  ViewController.m
//  MakeEnd_IOS
//
//  Created by Rangken on 2014. 5. 13..
//  Copyright (c) 2014년 Nexters. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+AnimationCompletion.h"
@interface ViewController ()
@property (nonatomic, strong) IBOutlet UIImageView* splaceImgView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < 26; i++) {
        [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"ploading%04i",i]]];
    }

    _splaceImgView.animationImages = images;
    _splaceImgView.animationDuration = 2.0f;
    _splaceImgView.animationRepeatCount = 1;
    [self.view addSubview:_splaceImgView];
    [_splaceImgView startAnimatingWithCompletionBlock:^(BOOL success){
        _splaceImgView.image = [UIImage imageNamed:@"ploading0025"];
        dispatch_time_t delayime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC));
        dispatch_after(delayime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"GoToMain" sender:NULL];
            });
        });
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
