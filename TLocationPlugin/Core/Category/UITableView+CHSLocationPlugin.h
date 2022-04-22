//
//  UITableView+CHSLocationPlugin.h
//  CHSLocationPlugin
//
//  Created by TBD on 2019/9/8.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (CHSLocationPlugin)

@property (nonatomic, assign, getter=isEditBegining) BOOL editBegining;
@property (nonatomic, assign, getter=isEditEnding) BOOL editEnding;

@end

NS_ASSUME_NONNULL_END
