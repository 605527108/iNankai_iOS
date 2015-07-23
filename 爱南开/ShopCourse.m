//
//  ShopCourse.m
//  爱南开
//
//  Created by SynCeokhou on 30/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "ShopCourse.h"
#import "Network.h"
#import "Login.h"

@interface ShopCourse ()

@end

@implementation ShopCourse


+ (void)postChoose:(NSDictionary *)parameters withContinue:(BOOL)continueOrNot
{
    NSURL *url = [Network URLforChoose];
    NSURLRequest *request = [Network HTTPPOSTRequestForURL:url withParameters:parameters];
    [Network sendDataRequest:request withCompetionHandler:^(NSData *data, NSError *error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shop"
                                                                object:self
                                                              userInfo:[error userInfo]];
        } else {
            NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *temp = [[NSString alloc] initWithData:data encoding:gbkEncoding];
            if (temp.length==4780) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginFirst"
                                                                    object:self
                                                                  userInfo:nil];
            } else if (temp.length==0)
            {
                if ([self fetchSomePage]) {
                    [self postChoose:parameters withContinue:continueOrNot];
                }
            }
            else {
                NSString *pattern = @"<font [^w>]*>([^<]*)</font></p>";
                NSError *error = NULL;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
                NSArray *matches = [regex matchesInString:temp options:0 range:NSMakeRange(0, [temp length])];
                NSInteger bound = [matches count];
                for (NSInteger i=0; i<bound; i++) {
                    NSRange match = [matches[i] rangeAtIndex:1];
                    NSString *matchStr = [NSString stringWithString:[temp substringWithRange:match]];
                    NSDictionary *info = nil;
                    if (([matchStr rangeOfString:@"课号已选"].length > 0)||([matchStr rangeOfString:@"时间冲突"].length > 0)||([matchStr rangeOfString:@"4位数字"].length > 0)) {
                        info = [[NSDictionary alloc] initWithObjectsAndKeys:matchStr,@"error",nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"StopTimer"
                                                                            object:self
                                                                          userInfo:info];
                    }
                    if ([matchStr rangeOfString:@"选修剩余名额不足"].length > 0) {
                        if (!continueOrNot) {
                            info = [[NSDictionary alloc] initWithObjectsAndKeys:matchStr,@"error",nil];
                        } else {
                            info = [[NSDictionary alloc] initWithObjectsAndKeys:@"",@"error",matchStr,@"info",nil];
                        }
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"StopTimer"
                                                                            object:self
                                                                          userInfo:info];
                    }
                }
                if (bound==0) {
                    NSDictionary *info = nil;
                    info = [[NSDictionary alloc] initWithObjectsAndKeys:@"看来选上了",@"error",nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"StopTimer"
                                                                        object:self
                                                                      userInfo:info];
                }
            }
        }
    }];
}

+ (BOOL)fetchSomePage
{
    NSError *error = nil;
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *temp = [NSString stringWithContentsOfURL:[NSURL URLWithString:@"http://222.30.32.10/xsxk/selectMianInitAction.do"] encoding:gbkEncoding error:&error];
    if ([temp rangeOfString:@"选课系统关闭"].length>0||[temp rangeOfString:@"选课时间已过"].length>0) {
        NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:@"选课系统关闭",@"error",nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"shop"
                                                            object:self
                                                          userInfo:info];
        return NO;
    }
    return YES;
}


@end
