//
//  YXLayoutUtils-Install.h
//  YXLayout
//
//  Created by YourtionGuo on 6/7/16.
//  Copyright © 2016 Yourtion. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Cross Platform
#if TARGET_OS_IPHONE
    #import <UIKit/UIKit.h>
    @compatibility_alias VIEW_CLASS UIView;
#elif TARGET_OS_MAC
    #import <AppKit/AppKit.h>
    @compatibility_alias VIEW_CLASS NSView;
#endif

typedef enum
{
    YXLayoutPriorityRequired = 1000,
    YXLayoutPriorityHigh = 750,
    YXLayoutPriorityDragResizingWindow = 510,
    YXLayoutPriorityMedium = 501,
    YXLayoutPriorityFixedWindowSize = 500,
    YXLayoutPriorityLow = 250,
    YXLayoutPriorityFittingSize = 50,
    YXLayoutPriorityMildSuggestion = 1,
} YXLayoutPriority;

// A few items for my convenience
#define AQUA_SPACE  8
#define AQUA_INDENT 20
#define PREPCONSTRAINTS(VIEW) [VIEW setTranslatesAutoresizingMaskIntoConstraints:NO]


/**
 *  Hierarchy Support
 */
@interface VIEW_CLASS (YXHierarchySupport)

/**
 *  Get superview
 */
@property (nonatomic, readonly) NSArray *yx_superviews;

/**
 *  Get all superview
 */
@property (nonatomic, readonly) NSArray *yx_allSubviews;

/**
 *  Test if the current view has a superview relationship to a view
 *
 *  @param aView view to test
 *
 *  @return has a superview
 */
- (BOOL) yx_isAncestorOf: (VIEW_CLASS *) aView;

/**
 *  Return the nearest common ancestor between self and another view
 *
 *  @param aView view to find ancestor
 *
 *  @return the nearest ancestor view
 */
- (VIEW_CLASS *) yx_nearestCommonAncestor: (VIEW_CLASS *) aView;
@end


/**
 *  Constraint Ready Views
 */
@interface VIEW_CLASS (YXConstraintReadyViews)
/**
 *  Creat a constraint ready view
 *
 *  @return view
 */
+ (instancetype) yx_view;
@end


/**
 *  View Hierarchy
 */
@interface NSLayoutConstraint (YXViewHierarchy)

/**
 *  First view
 */
@property (nonatomic, readonly) VIEW_CLASS *yx_firstView;

/**
 *  Second view
 */
@property (nonatomic, readonly) VIEW_CLASS *yx_secondView;

/**
 *  Are two items involved or not
 */
@property (nonatomic, readonly) BOOL yx_isUnary;

/**
 *  Return NCA
 */
@property (nonatomic, readonly) VIEW_CLASS *yx_likelyOwner;
@end

/**
 *  Self Install
 */
@interface NSLayoutConstraint (YXSelfInstall)
/**
 *  Install constraint
 *
 *  @return Succeed or not
 */
- (BOOL) yx_install;

/**
 *  Set priority and install
 *
 *  @param priority Layout priority
 *
 *  @return Succeed or not
 */
- (BOOL) yx_install: (float) priority;

/**
 *  Remove constraint
 */
- (void) yx_remove;
@end
