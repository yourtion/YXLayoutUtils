//
//  NSObject-Nametag.m
//  YXLayout
//
//  Created by YourtionGuo on 6/7/16.
//  Copyright © 2016 Yourtion. All rights reserved.
//

#import "YXNSObject-Nametag.h"
@import ObjectiveC;

@implementation NSObject (YXNametags)
- (id) yx_nametag
{
    return objc_getAssociatedObject(self, @selector(yx_nametag));
}

-(void)setYx_nametag:(NSString *)nametag
{
    objc_setAssociatedObject(self, @selector(yx_nametag), nametag, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
@end
