//
//  TanShe.m
//  弹射
//
//  Created by Sking on 16/4/17.
//  Copyright © 2016年 Sking. All rights reserved.
//

#import "TanShe.h"
#import "UIView+DrawRect.h"
#define H 100
#define X 100
#define kStartPoint CGPointMake(X, self.bounds.size.height - H)
#define kVelocit 0.3
#define kGravity 0.1
#define kRadius 10
#define kDamping 0.8

@interface TanShe ()<UIAlertViewDelegate>


@property (nonatomic, assign) CGPoint birdPoint;
@property (nonatomic, assign) CGPoint endPoint;
@property (nonatomic, assign) CGRect endRect;
@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, assign) BOOL isMoving;

@property (nonatomic, assign) CGFloat Vx;
@property (nonatomic, assign) CGFloat Vy;

@property (nonatomic, weak) CADisplayLink* link;
@property (nonatomic, weak) NSTimer* timer;

@property (nonatomic, strong) NSMutableArray* paths;
@property (nonatomic, strong) NSDate* lastDate;

@property (nonatomic, strong) UIAlertController *alertVC;

@end

static BOOL flag = NO;
static BOOL isBegin = NO;
@implementation TanShe

- (NSMutableArray*)paths
{
    if (!_paths) {
        _paths = [NSMutableArray array];
    }
    return _paths;
}
//-(void)didMoveToSuperview{
//    [self reset];
//    NSLog(@"move to");
//}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self reset];

    UIButton* btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [btn addTarget:self action:@selector(reset) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:btn];

    _birdPoint = kStartPoint;
    //    NSLog(@"%@",NSStringFromCGRect(self.frame));
}

- (void)touchesBegan:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    CGPoint point = [[touches anyObject] locationInView:self];

    _isOn = [self selectPoint:point OnCenter:_birdPoint];
}

- (void)touchesMoved:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    if (isBegin == NO) {
        CGPoint point = [[touches anyObject] locationInView:self];
        
        _birdPoint = _isOn ? point : _birdPoint;
        
        _isMoving = YES;
        [self setNeedsDisplay];
    }
    
}

- (void)touchesEnded:(NSSet<UITouch*>*)touches withEvent:(UIEvent*)event
{
    if (isBegin == NO) {
        if (_isOn) {
            _isMoving = NO;
            _Vx = (kStartPoint.x - _birdPoint.x) * kVelocit;
            _Vy = (kStartPoint.y - _birdPoint.y) * kVelocit;
            
            NSLog(@"vx=%0.2f  vy=%0.2f", _Vx, _Vy);
            //        CADisplayLink* link = [CADisplayLink displayLinkWithTarget:self selector:@selector(move)];
            //        [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            //        _link = link;
            
            NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:1 / 80 target:self selector:@selector(move) userInfo:nil repeats:YES];
            [timer fire];
            _timer = timer;
            _lastDate = [NSDate date];
            isBegin = YES;
        }

    }
        _isOn = NO;
    
}

- (void)move
{

    _Vy += kGravity;

    _birdPoint.x += _Vx;
    _birdPoint.y += _Vy;

    //    NSLog(@"%.2f   %9f  %f",_birdPoint.y,_Vy,self.bounds.size.height - kRadius);
    if (flag == NO) {
        [self check];
    }
    
    [self setNeedsDisplay];
}

- (void)check
{

    //上边界
    if (_birdPoint.y < kRadius) {
        _birdPoint.y = kRadius;
        _Vy = -_Vy * kDamping;
    }

    //下边界
    if (_birdPoint.y >= self.bounds.size.height - kRadius) {
        _birdPoint.y = self.bounds.size.height - kRadius;
        _Vy = -_Vy * kDamping;

        //是否结束
        if (_Vy + kGravity >= 0) {
            [self gameOver];
        }
    }
    //右边界
    if (_birdPoint.x <= kRadius) {
        _birdPoint.x = kRadius;
        _Vx = -_Vx * kDamping;
    }
    //左边界
    if (_birdPoint.x >= self.bounds.size.width - kRadius) {
        _birdPoint.x = self.bounds.size.width - kRadius;
        _Vx = -_Vx * kDamping;
    }

    [self changeDirection];

    if (CGRectContainsPoint(_endRect, _birdPoint)) {
        [self gameOver];
    }
}

- (void)changeDirection
{
    CGRect birdRect = CGRectMake(_birdPoint.x - kRadius, _birdPoint.y - kRadius, 2 * kRadius, 2 * kRadius);

    for (NSValue* rt in self.paths) {

        CGRect rect = [rt CGRectValue];

        if (CGRectIntersectsRect(birdRect, rect)) {

            CGRect interRect = CGRectIntersection(birdRect, [rt CGRectValue]);

            CGFloat interMaxX = CGRectGetMaxX(interRect);
            CGFloat interMaxY = CGRectGetMaxY(interRect);
            CGFloat hinderMaxX = CGRectGetMaxX(rect);
            CGFloat hinderMaxY = CGRectGetMaxY(rect);
            CGFloat birdMaxX = CGRectGetMaxX(birdRect);
            CGFloat birdMaxY = CGRectGetMaxY(birdRect);

            if ((interRect.origin.x == rect.origin.x && interRect.origin.x > birdRect.origin.x) || (interMaxX == hinderMaxX && interMaxX < birdMaxX)) {
                _Vx = -_Vx;
            }
            if ((interRect.origin.y == rect.origin.y && interRect.origin.y > birdRect.origin.y) || (interMaxY == hinderMaxY && interMaxY < birdMaxY)) {
                _Vy = -_Vy;
            }
            break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self reset];
    }
}

