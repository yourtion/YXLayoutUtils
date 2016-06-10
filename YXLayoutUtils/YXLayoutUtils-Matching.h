//
//  YXLayoutUtils-Matching.h
//  YXLayoutUtils
//
//  Created by YourtionGuo on 6/7/16.
//  Copyright © 2016 Yourtion. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXLayoutUtils-Install.h"
#import "YXNSObject-Nametag.h"

#pragma mark - Testing Constraint Elements

#define YX_IS_SIZE_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeWidth), @(NSLayoutAttributeHeight)] containsObject:@(ATTRIBUTE)]
#define YX_IS_CENTER_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeCenterY)] containsObject:@(ATTRIBUTE)]
#define YX_IS_EDGE_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeTop), @(NSLayoutAttributeBottom), @(NSLayoutAttributeLeading), @(NSLayoutAttributeTrailing), @(NSLayoutAttributeBaseline)] containsObject:@(ATTRIBUTE)]
#define YX_IS_LOCATION_ATTRIBUTE(ATTRIBUTE) (IS_EDGE_ATTRIBUTE(ATTRIBUTE) || IS_CENTER_ATTRIBUTE(ATTRIBUTE))

#define YX_IS_HORIZONTAL_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeLeading), @(NSLayoutAttributeTrailing), @(NSLayoutAttributeCenterX), @(NSLayoutAttributeWidth)] containsObject:@(ATTRIBUTE)]
#define IS_VERTICAL_ATTRIBUTE(ATTRIBUTE) [@[@(NSLayoutAttributeTop), @(NSLayoutAttributeBottom), @(NSLayoutAttributeCenterY), @(NSLayoutAttributeHeight), @(NSLayoutAttributeBaseline)] containsObject:@(ATTRIBUTE)]

#define YX_IS_HORIZONTAL_ALIGNMENT(ALIGNMENT) [@[@(NSLayoutFormatAlignAllLeft), @(NSLayoutFormatAlignAllRight), @(NSLayoutFormatAlignAllLeading), @(NSLayoutFormatAlignAllTrailing), @(NSLayoutFormatAlignAllCenterX), ] containsObject:@(ALIGNMENT)]
#define YX_IS_VERTICAL_ALIGNMENT(ALIGNMENT) [@[@(NSLayoutFormatAlignAllTop), @(NSLayoutFormatAlignAllBottom), @(NSLayoutFormatAlignAllCenterY), @(NSLayoutFormatAlignAllBaseline), ] containsObject:@(ALIGNMENT)]

/*
 NAMED CONSTRAINTS
 Naming makes constraints more self-documenting, enabling you to retrieve
 them by tag. These methods also add an option to find constraints that
 specifically match a certain view.
 */

#pragma mark - Named Constraint Support
@interface VIEW_CLASS (YXNamedConstraintSupport)

// Single
- (NSLayoutConstraint *) yx_constraintNamed: (NSString *) aName;
- (NSLayoutConstraint *) yx_constraintNamed: (NSString *) aName matchingView: (VIEW_CLASS *) view;

// Multiple
- (NSArray *) yx_constraintsNamed: (NSString *) aName;
- (NSArray *) yx_constraintsNamed: (NSString *) aName matchingView: (VIEW_CLASS *) view;
@end

/*
 MATCHING CONSTRAINTS
 Test if one constraint is essentially the same as another.
 This is particularly important when you generate new constraints
 and want to remove their equivalents from another view.
 */

#pragma mark - Constraint Matching
@interface NSLayoutConstraint (YXConstraintMatching)
- (BOOL) yx_isEqualToLayoutConstraint: (NSLayoutConstraint *) constraint;
- (BOOL) yx_isEqualToLayoutConstraintConsideringPriority: (NSLayoutConstraint *) constraint;
- (BOOL) yx_refersToView: (VIEW_CLASS *) aView;
@property (nonatomic, readonly) BOOL yx_isHorizontal;
@end

#pragma mark - Managing Matching Constraints
@interface VIEW_CLASS (YXConstraintMatching)
@property (nonatomic, readonly) NSArray *yx_allConstraints;
@property (nonatomic, readonly) NSArray *yx_referencingConstraintsInSuperviews;
@property (nonatomic, readonly) NSArray *yx_referencingConstraints;

// Retrieving constraints
- (NSLayoutConstraint *) yx_constraintMatchingConstraint: (NSLayoutConstraint *) aConstraint;
- (NSArray *) yx_constraintsMatchingConstraints: (NSArray *) constraints;

// Constraints referencing a given view
- (NSArray *) yx_constraintsReferencingView: (VIEW_CLASS *) view;

// Removing matching constraints
- (void) yx_removeMatchingConstraint: (NSLayoutConstraint *) aConstraint;
- (void) yx_removeMatchingConstraints: (NSArray *) anArray;

// Removing named constraints
- (void) yx_removeConstraintsNamed: (NSString *) name;
- (void) yx_removeConstraintsNamed: (NSString *) name matchingView: (VIEW_CLASS *) view;
@end
