//
//  HistoryTableViewCell.h
//  iNankai
//
//  Created by SynCeokhou on 19/3/15.
//  Copyright (c) 2015 SynCeokhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "History.h"

@interface HistoryTableViewCell : UITableViewCell

@property (nonatomic,strong) History *course;

- (void)updateUI:(NSString *)name withCredit:(NSString *)credit withScore:(NSString *)score withType:(NSString *)type;

@end
