//
//  ViewUtils.h
//
//  Version 1.1.2
//
//  Created by Nick Lockwood on 19/11/2011.
//  Copyright (c) 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/ViewUtils
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//


#import <UIKit/UIKit.h>

@interface UIView (ViewUtils)

//nib loading

+ (id)wm_instanceWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)bundleOrNil owner:(id)owner;
- (void)wm_loadContentsWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)bundleOrNil;

//hierarchy

- (UIView *)wm_viewMatchingPredicate:(NSPredicate *)predicate;
- (UIView *)wm_viewWithTag:(NSInteger)tag ofClass:(Class)viewClass;
- (UIView *)wm_viewOfClass:(Class)viewClass;
- (NSArray *)wm_viewsMatchingPredicate:(NSPredicate *)predicate;
- (NSArray *)wm_viewsWithTag:(NSInteger)tag;
- (NSArray *)wm_viewsWithTag:(NSInteger)tag ofClass:(Class)viewClass;
- (NSArray *)wm_viewsOfClass:(Class)viewClass;

- (UIView *)wm_firstSuperviewMatchingPredicate:(NSPredicate *)predicate;
- (UIView *)wm_firstSuperviewOfClass:(Class)viewClass;
- (UIView *)wm_firstSuperviewWithTag:(NSInteger)tag;
- (UIView *)wm_firstSuperviewWithTag:(NSInteger)tag ofClass:(Class)viewClass;

- (BOOL)wm_viewOrAnySuperviewMatchesPredicate:(NSPredicate *)predicate;
- (BOOL)wm_viewOrAnySuperviewIsKindOfClass:(Class)viewClass;
- (BOOL)wm_isSuperviewOfView:(UIView *)view;
- (BOOL)wm_isSubviewOfView:(UIView *)view;

- (UIViewController *)wm_firstViewController;//所属的ViewController

- (UIView *)wm_firstResponder;//第一响应者

//frame accessors

@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic,readonly, assign) CGFloat maxX;
@property (nonatomic,readonly, assign) CGFloat maxY;

//bounds accessors

@property (nonatomic, assign) CGSize boundsSize;
@property (nonatomic, assign) CGFloat boundsWidth;
@property (nonatomic, assign) CGFloat boundsHeight;

//content getters

@property (nonatomic, readonly) CGRect contentBounds;
@property (nonatomic, readonly) CGPoint contentCenter;

//additional frame setters

- (void)wm_setLeft:(CGFloat)left right:(CGFloat)right;
- (void)wm_setWidth:(CGFloat)width right:(CGFloat)right;
- (void)wm_setTop:(CGFloat)top bottom:(CGFloat)bottom;
- (void)wm_setHeight:(CGFloat)height bottom:(CGFloat)bottom;

//animation

- (void)wm_crossfadeWithDuration:(NSTimeInterval)duration;
- (void)wm_crossfadeWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;

@end