- (void)gameOver
{
    NSString* title = @"你输了";
    NSString* subTitle = nil;
    if (self.paths.count == 3 && CGRectContainsPoint(_endRect, _birdPoint)) {
        title = @"你赢了";
        subTitle = [NSString stringWithFormat:@"耗时:%.2f", [[NSDate date] timeIntervalSinceDate:_lastDate]];
    }
    
    [_timer invalidate];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:title message:subTitle delegate:self cancelButtonTitle:@"重新开始" otherButtonTitles:nil, nil];

    [alert show];
    flag = YES;
}

- (void)createHinder
{

    //是否重合
    BOOL notIntersect = YES;
    CGFloat HinderW = self.bounds.size.width * 0.8;
    CGFloat HinderH = self.bounds.size.height;
    CGFloat HinderX = self.bounds.size.width - HinderW;

    //创建目标块
    for (int i = 0; i < 3;) {

        notIntersect = YES;

        CGFloat randomX = arc4random_uniform(10) / 10.0 * HinderW + HinderX;
        CGFloat randomY = arc4random_uniform(10) / 10.0 * HinderH;
        CGFloat randomW = (1 + arc4random_uniform(2)) / 10.0 * HinderW;
        CGFloat randomH = (1 + arc4random_uniform(2)) / 10.0 * HinderH;
        CGFloat lowHeight = HinderH - randomH - randomY;
        
        CGRect rect = CGRectMake(randomX, randomY, randomW, randomH);
        
        for (NSValue* rt in self.paths) {
            if (CGRectIntersectsRect([rt CGRectValue], rect)) {
                notIntersect = NO;
                break;
            }
        }
        if (notIntersect && (lowHeight >= 100)) {

            [self.paths addObject:[NSValue valueWithCGRect:rect]];

            i++;
        }

        [self setNeedsDisplay];
    }
    //    NSLog(@"创建目标块");
    //    创建终点
    do {
        notIntersect = YES;
        _endPoint.x = (4 + arc4random_uniform(6)) / 10.0 * HinderW;
        _endPoint.y = (1 + arc4random_uniform(8)) / 10.0 * HinderH;
        _endRect = CGRectMake(_endPoint.x - 2 * kRadius, _endPoint.y - 2 * kRadius, 4 * kRadius, 4 * kRadius);
        for (NSValue* rt in self.paths) {
            if (CGRectIntersectsRect([rt CGRectValue], _endRect)) {
                notIntersect = NO;
                break;
            }
        }
    } while (!notIntersect);
    //    NSLog(@"创建终点");
}

- (void)reset
{
    isBegin = NO;
    flag = NO;
    [_timer invalidate];
    _Vx = 0;
    _Vy = 0;
    _birdPoint = kStartPoint;
    _paths = nil;
    [_link invalidate];
    [self createHinder];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{

    UIBezierPath* zhijia = [UIBezierPath bezierPath];
    [zhijia moveToPoint:kStartPoint];
    [zhijia addLineToPoint:relativeCor(kStartPoint, 0, H)];
    zhijia.lineWidth = 10;
    [zhijia stroke];

    UIBezierPath* bird = [UIBezierPath bezierPathWithArcCenter:_birdPoint radius:10 startAngle:0 endAngle:2 * M_PI clockwise:1];
    [[UIColor redColor] setFill];
    [bird fill];
    UIBezierPath* end = [UIBezierPath bezierPathWithArcCenter:_endPoint radius:2 * kRadius startAngle:0 endAngle:2 * M_PI clockwise:1];
    [[UIColor blueColor] setFill];
    [end fill];

    for (NSValue* rt in self.paths) {
        UIBezierPath* path = [UIBezierPath bezierPathWithRect:[rt CGRectValue]];

        [[UIColor grayColor] setFill];
        [path fill];
        [path stroke];
    }
    if (_isMoving) {

        [self drawLine];
    }
}

- (void)drawLine
{
    UIBezierPath* line = [UIBezierPath bezierPath];
    [line moveToPoint:_birdPoint];
    CGFloat x = _birdPoint.x;
    CGFloat y = _birdPoint.y;
    _Vx = (kStartPoint.x - _birdPoint.x) * kVelocit;
    _Vy = (kStartPoint.y - _birdPoint.y) * kVelocit;
    for (int i = 0; i < 250; i++) {
        x += _Vx;
        y += _Vy;
        _Vy += kGravity;
        [line addLineToPoint:CGPointMake(x, y)];
        if (x < 0 || x > self.bounds.size.width || y < 0 || y > self.bounds.size.height) {
            _Vx = 0;
            _Vy = 0;
        }
    }
    [line stroke];
}

@end
