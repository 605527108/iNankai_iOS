//
//  CurrentCourseViewController.m
//  iiNankai
//
//  Created by SynCeokhou on 17/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "CurrentCourseViewController.h"
#import "LoginViewController.h"
#import "Current.h"

@interface CurrentCourseViewController ()

@property (weak, nonatomic) IBOutlet UIView *courseBoard;
@property (strong,nonatomic) NSArray *courses;

@end

@implementation CurrentCourseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImage *background = [UIImage imageNamed:@"timetable_bg.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:background];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userLoggedIn"]==nil) {
        LoginViewController *loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        loginController.managedObjectContext = self.managedObjectContext;
        [self.navigationController presentViewController:loginController animated:true completion:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userLoggedIn"]) {
        [self loadCourses];
    }
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userLoggedIn"]) {
        [self loadCourses];
    }
}

- (void)loadCourses
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Current"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"unique"
                                                              ascending:YES
                                                               selector:@selector(localizedStandardCompare:)]];
    
    NSError *error;
    self.courses = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (self.courses != nil) {
        NSUInteger count = [self.courses count]; // May be 0 if the object has been deleted.
        NSLog(@"%lu",(unsigned long)count);
    }
    else {
        // Deal with error.
        NSLog(@"%@",error.userInfo);
    }
    for (Current *course in self.courses) {
        
        NSInteger courseLabelID = ([course.weekday integerValue]-1)*6 + ([course.start integerValue]+1)/2;
        NSInteger time = [course.end integerValue] - [course.start integerValue];
        NSString *bgName = [NSString stringWithFormat:@"timetable_%d.png",[course.unique intValue]%7];
        UIImage *background = [UIImage imageNamed:bgName];
        
        UILabel *courseLabel =(UILabel *)[self.courseBoard viewWithTag:courseLabelID];
        courseLabel.text = [NSString stringWithFormat:@"%@@%@",course.name,course.location];
        courseLabel.textColor = [UIColor whiteColor];
        courseLabel.backgroundColor = [UIColor colorWithPatternImage:background];
        if (time==2) {
            courseLabel =(UILabel *)[self.courseBoard viewWithTag:courseLabelID+1];
            courseLabel.text = [NSString stringWithFormat:@"%@@%@",course.name,course.location];
            courseLabel.textColor = [UIColor whiteColor];
            courseLabel.backgroundColor = [UIColor colorWithPatternImage:background];
        }
    }
}

@end
