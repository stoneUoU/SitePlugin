//
//  CHSFetchLocationTableViewCell.h
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/14.
//  Copyright © 2022 TBD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHSLocationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CHSFetchLocationTableViewCell : UITableViewCell

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) CHSLocationModel *model;

@end

NS_ASSUME_NONNULL_END
