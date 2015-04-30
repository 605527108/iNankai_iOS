//
//  NoticeViewController.m
//  iiNankai
//
//  Created by SynCeokhou on 24/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "NoticeViewController.h"

@interface NoticeViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation NoticeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:@"http://inankai.cn/?cat=14"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

@end
