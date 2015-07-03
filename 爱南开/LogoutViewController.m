//
//  LogoutViewController.m
//  iiNankai
//
//  Created by SynCeokhou on 22/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "LogoutViewController.h"
#import <CoreData/CoreData.h>
#import "Login.h"

@interface LogoutViewController ()

@property (weak, nonatomic) IBOutlet UILabel *number;

@end

@implementation LogoutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.number.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"studentID"];
}


- (IBAction)logout {
    [Login logout:self.managedObjectContext];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)cancel {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

@end
