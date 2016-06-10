//
//  YXLayoutUtils-Install.m
//  YXLayout
//
//  Created by YourtionGuo on 6/7/16.
//  Copyright © 2016 Yourtion. All rights reserved.
//

#import "YXLayoutUtils-Install.h"
#pragma mark - Views

#pragma mark - Hierarchy
@implementation VIEW_CLASS (YXHierarchySupport)

// Return an array of all superviews
- (NSArray *) yx_superviews
{
    NSMutableArray *array = [NSMutableArray array];
    VIEW_CLASS *view = self.superview;
    while (view)
    {
        [array addObject:view];
        view = view.superview;
    }
    
    return array;
}

// Return an array of all subviews
- (NSArray *) yx_allSubviews
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (VIEW_CLASS *view in self.subviews)
    {
        [array addObject:view];
        [array addObjectsFromArray:[view subviews]];
    }
    
    return array;
}

// Test if the current view has a superview relationship to a view
- (BOOL) yx_isAncestorOf: (VIEW_CLASS *) aView
{
    return [aView.yx_superviews containsObject:self];
}

// Return the nearest common ancestor between self and another view
- (VIEW_CLASS *) yx_nearestCommonAncestor: (VIEW_CLASS *) aView
{
    // Check for same view
    if (self == aView)
        return self;
    
    // Check for direct superview relationship
    if ([self yx_isAncestorOf:aView])
        return self;
    if ([aView yx_isAncestorOf:self])
        return aView;
    
    // Search for indirect common ancestor
    NSArray *ancestors = self.yx_superviews;
    for (VIEW_CLASS *view in aView.yx_superviews)
        if ([ancestors containsObject:view])
            return view;
    
    // No common ancestor
    return nil;
}
@end

#pragma mark - Constraint-Ready Views
@implementation VIEW_CLASS (YXConstraintReadyViews)
+ (instancetype) yx_view
{
    VIEW_CLASS *newView = [[VIEW_CLASS alloc] initWithFrame:CGRectZero];
    newView.translatesAutoresizingMaskIntoConstraints = NO;
    return newView;
}
@end

#pragma mark - NSLayoutConstraint

#pragma mark - View Hierarchy
@implementation NSLayoutConstraint (YXViewHierarchy)
// Cast the first item to a view
- (VIEW_CLASS *) yx_firstView
{
    return self.firstItem;
}

// Cast the second item to a view
- (VIEW_CLASS *) yx_secondView
{
    return self.secondItem;
}

// Are two items involved or not
- (BOOL) yx_isUnary
{
    return self.secondItem == nil;
}

// Return NCA
- (VIEW_CLASS *) yx_likelyOwner
{
    if (self.yx_isUnary)
        return self.yx_firstView;
    
    return [self.yx_firstView yx_nearestCommonAncestor:self.yx_secondView];
}
@end

#pragma mark - Self Install
@implementation NSLayoutConstraint (YXSelfInstall)
- (BOOL) yx_install
{
    // Handle Unary constraint
    if (self.yx_isUnary)
    {
        // Add weak owner reference
        [self.yx_firstView addConstraint:self];
        return YES;
    }
    
    // Install onto nearest common ancestor
    VIEW_CLASS *view = [self.yx_firstView yx_nearestCommonAncestor:self.yx_secondView];
    if (!view)
    {
        NSLog(@"Error: Constraint cannot be installed. No common ancestor between items.");
        return NO;
    }
    
    [view addConstraint:self];
    return YES;
}

// Set priority and install
- (BOOL) yx_install: (float) priority
{
    self.priority = priority;
    return [self yx_install];
}

- (void) yx_remove
{
    if (![self.class isEqual:[NSLayoutConstraint class]])
    {
        NSLog(@"Error: Can only uninstall NSLayoutConstraint. %@ is an invalid class.", self.class.description);
        return;
    }
    
    if (self.yx_isUnary)
    {
        VIEW_CLASS *view = self.yx_firstView;
        [view removeConstraint:self];
        return;
    }
    
    // Remove from preferred recipient
    VIEW_CLASS *view = [self.yx_firstView yx_nearestCommonAncestor:self.yx_secondView];
    if (!view) return;
    
    // If the constraint not on view, this is a no-op
    [view removeConstraint:self];
}
@end
