//
//  HistoryTableViewCell.m
//  iNankai
//
//  Created by SynCeokhou on 19/3/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "HistoryTableViewCell.h"

@interface HistoryTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UILabel *courseType;
@property (weak, nonatomic) IBOutlet UILabel *courseCredit;
@property (weak, nonatomic) IBOutlet UIImageView *courseImage;
@property (weak, nonatomic) IBOutlet UILabel *courseScore;
@property (weak, nonatomic) IBOutlet UIImageView *coursePass;

@end


@implementation HistoryTableViewCell

- (void)setCourse:(History *)course
{
    self.course = course;
    NSLog(@"%@",course);
//    [self updateUI];
}

//- (void)updateUI
//{
//    float score = [self.course.score floatValue];
//    if (score>=60) {
//        self.coursePass.image =[UIImage imageNamed:@"history_pass"];
//    } else {
//        self.coursePass.image = [UIImage imageNamed:@"history_no_pass"];
//    }
//    self.courseImage.image = [UIImage imageNamed:[NSString stringWithFormat:@"history_%@",self.course.type]];
//    
//    
//    self.courseName.text = self.course.name;
//    self.courseCredit.text = self.course.credit;
//    self.courseScore.text = self.course.score;
//    self.courseType.text = self.course.type;
//}

- (void)updateUI:(NSString *)name withCredit:(NSString *)credit withScore:(NSString *)score withType:(NSString *)type
{
    NSString *imageName;
    if ([type rangeOfString:@"A"].length > 0) {
        imageName = @"history_A";
    } else if ([type rangeOfString:@"B"].length > 0) {
        imageName = @"history_B";
    } else if ([type rangeOfString:@"C"].length > 0) {
        imageName = @"history_C";
    } else if ([type rangeOfString:@"D"].length > 0) {
        imageName = @"history_D";
    } else if ([type rangeOfString:@"E"].length > 0) {
        imageName = @"history_E";
    } else {
        imageName = @"history_E";
    }
    
    self.courseName.text = name;
    self.courseCredit.text = credit;
    self.courseScore.text = score;
    self.courseType.text = type;
    NSLog(@"%@",score);
    if ([score floatValue]>=60 || [score rangeOfString:@"通过"].length > 0) {
        self.coursePass.image =[UIImage imageNamed:@"history_pass"];
    } else {
        self.coursePass.image = [UIImage imageNamed:@"history_no_pass"];
    }
    self.courseImage.image = [UIImage imageNamed:imageName];
}


@end
