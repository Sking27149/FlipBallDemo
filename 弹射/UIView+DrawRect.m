//
//  UIView+DrawRect.m
//  弹射
//
//  Created by Sking on 16/4/17.
//  Copyright © 2016年 Sking. All rights reserved.
//

#import "UIView+DrawRect.h"

@implementation UIView (DrawRect)

//选择拖动点
- (BOOL)selectPoint:(CGPoint)Point OnCenter:(CGPoint)center
{
    CGRect rect = CGRectMake(center.x - 10, center.y - 10, 20, 20);
    return CGRectContainsPoint(rect, Point);
}
//相对坐标
CGPoint relativeCor(CGPoint point,CGFloat x,CGFloat y){
    return  CGPointMake(point.x + x, point.y + y);
}


@end
