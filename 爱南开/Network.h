//
//  Network.h
//  iiNankai
//
//  Created by SynCeokhou on 5/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import <Foundation/Foundation.h>


#define TIME_OUT_INTERVAL 10
#define LOGIN_SUCC_PAGE_DATA_LENGTH 1138




@interface Network : NSObject

+ (NSURL *)URLforSignin;

+ (NSURL *)URLforTotalEvaluate;

+ (NSURL *)URLforChoose;

+ (NSURL *)URLforSingleEvaluate:(NSInteger)index;

+ (NSURL *)URLforPostEvaluate;

+ (NSURL *)URLforFetchImage;

+ (NSURL *)URLforFetchHistory;

+ (NSURL *)URLforFetchHistoryFirst;

+ (NSURL *)URLforFetchCurrent;

+ (NSURL *)URLforFetchCurrentFirst;

+ (NSString *)HTTPBodyWithParameters:(NSDictionary *)parameters;

+ (NSMutableURLRequest *)HTTPGETRequestForURL:(NSURL *)url;

+ (NSMutableURLRequest *)HTTPPOSTRequestForURL:(NSURL *)url withParameters:( NSDictionary *)parameters;

+ (void)sendDataRequest:(NSURLRequest *)request withCompetionHandler:(void (^)(NSData *data,NSError *error))CompetionHandler;

+ (void)sendDownloadRequest:(NSURLRequest *)request withCompetionHandler:(void (^)(NSURL *location,NSError *error))CompetionHandler;

+ (BOOL)isOnline;

+ (BOOL)updateUserOnlineFlag;

@end
