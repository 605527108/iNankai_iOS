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


+ (void)postChoose:(NSDictionary *)parameters
{
    NSURL *url = [Network URLforChoose];
    NSURLRequest *request = [Network HTTPPOSTRequestForURL:url withParameters:parameters];
    [Network sendDataRequest:request withCompetionHandler:^(NSData *data, NSError *error) {
        if (error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShopError"
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
                [Login fetchSomePage];
                NSLog(@"saf");
            }
            else {
                NSString *pattern = @"<font [^w>]*>([^<]*)</font></p>";
                
                NSRange matches = [temp rangeOfString:pattern options:NSRegularExpressionSearch];
                if ([temp substringWithRange:matches].length>0) {
                    NSString *match = [NSString stringWithString:[temp substringWithRange:matches]];
                    NSLog(@"%@",match);
                    NSDictionary *info = nil;
                    if (([match rangeOfString:@"课号已选"].length > 0)||([match rangeOfString:@"时间冲突"].length > 0)||([match rangeOfString:@"4位数字"].length > 0)) {
                        info = [[NSDictionary alloc] initWithObjectsAndKeys:match,@"error",nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"StopTimer"
                                                                            object:self
                                                                          userInfo:info];
                        NSLog(@"Post Fail");
                    }
                    if ([match rangeOfString:@"选修剩余名额不足"].length > 0) {
                        NSLog(@"选修剩余名额不足");
                    }
                }
            }
        }
    }];
}


@end
