//
//  AskViewController.m
//  iiNankai
//
//  Created by SynCeokhou on 24/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "AskViewController.h"
#import "History.h"

@interface AskViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation AskViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:@"http://ask.nankai.edu.cn"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

@end
