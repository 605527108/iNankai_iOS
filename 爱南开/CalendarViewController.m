//
//  CalendarViewController.m
//  iiNankai
//
//  Created by SynCeokhou on 22/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "CalendarViewController.h"
#import "Network.h"

@interface CalendarViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *calendarImage;
@property (nonatomic ,strong) NSString *swipeGestureRecognizerDirection;
@property (nonatomic ,strong) NSString *month;
@property(nonatomic, strong) id calendarObserver;

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSDate *today = [NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYYMM"];
    self.month = [dateformatter stringFromDate:today];
    NSLog(@"%@",self.month);
    [self fetchImage:self.month];
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [[self view] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [[self view] addGestureRecognizer:recognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.calendarObserver = [[NSNotificationCenter defaultCenter] addObserverForName:@"calendar"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      NSDictionary *info = [note userInfo];
                                                      [self handleImage:info withDirection:self.swipeGestureRecognizerDirection];
                                                  }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self.calendarObserver name:@"calendar" object:nil];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp) {
        self.swipeGestureRecognizerDirection = @"up";
        NSInteger newYear = [self.month integerValue] /100;
        NSInteger newMonth = ([self.month integerValue] +1) %100;
        if (newMonth > 12) {
            newYear = newYear +1;
            self.month = [NSString stringWithFormat:@"%ld01",(long)newYear];
        } else if(newMonth<10)
        {
            self.month = [NSString stringWithFormat:@"%ld0%ld",(long)newYear,(long)newMonth];
        } else {
            self.month =[NSString stringWithFormat:@"%ld%ld",(long)newYear,(long)newMonth];
        }
        [self fetchImage:self.month];
        NSLog(@"%@",self.month);
    } else if(gesture.direction == UISwipeGestureRecognizerDirectionDown) {
        self.swipeGestureRecognizerDirection = @"down";
        NSInteger newYear = [self.month integerValue] /100;
        NSInteger newMonth = ([self.month integerValue] -1) %100;
        if (newMonth == 0) {
            newYear = newYear -1;
            self.month = [NSString stringWithFormat:@"%ld12",(long)newYear];
        } else if(newMonth<10)
        {
            self.month = [NSString stringWithFormat:@"%ld0%ld",(long)newYear,(long)newMonth];
        } else {
            self.month =[NSString stringWithFormat:@"%ld%ld",(long)newYear,(long)newMonth];
        }
        [self fetchImage:self.month];
        NSLog(@"%@",self.month);
    }
}

- (void)fetchImage:(NSString *)date
{
    NSString *temp = [NSString stringWithFormat:@"http://inankai.cn/app/inankai/calendar/%@",date];
    NSURL *url = [NSURL URLWithString: temp];
    
    NSURLRequest *URLRequest = [Network HTTPGETRequestForURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:URLRequest completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSDictionary *info = nil;
        if (error) {
            NSLog(@"Image Unresolved error %@, %@", error, [error userInfo]);
            info = [[NSDictionary alloc] initWithObjectsAndKeys:nil,@"image",[error localizedDescription],@"error",nil];
        }
        else
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                info = [[NSDictionary alloc] initWithObjectsAndKeys:image,@"image",nil,@"error",nil];
            } else {
                info = [[NSDictionary alloc] initWithObjectsAndKeys:nil,@"image",@"statusCode_NO_200",@"error",nil];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"calendar"
                                                            object:self
                                                          userInfo:info];
    }];
    [task resume];
}

- (void)handleImage:(NSDictionary *)info withDirection:(NSString *)direction
{
    if ([info objectForKey:@"error"]) {
        
    } else {
        if ([direction isEqualToString:@"up"]) {
            [UIView transitionWithView:self.calendarImage
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCurlUp
                            animations:^{
                                self.calendarImage.image = [info objectForKey:@"image"];
                            }
                            completion:nil];
        } else if ([direction isEqualToString:@"down"])
        {
            [UIView transitionWithView:self.calendarImage
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCurlDown
                            animations:^{
                                self.calendarImage.image = [info objectForKey:@"image"];
                            }
                            completion:nil];
        }
        else {
            self.calendarImage.image = [info objectForKey:@"image"];
        }
    }
}


@end
