//
//  Network.h
//  iiNankai
//
//  Created by SynCeokhou on 5/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import <Foundation/Foundation.h>


#define TIME_OUT_INTERVAL 10




@interface Network : NSObject

+ (NSURL *)URLforSignin;

+ (NSURL *)URLforFetchImage;

+ (NSURL *)URLforFetchHistory;

+ (NSURL *)URLforFetchHistoryFirst;

+ (NSURL *)URLforFetchCurrent;

+ (NSURL *)URLforFetchCurrentFirst;

+ (NSString *)HTTPBodyWithParameters:(NSDictionary *)parameters;

+ (NSURLRequest *)HTTPGETRequestForURL:(NSURL *)url;

+ (NSURLRequest *)HTTPPOSTRequestForURL:( NSURL *)url withParameters:( NSDictionary *)parameters;

+ (void)sendRequest:(NSURLRequest *)request withCompetionHandler:(void (^)(NSData *data,NSError *error))CompetionHandler;
@end
