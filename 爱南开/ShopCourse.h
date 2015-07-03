//
//  ShopCourse.h
//  爱南开
//
//  Created by SynCeokhou on 30/4/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShopCourse : NSObject

@property (nonatomic,strong) NSDictionary *parameters;

+ (void)postChoose:(NSDictionary *)parameters;

@end
