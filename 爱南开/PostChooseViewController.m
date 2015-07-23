//
//  ViewController.m
//  test
//
//  Created by SynCeokhou on 28/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "PostChooseViewController.h"
#import "Network.h"
#import "LoginViewController.h"
#import "ShopCourse.h"

@interface PostChooseViewController () <UITextFieldDelegate , UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *course_1;
@property (weak, nonatomic) IBOutlet UITextField *course_2;
@property (weak, nonatomic) IBOutlet UITextField *course_3;
@property (weak, nonatomic) IBOutlet UITextField *course_4;
@property (weak, nonatomic) IBOutlet UISwitch *chooseAgain;
@property (weak, nonatomic) IBOutlet UISwitch *dualDegree;
@property (strong ,nonatomic) NSTimer *imageTimer;
@property (strong ,nonatomic) NSDictionary *parameters;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic, strong) id LoginFirstObserver;
@property(nonatomic, strong) id StopTimerObserver;
@property(nonatomic, strong) id shopObserver;
@property (weak, nonatomic) IBOutlet UILabel *chooseInfo;

@end

@implementation PostChooseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.course_1.delegate = self;
    self.course_2.delegate = self;
    self.course_3.delegate = self;
    self.course_4.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.LoginFirstObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"LoginFirst"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self stop:nil];
                                                          LoginViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                                                          lvc.whereWeFrom = @"Post";
                                                          lvc.managedObjectContext = self.managedObjectContext;
                                                          [self.navigationController presentViewController:lvc animated:true completion:nil];
                                                      });
                                                  }];
    self.StopTimerObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"StopTimer"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          if ([[[note userInfo] objectForKey:@"error"] isEqualToString:@""]) {
                                                              self.chooseInfo.text = [[note userInfo] objectForKey:@"info"];
                                                          } else {
                                                              [self.spinner stopAnimating];
                                                              [self.imageTimer invalidate];
                                                              self.imageTimer = nil;
                                                              [self alert:[[note userInfo] objectForKey:@"error"]];
                                                          }
                                                      });
                                                  }];
    self.shopObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"shop"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self.spinner stopAnimating];
                                                      [self alert:[[note userInfo] objectForKey:@"error"]];
                                                  }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self.LoginFirstObserver name:@"LoginFirst" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.StopTimerObserver name:@"StopTimer" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.shopObserver name:@"shop" object:nil];
}
- (IBAction)submit:(id)sender {
    if ([self handleParameters]) {
        [self.spinner startAnimating];
        [self postChoose];
    } else {
        [self alert:@"请填选课序号"];
    }
}

- (BOOL)handleParameters
{
    if (([self.course_1.text length]==0)&&([self.course_2.text length]==0)&&([self.course_3.text length]==0)&&([self.course_4.text length]==0)) {
        return NO;
    } else {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.course_1.text,@"xkxh1",self.course_2.text,@"xkxh2",self.course_3.text,@"xkxh3",self.course_4.text,@"xkxh4",@"xuanke",@"operation",@"",@"index",@"%25",@"departIncode",@"",@"courseindex",nil];
        if (self.chooseAgain.on) {
            [parameters setValue:@"selected" forKey:@"xkxh5"];
        }
        if (self.dualDegree.on) {
            [parameters setValue:@"selected" forKey:@"xkxh6"];
        }
        self.parameters = parameters;
    }
    return YES;
}

- (void)postChoose:(NSTimer *)timer
{
    self.chooseInfo.text = @"请等待";
    [ShopCourse postChoose:self.parameters withContinue:YES];
}

- (void)postChoose {
    [ShopCourse postChoose:self.parameters withContinue:NO];
}

- (IBAction)continueSubmit:(id)sender {
    if ([self handleParameters]) {
        [self.spinner startAnimating];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageTimer invalidate];
            self.imageTimer = nil;
            self.imageTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(postChoose:) userInfo:nil repeats:YES];
        });
    } else {
        [self alert:@"请填选课序号"];
    }
}


- (IBAction)stop:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.spinner stopAnimating];
        [self.imageTimer invalidate];
        self.imageTimer = nil;
    });
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Course Shopper"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)fatalAlert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Course Shopper"
                                message:msg
                               delegate:self
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

@end
