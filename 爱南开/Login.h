//
//  Login.h
//  爱南开
//
//  Created by SynCeokhou on 30/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>



@interface Login : NSObject

@property (nonatomic,strong) UIImage *vadilationImage;

+ (void)fetchImage;

+ (void)signIn:(NSDictionary *)parameters withManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (BOOL)fetchSomePage;

+ (void)logout:(NSManagedObjectContext *)managedObjectContext;

+ (BOOL)updateUserLoggedInFlag:(NSString *)studentID;

+ (BOOL)isLogin;

@end
