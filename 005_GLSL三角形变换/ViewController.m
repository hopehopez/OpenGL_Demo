//
//  ViewController.m
//  003_GLSL
//
//  Created by zsq on 2020/7/31.
//  Copyright © 2020 zsq. All rights reserved.
//

#import "ViewController.h"
#import "CCView.h"
@interface ViewController ()
@property(nonnull,strong)CCView *myView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.myView = (CCView *)self.view;
}


@end
