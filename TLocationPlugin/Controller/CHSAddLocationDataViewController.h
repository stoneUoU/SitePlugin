//
//  CHSAddLocationDataViewController.h
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/14.
//  Copyright © 2022 TBD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHSLocationModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CHSAddLocationCompletionBlock)(CHSLocationModel *model);

@interface CHSAddLocationDataViewController : UIViewController

@property (nonatomic, copy) CHSAddLocationCompletionBlock addLocationBlock;

@end

NS_ASSUME_NONNULL_END
