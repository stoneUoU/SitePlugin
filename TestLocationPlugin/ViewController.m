//
//  ViewController.m
//  CHSLocationPlugin
//
//  Created by TBD on 2019/9/5.
//  
//

#import "ViewController.h"
#import "PageManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toExcute:)];
    [self.view addGestureRecognizer:ges];
}

- (void)toExcute:(UIButton *)sender {
    [PageManager.sharedInstance presentViewController:@"CHSFetchLocationDataViewController" withParam:nil inNavigationController:YES animated:YES];
}


@end
