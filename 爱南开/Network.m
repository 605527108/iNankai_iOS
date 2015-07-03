//
//  Network.m
//  iiNankai
//
//  Created by SynCeokhou on 5/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "Network.h"
#import "Reachability.h"


@implementation Network


#pragma mark - URL

+ (NSURL *)URLforSignin;
{
    return [NSURL URLWithString:@"http://222.30.32.10/stdloginAction.do"];
}

+ (NSURL *)URLforTotalEvaluate;
{
    return [NSURL URLWithString:@"http://222.30.32.10/evaluate/stdevatea/queryCourseAction.do"];
}

+ (NSURL *)URLforSingleEvaluate:(NSInteger)index;
{
    NSString *url = [NSString stringWithFormat:@"http://222.30.32.10/evaluate/stdevatea/queryTargetAction.do?operation=target&index=%ld",(long)index];
    return [NSURL URLWithString:url];
}

+ (NSURL *)URLforChoose;
{
    return [NSURL URLWithString:@"http://222.30.32.10/xsxk/swichAction.do"];
}

+ (NSURL *)URLforPostEvaluate;
{
    return [NSURL URLWithString:@"http://222.30.32.10/evaluate/stdevatea/queryTargetAction.do"];
}

+ (NSURL *)URLforFetchImage;
{
    return [NSURL URLWithString:@"http://222.30.32.10/ValidateCode"];
}

+ (NSURL *)URLforFetchHistoryFirst;
{
    return [NSURL URLWithString:@"http://222.30.32.10/xsxk/studiedAction.do"];
}

+ (NSURL *)URLforFetchHistory;
{
    return [NSURL URLWithString:@"http://222.30.32.10/xsxk/studiedPageAction.do?page=next"];
}

+ (NSURL *)URLforFetchCurrent;
{
    return [NSURL URLWithString:@"http://222.30.32.10/xsxk/selectedPageAction.do?page=next"];
}

+ (NSURL *)URLforFetchCurrentFirst;
{
    return [NSURL URLWithString:@"http://222.30.32.10/xsxk/selectedAction.do"];
}


#pragma mark - build request

+ (NSMutableURLRequest *)HTTPGETRequestForURL:(NSURL *)url
{
    NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIME_OUT_INTERVAL];
    [URLRequest setHTTPMethod: @"GET" ];
    [URLRequest HTTPShouldHandleCookies];
    return URLRequest;
}

+ (NSMutableURLRequest *)HTTPPOSTRequestForURL:(NSURL *)url withParameters:(NSDictionary *)parameters
{
    NSMutableURLRequest *URLRequest = [[ NSMutableURLRequest alloc ] initWithURL :url cachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval: TIME_OUT_INTERVAL ];
    NSString *HTTPBodyString = [self HTTPBodyWithParameters :parameters];
    [URLRequest setHTTPBody :[HTTPBodyString dataUsingEncoding : NSUTF8StringEncoding ]];
    [URLRequest setHTTPMethod : @"POST" ];
    [URLRequest HTTPShouldHandleCookies];
    return URLRequest;
}

+ (NSString *)HTTPBodyWithParameters:(NSDictionary *)parameters
{
    NSMutableArray *parametersArray = [[NSMutableArray alloc] init];
    for (NSString *key in [parameters allKeys]) {
        id value = [parameters objectForKey:key];
        if ([value isKindOfClass:[NSString class]]) {
            [parametersArray addObject:[NSString stringWithFormat:@"%@=%@",key,value]];
        }
    }
    return [parametersArray componentsJoinedByString: @"&" ];
}



#pragma mark - send request

+ (void)sendDataRequest:(NSURLRequest *)request withCompetionHandler:(void (^)(NSData *data,NSError *error))CompetionHandler;
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error) {
            CompetionHandler(data,error);
        }
        else
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                CompetionHandler(data,nil);
            }
            else
            {
                NSError *statusError = [[NSError alloc] initWithDomain:@"statusCodeNotEqualTo200" code:httpResponse.statusCode userInfo:httpResponse.allHeaderFields];
                CompetionHandler(nil,statusError);
            }
        }
    }];
    [task resume];
}

+ (void)sendDownloadRequest:(NSURLRequest *)request withCompetionHandler:(void (^)(NSURL *location,NSError *error))CompetionHandler;
{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if (error) {
            CompetionHandler(nil,error);
        }
        else
        {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            if (httpResponse.statusCode == 200) {
                CompetionHandler(location,nil);
            }
            else
            {
                NSError *statusError = [[NSError alloc] initWithDomain:@"statusCodeNotEqualTo200" code:httpResponse.statusCode userInfo:httpResponse.allHeaderFields];
                CompetionHandler(nil,statusError);
            }
        }
    }];
    [task resume];
}


#pragma mark - update flag

+ (BOOL)updateUserOnlineFlag
{
    Reachability *wifi = [Reachability reachabilityForLocalWiFi];
    Reachability *conn = [Reachability reachabilityForInternetConnection];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"online" forKey:@"online"];
    [defaults synchronize];
    
    if (([wifi currentReachabilityStatus] != NotReachable) &&([conn currentReachabilityStatus] != NotReachable)) {
        [defaults setObject:@"online" forKey:@"online"];
        [defaults synchronize];
        return YES;
    }
    [defaults setObject:@"offline" forKey:@"online"];
    [defaults synchronize];
    return NO;
   
}

+ (BOOL)isOnline
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"online"]==nil;
}

@end
