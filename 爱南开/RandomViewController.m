//
//  RandomViewController.m
//  iiNankai
//
//  Created by SynCeokhou on 25/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "RandomViewController.h"

@interface RandomViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation RandomViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self.indicator startAnimating];
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self.indicator stopAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.indicator stopAnimating];
}

@end
