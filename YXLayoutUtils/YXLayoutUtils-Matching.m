//
//  YXLayoutUtils-Matching.m
//  YXLayoutUtils
//
//  Created by YourtionGuo on 6/7/16.
//  Copyright © 2016 Yourtion. All rights reserved.
//

#import "YXLayoutUtils-Matching.h"

#pragma mark - Named Constraint Support
@implementation VIEW_CLASS (YXNamedConstraintSupport)

// Returns first constraint with matching name
// Type not checked
- (NSLayoutConstraint *) yx_constraintNamed: (NSString *) aName
{
    if (!aName) return nil;
    for (NSLayoutConstraint *constraint in self.constraints)
        if (constraint.yx_nametag && [constraint.yx_nametag isEqualToString:aName])
            return constraint;
    
    // Recurse up the tree
    if (self.superview)
        return [self.superview yx_constraintNamed:aName];
    
    return nil;
}

// Returns first constraint with matching name and view.
// Type not checked
- (NSLayoutConstraint *) yx_constraintNamed: (NSString *) aName matchingView: (VIEW_CLASS *) theView
{
    if (!aName) return nil;
    
    for (NSLayoutConstraint *constraint in self.constraints)
        if (constraint.yx_nametag && [constraint.yx_nametag isEqualToString:aName])
        {
            if (constraint.firstItem == theView)
                return constraint;
            if (constraint.secondItem && (constraint.secondItem == theView))
                return constraint;
        }
    
    // Recurse up the tree
    if (self.superview)
        return [self.superview yx_constraintNamed:aName matchingView:theView];
    
    return nil;
}

// Returns all matching constraints
// Type not checked
- (NSArray *) yx_constraintsNamed: (NSString *) aName
{
    // For this, all constraints match a nil item
    if (!aName) return self.constraints;
    
    // However, constraints have to have a name to match a non-nil name
    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.constraints)
        if (constraint.yx_nametag && [constraint.yx_nametag isEqualToString:aName])
            [array addObject:constraint];
    
    // recurse upwards
    if (self.superview)
        [array addObjectsFromArray:[self.superview yx_constraintsNamed:aName]];
    
    return array;
}

// Returns all matching constraints specific to a given view
// Type not checked
- (NSArray *) yx_constraintsNamed: (NSString *) aName matchingView: (VIEW_CLASS *) theView
{
    // For this, all constraints match a nil item
    if (!aName) return self.constraints;
    
    // However, constraints have to have a name to match a non-nil name
    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in self.constraints)
        if (constraint.yx_nametag && [constraint.yx_nametag isEqualToString:aName])
        {
            if (constraint.firstItem == theView)
                [array addObject:constraint];
            else if (constraint.secondItem && (constraint.secondItem == theView))
                [array addObject:constraint];
        }
    
    // recurse upwards
    if (self.superview)
        [array addObjectsFromArray:[self.superview yx_constraintsNamed:aName matchingView:theView]];
    
    return array;
}
@end

#pragma mark - Constraint Matching
@implementation NSLayoutConstraint (YXConstraintMatching)

// This ignores any priority, looking only at y (R) mx + b
- (BOOL) yx_isEqualToLayoutConstraint: (NSLayoutConstraint *) constraint
{
    // I'm still wavering on these two checks
    if (![self.class isEqual:[NSLayoutConstraint class]]) return NO;
    if (![self.class isEqual:constraint.class]) return NO;
    
    // Compare properties
    if (self.firstItem != constraint.firstItem) return NO;
    if (self.secondItem != constraint.secondItem) return NO;
    if (self.firstAttribute != constraint.firstAttribute) return NO;
    if (self.secondAttribute != constraint.secondAttribute) return NO;
    if (self.relation != constraint.relation) return NO;
    if (self.multiplier != constraint.multiplier) return NO;
    if (self.constant != constraint.constant) return NO;
    
    return YES;
}

// This looks at priority too
- (BOOL) yx_isEqualToLayoutConstraintConsideringPriority:(NSLayoutConstraint *)constraint
{
    if (![self yx_isEqualToLayoutConstraint:constraint])
        return NO;
    
    return (self.priority == constraint.priority);
}

- (BOOL) yx_refersToView: (VIEW_CLASS *) theView
{
    if (!theView)
        return NO;
    if (!self.firstItem) // shouldn't happen. Illegal
        return NO;
    if (self.firstItem == theView)
        return YES;
    if (!self.secondItem)
        return NO;
    return (self.secondItem == theView);
}

