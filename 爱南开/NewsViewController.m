//
//  NewsViewController.m
//  iiNankai
//
//  Created by SynCeokhou on 23/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "NewsViewController.h"

@interface NewsViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation NewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:@"http://inankai.cn"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

@end
