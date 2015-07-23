//
//  MasterViewController.m
//  iiNankai
//
//  Created by SynCeokhou on 5/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "MasterViewController.h"
#import "LoginViewController.h"
#import "HistoryCourseCDTVC.h"
#import "Network.h"
#import "CurrentCourseViewController.h"
#import "LogoutViewController.h"
#import "RandomViewController.h"
#import "Reachability.h"
#import "PostChooseViewController.h"
#import "Login.h"


@interface MasterViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong ,nonatomic) NSTimer *imageTimer;
@property (nonatomic, assign) NSInteger currentImageID;
@property (nonatomic ,strong) NSMutableArray *imageDatas;

@end

@implementation MasterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.image = [UIImage imageNamed:@"nankai_default"];
    
    if ([Network updateUserOnlineFlag]) {
        [self fetchImage];
    }
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer:recognizer];
}


- (IBAction)tapImage:(UITapGestureRecognizer *)sender {
    if ([self.imageDatas count]>0) {
        [self performSegueWithIdentifier:@"Show Random" sender:self.imageView];
    }
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)gesture
{
    if ([self.imageDatas count]>0) {
        if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
            self.currentImageID = (self.currentImageID+1) % [self.imageDatas count];
            [self animationImage:self.currentImageID directionBack:NO];
            [self timerImage];
        } else if(gesture.direction == UISwipeGestureRecognizerDirectionRight) {
            self.currentImageID = (self.currentImageID+[self.imageDatas count]-1) % [self.imageDatas count];
            [self animationImage:self.currentImageID directionBack:YES];
            [self timerImage];
        }
    }
}

- (void)timerImage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.imageTimer invalidate];
        self.imageTimer = nil;
        if ([self.imageDatas count]>0) {
            self.imageTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(timerImageRight:) userInfo:nil repeats:YES];
        }
    });
}

- (void)timerImageRight:(NSTimer *)timer
{
    self.currentImageID = (self.currentImageID+1) % [self.imageDatas count];
    [self animationImage:self.currentImageID directionBack:NO];
}

- (void)displayImage
{
    self.currentImageID = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = [self.imageDatas[self.currentImageID] objectForKey:@"image"];
        [self timerImage];
    });
}

- (void)animationImage:(NSInteger)imageID directionBack:(BOOL)trueOrFalse
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView transitionWithView:self.imageView
                          duration:0.5
                           options:(trueOrFalse? UIViewAnimationOptionTransitionFlipFromLeft:UIViewAnimationOptionTransitionFlipFromRight)
                        animations:^{
                            self.imageView.image = [self.imageDatas[imageID] objectForKey:@"image"];
                        }
                        completion:nil];
    });
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[HistoryCourseCDTVC class]]) {
        HistoryCourseCDTVC *hvc = (HistoryCourseCDTVC *)segue.destinationViewController;
        hvc.managedObjectContext = self.managedObjectContext;
        hvc.title = segue.identifier;
    }
    else if([segue.destinationViewController isKindOfClass:[CurrentCourseViewController class]]) {
        CurrentCourseViewController *cvc = (CurrentCourseViewController *)segue.destinationViewController;
        cvc.managedObjectContext = self.managedObjectContext;
        cvc.title = segue.identifier;
    }
    else if([segue.identifier isEqualToString:@"Show Random"]) {
        RandomViewController *rvc = (RandomViewController *)segue.destinationViewController;
        rvc.urlString = [self.imageDatas[self.currentImageID] objectForKey:@"link"];
    }
    else if([segue.destinationViewController isKindOfClass:[RandomViewController class]]) {
        RandomViewController *rvc = (RandomViewController *)segue.destinationViewController;
        if ([segue.identifier isEqualToString:@"Show Random"]) {
            rvc.urlString = [self.imageDatas[self.currentImageID] objectForKey:@"link"];
        } else if ([segue.identifier isEqualToString:@"Find Classroom"]) {
            rvc.urlString = @"http://inankai.cn/iclass-app/result.php";
        } else if ([segue.identifier isEqualToString:@"Show News"]) {
            rvc.urlString = @"http://inankai.cn";
        } else if ([segue.identifier isEqualToString:@"Show Notice"]) {
            rvc.urlString = @"http://inankai.cn/?cat=14";
        } else if ([segue.identifier isEqualToString:@"Show Event"]) {
            rvc.urlString = @"http://ievent.nankai.edu.cn";
        } else if ([segue.identifier isEqualToString:@"Show Comment"]) {
            rvc.urlString = @"http://inankai.cn/iclass-app/index.php";
        } else if ([segue.identifier isEqualToString:@"Show Ask"]) {
            rvc.urlString = @"http://ask.nankai.edu.cn";
        } else if ([segue.identifier isEqualToString:@"Show Phone"]) {
            rvc.urlString = @"http://inankai.cn/phonebook/";
        } else if ([segue.identifier isEqualToString:@"Show Recruit"]) {
            rvc.urlString = @"http://career.nankai.edu.cn/index.php/Corpinternmsg/index/type/1";
        } else if ([segue.identifier isEqualToString:@"Show Intern"]) {
            rvc.urlString = @"http://career.nankai.edu.cn/index.php/corpinternmsg/index/type/2";
        }
    }
    else if([segue.destinationViewController isKindOfClass:[PostChooseViewController class]]) {
        PostChooseViewController *pvc = (PostChooseViewController *)segue.destinationViewController;
        pvc.managedObjectContext = self.managedObjectContext;
        pvc.title = segue.identifier;
    }
}


- (IBAction)infoButton:(UIBarButtonItem *)sender {
    if ([Login isLogin]) {
        LogoutViewController *logoutViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LogoutViewController"];
        logoutViewController.managedObjectContext = self.managedObjectContext;
        [self.navigationController presentViewController:logoutViewController animated:true completion:nil];
    } else {
        LoginViewController *loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
        loginViewController.managedObjectContext = self.managedObjectContext;
        [self.navigationController presentViewController:loginViewController animated:true completion:nil];
    }
}


- (void)fetchImage
{
    NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://inankai.cn/app/inankai/testslide.php"]];
    NSError *error;
    
    NSMutableArray *urlDatas = [NSJSONSerialization JSONObjectWithData:jsonData options:(NSJSONReadingOptions)NSJSONReadingAllowFragments error:&error];
    
    self.imageDatas = [[NSMutableArray alloc] init];
    
    NSInteger imageNum = [urlDatas count];
    
    for (NSDictionary *urlData in urlDatas)  {
        
        NSURL *url = [NSURL URLWithString:[urlData objectForKey:@"url"]];
        
        NSURLRequest *URLRequest = [Network HTTPGETRequestForURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:URLRequest completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"Image Unresolved error %@, %@", error, [error userInfo]);
            }
            else
            {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                if (httpResponse.statusCode == 200) {
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                    NSMutableDictionary *imageData = [[NSMutableDictionary alloc] initWithObjectsAndKeys:image,@"image",[urlData objectForKey:@"link"],@"link",nil];
                    [self.imageDatas addObject:imageData];
                    if ([self.imageDatas count] ==imageNum) {
                        [self displayImage];
                    }
                }
            }
            
        }];
        [task resume];
    }
}


@end
