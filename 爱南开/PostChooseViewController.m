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

- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserverForName:@"LoginFirst"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          LoginViewController *lvc = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
                                                          lvc.whereWeFrom = @"Post";
                                                          lvc.managedObjectContext = self.managedObjectContext;
                                                          [self.navigationController presentViewController:lvc animated:true completion:nil];
                                                      });
                                                  }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"StopTimer"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      dispatch_async(dispatch_get_main_queue(), ^{
                                                          [self.imageTimer invalidate];
                                                          self.imageTimer = nil;
                                                          [self alert:[[note userInfo] objectForKey:@"error"]];
                                                      });
                                                  }];
    
}

- (IBAction)submit:(id)sender {
    if (([self.course_1.text length]==0)&&([self.course_2.text length]==0)&&([self.course_3.text length]==0)&&([self.course_4.text length]==0)) {
        [self alert:@"请填选课序号"];
    } else {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.course_1.text,@"xkxh1",self.course_2.text,@"xkxh2",self.course_3.text,@"xkxh3",self.course_4.text,@"xkxh4",@"xuanke",@"operation",@"",@"index",@"%25",@"departIncode",@"",@"courseindex",nil];
        if (self.chooseAgain.on) {
            [parameters setValue:@"selected" forKey:@"xkxh5"];
        }
        if (self.dualDegree.on) {
            [parameters setValue:@"selected" forKey:@"xkxh6"];
        }
        self.parameters = parameters;
        [self postChoose];
    }
    
}

- (void)postChoose:(NSTimer *)timer
{
    [self postChoose];
}

- (void)postChoose {
    [ShopCourse postChoose:self.parameters];
}

- (IBAction)continueSubmit:(id)sender {
    if (([self.course_1.text length]==0)&&([self.course_2.text length]==0)&&([self.course_3.text length]==0)&&([self.course_4.text length]==0)) {
        [self alert:@"请添加选课序号"];
    } else {
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:self.course_1.text,@"xkxh1",self.course_2.text,@"xkxh2",self.course_3.text,@"xkxh3",self.course_4.text,@"xkxh4",@"xuanke",@"operation",@"",@"index",@"%25",@"departIncode",@"",@"courseindex",nil];
        if (self.chooseAgain.on) {
            [parameters setValue:@"selected" forKey:@"xkxh5"];
        }
        if (self.dualDegree.on) {
            [parameters setValue:@"selected" forKey:@"xkxh6"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.imageTimer invalidate];
            self.imageTimer = nil;
            self.imageTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(postChoose:) userInfo:nil repeats:YES];
        });
    }
}



- (IBAction)stop:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
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
                               delegate:self // we're going to cancel when dismissed
                      cancelButtonTitle:nil
                      otherButtonTitles:@"OK", nil] show];
}

@end
