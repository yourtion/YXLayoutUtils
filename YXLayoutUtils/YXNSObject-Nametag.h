//
//  NSObject-Nametag.h
//  YXLayout
//
//  Created by YourtionGuo on 6/7/16.
//  Copyright © 2016 Yourtion. All rights reserved.
//

@import Foundation;

// A nametag is an associated string object that can be assigned to any object.
// Similar in intent and nature to UIView/NSView's "tag" property, it allows you to
// assign readable text to objects for annotation and searching.

// If you use in production code, please make sure to add
// namespace indicators to class category methods

@interface NSObject (YXNametags)
@property (nonatomic, strong) NSString *yx_nametag;
@end
