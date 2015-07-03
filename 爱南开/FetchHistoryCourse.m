//
//  FetchHistoryCourse.m
//  爱南开
//
//  Created by SynCeokhou on 30/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "FetchHistoryCourse.h"
#import "Network.h"

@implementation FetchHistoryCourse

+ (void)fetchHistoryPageNum:(NSManagedObjectContext *)managedObjectContext
{
    NSURL *url = [Network URLforFetchHistoryFirst];
    NSURLRequest *URLRequest = [Network HTTPGETRequestForURL:url];
    
    [Network sendDataRequest:URLRequest withCompetionHandler:^(NSData *data, NSError *error) {
        NSDictionary *info = nil;
        if (error) {
            info = [[NSDictionary alloc] initWithObjectsAndKeys:nil,@"fetchedDone",@"yes",@"error",nil];
        }
        else
        {
            NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            NSString *temp = [[NSString alloc] initWithData:data encoding:gbkEncoding];
            NSError *error = NULL;
            NSString *pattern = @"共 (.) 页";
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
            NSTextCheckingResult *match = [regex firstMatchInString:temp options:0 range:NSMakeRange(0, [temp length])];
            NSRange firstHalfRange = [match rangeAtIndex:1];
            NSInteger pages = [[temp substringWithRange:firstHalfRange] integerValue];
            NSLog(@"history: %ld",(long)pages);

            [self analyseContent:managedObjectContext withData:data];
            
            for (NSInteger i=1; i<pages; i++) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [FetchHistoryCourse fetchHistoryCourse:managedObjectContext];
                });
            }
            info = [[NSDictionary alloc] initWithObjectsAndKeys:@"History",@"fetchedDone",nil,@"error",nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fetch"
                                                            object:self
                                                          userInfo:info];
    }];
}


+ (void)fetchHistoryCourse:(NSManagedObjectContext *)managedObjectContext
{
    NSURL *url = [Network URLforFetchHistory];
    NSURLRequest *URLRequest = [Network HTTPGETRequestForURL:url];
    [Network sendDataRequest:URLRequest withCompetionHandler:^(NSData *data, NSError *error) {
        //        NSDictionary *info = nil;
        if (error) {
            //            info = [[NSDictionary alloc] initWithObjectsAndKeys:nil,@"success",[error localizedDescription],@"error",nil];
        }
        else
        {
            if ([self analyseContent:managedObjectContext withData:data]) {
                //                info = [[NSDictionary alloc] initWithObjectsAndKeys:@"yes",@"success",nil,@"error",nil];
            }
            else
            {
                //                info = [[NSDictionary alloc] initWithObjectsAndKeys:nil,@"success",[error localizedDescription],@"error",nil];
            }
        }
    }];
}
            

+ (BOOL)analyseContent:(NSManagedObjectContext *)managedObjectContext withData:(NSData *)data
{
    NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSString *temp = [[NSString alloc] initWithData:data encoding:gbkEncoding];
    NSString *pattern = @"<td [^w>]*>([^\n]*)";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray *matches = [regex matchesInString:temp options:0 range:NSMakeRange(0, [temp length])];
    NSInteger bound = [matches count];
    for (NSInteger i=1; i*8+6<bound; i++) {
        NSRange course_id = [matches[i*8] rangeAtIndex:1];
        NSRange course_name = [matches[i*8+2] rangeAtIndex:1];
        NSRange course_type = [matches[i*8+3] rangeAtIndex:1];
        NSRange course_score = [matches[i*8+4] rangeAtIndex:1];
        NSRange course_credit = [matches[i*8+5] rangeAtIndex:1];
        NSDictionary *course = [[NSDictionary alloc]initWithObjectsAndKeys:
                                [temp substringWithRange:course_id],@"unique",
                                [temp substringWithRange:course_name],@"name",
                                [temp substringWithRange:course_type],@"type",
                                [temp substringWithRange:course_score],@"score",
                                [temp substringWithRange:course_credit],@"credit",
                                nil];
        [History courseIntoDatabase:course inManagedObjectContext:managedObjectContext];
    }
    [managedObjectContext save:NULL];
    return YES;
}

+ (void)evaluateCourse
{
    NSURL *url = [Network URLforTotalEvaluate];
    NSURLRequest *request = [Network HTTPGETRequestForURL:url];
    [Network sendDataRequest:request withCompetionHandler:^(NSData *data, NSError *error) {
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        NSString *temp = [[NSString alloc] initWithData:data encoding:gbkEncoding];
        NSError *rerror = NULL;
        NSString *pattern = @"共 ([0-9]*) 项";
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&rerror];
        NSTextCheckingResult *match = [regex firstMatchInString:temp options:0 range:NSMakeRange(0, [temp length])];
        NSRange firstHalfRange = [match rangeAtIndex:1];
        NSInteger pages = [[temp substringWithRange:firstHalfRange] integerValue];
        NSLog(@"evaluate: %ld",(long)pages);
        NSString *pattern2 =@">(.)评价";
        NSRegularExpression *regex2 = [NSRegularExpression regularExpressionWithPattern:pattern2 options:NSRegularExpressionCaseInsensitive error:&rerror];
        NSArray *match2 = [regex2 matchesInString:temp options:0 range:NSMakeRange(0, [temp length])];
        for (NSInteger i=0; i<pages; i++) {
            NSRange firstHalfRange2 = [match2[i] rangeAtIndex:1];
            if ([[temp substringWithRange:firstHalfRange2] isEqualToString:@"未"]) {
                NSString *evaluatePage = [NSString stringWithContentsOfURL:[Network URLforSingleEvaluate:i] encoding:gbkEncoding error:&error];
                NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:@"Store",@"operation",@"10",@"array[0]",@"10",@"array[1]",@"5",@"array[2]",@"10",@"array[3]",@"5",@"array[4]",@"5",@"array[5]",@"5",@"array[6]",@"10",@"array[7]",@"10",@"array[8]",@"5",@"array[9]",@"5",@"array[10]",@"10",@"array[11]",@"10",@"array[12]",@"blabla",@"opinion",nil];
                NSURL *url = [Network URLforPostEvaluate];
                NSMutableURLRequest *URLRequest = [Network HTTPPOSTRequestForURL:url withParameters:parameters];
                NSString *referer = [NSString stringWithFormat:@"http://222.30.32.10/evaluate/stdevatea/queryTargetAction.do?operation=target&index=%ld",(long)i];
                [URLRequest addValue:@"Referer" forHTTPHeaderField:referer];
                [Network sendDataRequest:URLRequest withCompetionHandler:^(NSData *data, NSError *error) {
                    if (error) {
                        NSLog(@"%@",[error userInfo]);
                    }
                    else
                    {
                        NSLog(@"%lu",(unsigned long)data.length);
                    }
                }];
            } else {
                NSLog(@"%ld:%@",(long)i,[temp substringWithRange:firstHalfRange2]);
            }
        }
    }];
    NSDictionary *info = [[NSDictionary alloc] initWithObjectsAndKeys:@"Evaluate",@"fetchedDone",nil,@"error",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"fetch"
                                                        object:self
                                                      userInfo:info];
}

+ (void)deleteHistoryData:(NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"History" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPropertyValues:NO];
    [request setEntity:entity];
    NSError *error = nil;
    NSArray *datas = [context executeFetchRequest:request error:&error];
    if (!error && datas && [datas count])
    {
        for (NSManagedObject *obj in datas)
        {
            [context deleteObject:obj];
        }
        if (![context save:&error])
        {
            NSLog(@"error:%@",error);
        }
    }
}

@end
