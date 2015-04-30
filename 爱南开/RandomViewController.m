//
//  RandomViewController.m
//  iiNankai
//
//  Created by SynCeokhou on 25/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "RandomViewController.h"

@interface RandomViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation RandomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

@end
