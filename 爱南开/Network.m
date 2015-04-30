//
//  Network.m
//  iiNankai
//
//  Created by SynCeokhou on 5/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import "Network.h"

@implementation Network

+ (NSURL *)URLforSignin;
{
    return [NSURL URLWithString:@"http://222.30.32.10/stdloginAction.do"];
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

+ (NSURLRequest *)HTTPGETRequestForURL:(NSURL *)url
{
    NSMutableURLRequest *URLRequest = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy: NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:TIME_OUT_INTERVAL];
    [URLRequest setHTTPMethod: @"GET" ];
    [URLRequest HTTPShouldHandleCookies];
    return URLRequest;
}

+ (NSURLRequest *)HTTPPOSTRequestForURL:(NSURL *)url withParameters:(NSDictionary *)parameters
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



+ (void)sendRequest:(NSURLRequest *)request withCompetionHandler:(void (^)(NSData *data,NSError *error))CompetionHandler;
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
                NSError *jsonError;
                NSDictionary *errorDict = [NSJSONSerialization JSONObjectWithData:data options:(NSJSONReadingOptions)NSJSONReadingAllowFragments error:&jsonError];
                NSError *responseError = [[NSError alloc] initWithDomain:@"NetworkError" code:httpResponse.statusCode userInfo:errorDict];
                CompetionHandler(data, responseError);
            }
        }
    }];
    [task resume];
}

@end
