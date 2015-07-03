//
//  FetchCurrentCourse.m
//  爱南开
//
//  Created by SynCeokhou on 30/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "FetchCurrentCourse.h"
#import "Network.h"

@interface FetchCurrentCourse ()
@end

@implementation FetchCurrentCourse

+ (void)fetchCurrentCourse:(NSManagedObjectContext *)managedObjectContext
{
    NSURL *url = [Network URLforFetchCurrent];
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

+ (void)fetchCurrentPageNum:(NSManagedObjectContext *)managedObjectContext
{
    NSURL *url = [Network URLforFetchCurrentFirst];
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
            NSLog(@"current: %ld",(long)pages);
            for (NSInteger i=1; i<pages; i++) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self fetchCurrentCourse:managedObjectContext];
                });
            }
            info = [[NSDictionary alloc] initWithObjectsAndKeys:@"Current",@"fetchedDone",nil,@"error",nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"fetch"
                                                            object:self
                                                          userInfo:info];
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
    NSMutableArray *courses = [[NSMutableArray alloc] init];
    NSInteger flag = 0;
    for (NSInteger i=1; i*13+9<bound; i++) {
        NSRange course_id = [matches[i*13] rangeAtIndex:1];
        NSRange course_number = [matches[i*13+1] rangeAtIndex:1];
        NSRange course_name = [matches[i*13+3] rangeAtIndex:1];
        NSRange course_weekday = [matches[i*13+4] rangeAtIndex:1];
        NSRange course_start = [matches[i*13+5] rangeAtIndex:1];
        NSRange course_end = [matches[i*13+6] rangeAtIndex:1];
        NSRange course_location = [matches[i*13+7] rangeAtIndex:1];
        NSRange course_teacher = [matches[i*13+9] rangeAtIndex:1];
        
        NSDictionary *course = [[NSDictionary alloc]initWithObjectsAndKeys:
                                [temp substringWithRange:course_id],@"unique",
                                [temp substringWithRange:course_number],@"number",
                                [temp substringWithRange:course_name],@"name",
                                [temp substringWithRange:course_weekday],@"weekday",
                                [temp substringWithRange:course_start],@"start",
                                [temp substringWithRange:course_end],@"end",
                                [temp substringWithRange:course_location],@"location",
                                [temp substringWithRange:course_teacher],@"teacher",
                                nil];
        if ([[course objectForKey:@"name"] rangeOfString:@"小学期"].length > 0) {
            [courses removeAllObjects];
            flag = 1;
            continue;
        }
        [courses addObject:course];
    }
    if (flag) {
        [self deleteCurrentData:managedObjectContext];
        flag = 0;
    }
    [Current loadCoursesFromArray:courses intoManagedObjectContext:managedObjectContext];
    [managedObjectContext save:NULL];
    return YES;
}

+ (void)deleteCurrentData:(NSManagedObjectContext *)managedObjectContext
{
    NSManagedObjectContext *context = managedObjectContext;
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Current" inManagedObjectContext:context];
    
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
