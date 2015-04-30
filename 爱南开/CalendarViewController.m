//
//  CalendarViewController.m
//  iiNankai
//
//  Created by SynCeokhou on 22/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "CalendarViewController.h"

@interface CalendarViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *calendarImage;
@property (nonatomic, assign) NSInteger picNum;

@end

@implementation CalendarViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.picNum = 1;
    UIImage *image = [UIImage imageNamed:@"calendar_1"];
    self.calendarImage.image = image;
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [[self view] addGestureRecognizer:recognizer];
    
    recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [[self view] addGestureRecognizer:recognizer];
}

- (void)handleSwipeFrom:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionUp) {
        if (self.picNum<13) {
            self.picNum = self.picNum +1;
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"calendar_%ld",(long)self.picNum]];
            [UIView transitionWithView:self.calendarImage
                                 duration:0.5
                                  options:UIViewAnimationOptionTransitionCurlUp
                               animations:^{
                                   self.calendarImage.image = image;
                               }
                               completion:nil];
        }
    } else if(gesture.direction == UISwipeGestureRecognizerDirectionDown) {
        if (self.picNum>1) {
            self.picNum = self.picNum - 1;
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"calendar_%ld",(long)self.picNum]];
            [UIView transitionWithView:self.calendarImage
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCurlDown
                            animations:^{
                                self.calendarImage.image = image;
                            }
                            completion:nil];
        }
    }
}

@end