- (BOOL) yx_isHorizontal
{
    return YX_IS_HORIZONTAL_ATTRIBUTE(self.firstAttribute);
}
@end

#pragma mark - Managing Matching Constraints
@implementation VIEW_CLASS (YXConstraintMatching)

// Find first matching constraint. (Priority, Archiving ignored)
- (NSLayoutConstraint *) yx_constraintMatchingConstraint: (NSLayoutConstraint *) aConstraint
{
    NSArray *views = [@[self] arrayByAddingObjectsFromArray:self.yx_superviews];
    for (VIEW_CLASS *view in views)
        for (NSLayoutConstraint *constraint in view.constraints)
            if ([constraint yx_isEqualToLayoutConstraint:aConstraint])
                return constraint;
    
    return nil;
}


// Return all constraints from self and subviews
// Call on self.window for the entire collection
- (NSArray *) yx_allConstraints
{
    NSMutableArray *array = [NSMutableArray array];
    [array addObjectsFromArray:self.constraints];
    for (VIEW_CLASS *view in self.subviews)
        [array addObjectsFromArray:[view yx_allConstraints]];
    return array;
}

// Ancestor constraints pointing to self
- (NSArray *) yx_referencingConstraintsInSuperviews
{
    NSMutableArray *array = [NSMutableArray array];
    for (VIEW_CLASS *view in self.yx_superviews)
    {
        for (NSLayoutConstraint *constraint in view.constraints)
        {
            if (![constraint.class isEqual:[NSLayoutConstraint class]])
                continue;
            
            if ([constraint yx_refersToView:self])
                [array addObject:constraint];
        }
    }
    return array;
}

// Ancestor *and* self constraints pointing to self
- (NSArray *) yx_referencingConstraints
{
    NSMutableArray *array = [self.yx_referencingConstraintsInSuperviews mutableCopy];
    for (NSLayoutConstraint *constraint in self.constraints)
    {
        if (![constraint.class isEqual:[NSLayoutConstraint class]])
            continue;
        
        if ([constraint yx_refersToView:self])
            [array addObject:constraint];
    }
    return array;
}

// Find all matching constraints. (Priority, archiving ignored)
// Use with arrays returned by format strings to find installed versions
- (NSArray *) yx_constraintsMatchingConstraints: (NSArray *) constraints
{
    NSMutableArray *array = [NSMutableArray array];
    for (NSLayoutConstraint *constraint in constraints)
    {
        NSLayoutConstraint *match = [self yx_constraintMatchingConstraint:constraint];
        if (match)
            [array addObject:match];
    }
    return array;
}

// All constraints matching view in this ascent
// See also: referencingConstraints and referencingConstraintsInSuperviews
- (NSArray *) yx_constraintsReferencingView: (VIEW_CLASS *) theView
{
    NSMutableArray *array = [NSMutableArray array];
    NSArray *views = [@[self] arrayByAddingObjectsFromArray:self.yx_superviews];
    
    for (VIEW_CLASS *view in views)
        for (NSLayoutConstraint *constraint in view.constraints)
        {
            if (![constraint.class isEqual:[NSLayoutConstraint class]])
                continue;
            
            if ([constraint yx_refersToView:theView])
                [array addObject:constraint];
        }
    
    return array;
}

// Remove constraint
- (void) yx_removeMatchingConstraint: (NSLayoutConstraint *) aConstraint
{
    NSLayoutConstraint *match = [self yx_constraintMatchingConstraint:aConstraint];
    if (match)
        [match yx_remove];
}

// Remove constraints
// Use for removing constraings generated by format
- (void) yx_removeMatchingConstraints: (NSArray *) anArray
{
    for (NSLayoutConstraint *constraint in anArray)
        [self yx_removeMatchingConstraint:constraint];
}

// Remove constraints via name
- (void) yx_removeConstraintsNamed: (NSString *) name
{
    NSArray *array = [self yx_constraintsNamed:name];
    for (NSLayoutConstraint *constraint in array)
        [constraint yx_remove];
}

// Remove named constraints matching view
- (void) yx_removeConstraintsNamed: (NSString *) name matchingView: (VIEW_CLASS *) theView
{
    NSArray *array = [self yx_constraintsNamed:name matchingView:theView];
    for (NSLayoutConstraint *constraint in array)
        [constraint yx_remove];
}
@end
