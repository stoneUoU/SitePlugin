//
//  CHSFetchLocationDataViewController.h
//  CHSLocationPlugin
//
//  Created by stone on 2019/9/4.
//  
//

#import <UIKit/UIKit.h>
#import "CHSLocationModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^CHSFetchLocationDataCompletionBlock)(CHSLocationModel *model);

@interface CHSFetchLocationDataViewController : UIViewController

@end

NS_ASSUME_NONNULL_END
