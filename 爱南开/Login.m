//
//  Login.m
//  爱南开
//
//  Created by SynCeokhou on 30/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "Login.h"
#import "Network.h"
#import "FetchCurrentCourse.h"
#import "FetchHistoryCourse.h"
#import "User+Database.h"


@implementation Login

+ (void)fetchImage
{
    NSURL *url = [Network URLforFetchImage];
    NSURLRequest *URLRequest = [Network HTTPGETRequestForURL:url];
    [Network sendDownloadRequest:URLRequest withCompetionHandler:^(NSURL *location, NSError *error) {
        NSDictionary *info;
        if (error) {
            NSLog(@"ValidateCode Unresolved error %@, %@", error, [error localizedDescription]);
            info = [[NSDictionary alloc] initWithObjectsAndKeys:nil,@"image",@"bad",@"statusCode",nil];
            
        } else {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
            info = [[NSDictionary alloc] initWithObjectsAndKeys:image,@"image",@"200",@"statusCode",nil];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"validateCode"
                                                            object:self
                                                          userInfo:info];
    }];
}

+ (void)signIn:(NSDictionary *)parameters withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    NSURL *url = [Network URLforSignin];
    NSURLRequest *URLRequest = [Network HTTPPOSTRequestForURL:url withParameters:parameters];
    [Network sendDataRequest:URLRequest withCompetionHandler:^(NSData *data, NSError *error) {
        NSDictionary *info = nil;
        if (error) {
            NSLog(@"SignIn Unresolved error %@, %@", error, [error localizedDescription]);
            info = [[NSDictionary alloc] initWithObjectsAndKeys:nil,@"signIn",[error localizedDescription],@"error",nil];
        }
        else
        {
            if (data.length==LOGIN_SUCC_PAGE_DATA_LENGTH) {
                [self logout:managedObjectContext];
                [self updateUserLoggedInFlag:[parameters objectForKey:@"usercode_text"]];
                info = [[NSDictionary alloc] initWithObjectsAndKeys:@"yes",@"signIn",nil,@"error",nil];
            }
            else
            {
                info = [[NSDictionary alloc] initWithObjectsAndKeys:nil,@"signIn",@"LOGIN_SUCC_LENGTH_NOT_MATCH",@"error",nil];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"signIn"
                                                            object:self
                                                          userInfo:info];
    }];
}


+ (void)logout:(NSManagedObjectContext *)managedObjectContext {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"userLoggedIn"];
    [defaults synchronize];
    [FetchHistoryCourse deleteHistoryData:managedObjectContext];
    [FetchCurrentCourse deleteCurrentData:managedObjectContext];
}


+ (BOOL)updateUserLoggedInFlag:(NSString *)studentID
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"studentID"];
    [defaults setObject:studentID forKey:@"studentID"];
    [defaults setObject:@"yes" forKey:@"userLoggedIn"];
    [defaults synchronize];
    return YES;
}

+ (BOOL)isLogin
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"userLoggedIn"] isEqual:@"yes"];
}

@end
