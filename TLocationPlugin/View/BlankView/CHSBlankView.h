//
//  CHSBlankView.h
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/15.
//  Copyright © 2022 TBD. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^CHSBlankViewHandle)(void);

@interface CHSBlankView : UIView

@property (nonatomic, copy) CHSBlankViewHandle handle;

@end

NS_ASSUME_NONNULL_END
