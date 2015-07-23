//
//  LoginViewController.m
//  iNankai
//
//  Created by SynCeokhou on 18/3/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "LoginViewController.h"
#import "Network.h"
#import "User+Database.h"
#import "History+Network.h"
#import "Current+Network.h"
#import "Login.h"
#import "FetchCurrentCourse.h"
#import "FetchHistoryCourse.h"
#import "PostChooseViewController.h"
#import "ShopCourse.h"


@interface LoginViewController () <UITextFieldDelegate , UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *studentIdField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *vadilationField;
@property (weak, nonatomic) IBOutlet UIImageView *vadilationImageView;
@property (nonatomic , strong) UIImage *vadilationImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property(nonatomic, strong) id validateCodeObserver;
@property(nonatomic, strong) id fetchObserver;
@property(nonatomic, strong) id signInObserver;

@end

@implementation LoginViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.studentIdField.delegate = self;
    self.studentIdField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"studentID"];
    self.passwordField.delegate = self;
    self.vadilationField.delegate = self;
    [Login fetchImage];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

- (IBAction)refreshImage:(id)sender {
    [Login fetchImage];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.validateCodeObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"validateCode"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          NSDictionary *info = [note userInfo];
                                                          if ([[info objectForKey:@"statusCode"] isEqual:@"200"]) {
                                                              self.vadilationImage = [info objectForKey:@"image"];
                                                          }
                                                          else
                                                          {
                                                              [self alert:@"验证码获取失败"];
                                                          }
                                                      });
                                                  }];
    self.signInObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"signIn"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self handleSignIn:[note userInfo]];
                                                  }];
    self.fetchObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"fetch"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self handleFetch:[note userInfo]];
                                                  }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self.validateCodeObserver name:@"validateCode" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.signInObserver name:@"signIn" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.fetchObserver name:@"fetch" object:nil];
}


- (void)setVadilationImage:(UIImage *)vadilationImage
{
    self.vadilationImageView.image = vadilationImage;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField==self.studentIdField) {
        [self.passwordField becomeFirstResponder];
    } else if (textField==self.passwordField) {
        [self.vadilationField becomeFirstResponder];
    } else if (textField==self.vadilationField)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)cancel {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)handleSignIn:(NSDictionary *)info
{
    if ([[info objectForKey:@"signIn"] isEqual:@"yes"])
    {
        if ([self.whereWeFrom isEqualToString:@"Post"])
        {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        } else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [FetchCurrentCourse fetchCurrentPageNum:self.managedObjectContext];
            });
        }
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self alert:@"密码或者验证码错了.."];
            [self.spinner stopAnimating];
            [Login fetchImage];
        });
    }
}

- (void)handleFetch:(NSDictionary *)info
{
    if ([[info objectForKey:@"fetchedDone"] isEqualToString:@"Current"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [FetchHistoryCourse evaluateCourse];
        });
    }else if ([[info objectForKey:@"fetchedDone"] isEqualToString:@"Evaluate"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [FetchHistoryCourse fetchHistoryPageNum:self.managedObjectContext];
        });
    }else if ([[info objectForKey:@"fetchedDone"] isEqualToString:@"History"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
        });
    }else if ([[info objectForKey:@"error"] isEqualToString:@"yes"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.spinner stopAnimating];
            [self alert:@"获取课程失败"];
        });
    }
}


- (IBAction)login
{
    if (![self.studentIdField.text length]) {
        [self alert:@"Username required!"];
    } else if (![self.passwordField.text length]) {
        [self alert:@"Password required!"];
    } else if (![self.vadilationField.text length]) {
        [self alert:@"Vadilation required!"];
    } else {
        NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"operation",self.passwordField.text,@"userpwd_text",self.vadilationField.text,@"checkcode_text",@"%C8%B7+%C8%CF",@"submittype",self.studentIdField.text,@"usercode_text",nil];
        [self.spinner startAnimating];
        [Login signIn:parameters withManagedObjectContext:self.managedObjectContext];
    }
}


#pragma mark - Alerts

- (void)alert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Login"
                                message:msg
                               delegate:nil
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)fatalAlert:(NSString *)msg
{
    [[[UIAlertView alloc] initWithTitle:@"Login"
                                message:msg
                               delegate:self // we're going to cancel when dismissed
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

@end
