//
//  YQCalendarCell.m
//  YQCalendar
//
//  Created by Wang on 15/8/20.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "YQCalendarCell.h"
#import <DateTools.h>
#import "YQCalendarAppearence.h"


static NSString *const AnimationKey = @"CircleScaleKey";
@interface YQCalendarCell ()
@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) CAShapeLayer *textCircleLayer;
@property (strong, nonatomic) UIView *flagDot;
@end

@implementation YQCalendarCell

- (instancetype)init{
    if(self == [super init]){
        [self prepare];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self prepare];
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

#pragma mark self handler
- (void)prepare{
    
    _textCircleLayer = [CAShapeLayer layer];
    self.textCircleLayer.contentsScale = [UIScreen mainScreen].scale;
    self.textCircleLayer.rasterizationScale = 2.0 * [UIScreen mainScreen].scale;
    self.textCircleLayer.shouldRasterize = YES;
    self.textCircleLayer.hidden = YES;
    self.textCircleLayer.frame = self.bounds;
    [self.layer insertSublayer:self.textCircleLayer atIndex:0];
    
    _flagDot = [[UIView alloc] init];
    self.flagDot.frame = CGRectMake(0, 0, [YQCalendarAppearence share].cellFlagDotDiameter, [YQCalendarAppearence share].cellFlagDotDiameter);
    self.flagDot.layer.cornerRadius = [YQCalendarAppearence share].cellFlagDotDiameter/2;
    self.flagDot.hidden = YES;
    [self.contentView addSubview:self.flagDot];
    
    _dateLabel = [[UILabel alloc] init];
    self.dateLabel.textAlignment = NSTextAlignmentCenter;
    self.dateLabel.textColor = [YQCalendarAppearence share].cellTextNormalColor;
    self.dateLabel.font = [YQCalendarAppearence share].cellTextFont;
    [self.contentView addSubview:self.dateLabel];
    
}
- (void)selectWithAnimation:(BOOL)animate{
    
    self.textCircleLayer.fillColor = [YQCalendarAppearence share].cellTextCircleNormalColor.CGColor;
    self.dateLabel.textColor = [YQCalendarAppearence share].cellTextSelectColor;
    self.textCircleLayer.hidden = NO;
    self.flagDot.backgroundColor = [YQCalendarAppearence share].cellFlagDotSelectColor;
    if(animate){
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = 0.20; // 动画持续时间
        animation.repeatCount = 1; // 重复次数
        animation.fromValue = [NSNumber numberWithFloat:0.3];
        animation.toValue = [NSNumber numberWithFloat:1.0];
        [self.textCircleLayer addAnimation:animation forKey:AnimationKey];
    }
}

#pragma mark override

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.dateLabel sizeToFit];
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    self.dateLabel.center = center;
 
    self.flagDot.center = CGPointMake(self.dateLabel.center.x, CGRectGetMaxY(self.dateLabel.frame)+[YQCalendarAppearence share].cellFlagDotTextBottomSpace+CGRectGetMinY(self.flagDot.bounds));
    
    CGFloat side = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds))*[YQCalendarAppearence share].cellTextCircleScale;
    self.textCircleLayer.frame = self.bounds;
    self.textCircleLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:side/2 startAngle:0 endAngle:2*M_PI clockwise:YES].CGPath;
    DDLogDebug(@"调整");
}

- (void)prepareForReuse{
    [CATransaction setDisableActions:YES];//这样可以禁止隐式动画，在滑动不会出现影子
    self.textCircleLayer.hidden = YES;
    self.flagDot.hidden = YES;
}

- (void)setModel:(YQCellModel *)model{
    if(_model != model){
        _model = model;
    }
    //1.为了显示信息保证最新，不能在条件判断内执行
    //2.添加文字之后是不会调用sizeToFit的，导致复用情况下有些label显示不全文字
    self.dateLabel.text = [@(self.model.date.day) stringValue];
    [self.dateLabel sizeToFit];
    [CATransaction setDisableActions:NO];
    [self reset];
}

#pragma mark public
- (void)reset{
    switch (self.model.dateType) {
        case YQDateTypePreMonth:{
            self.textCircleLayer.hidden = YES;
            self.dateLabel.textColor = [YQCalendarAppearence share].cellTextOtherMonthColor;
            self.flagDot.backgroundColor = [YQCalendarAppearence share].cellFlagDotNormalColor;
        }
            break;
        case YQDateTypeCurrentMoth:{
            self.textCircleLayer.hidden = YES;
            self.dateLabel.textColor = [YQCalendarAppearence share].cellTextNormalColor;
            self.flagDot.backgroundColor = [YQCalendarAppearence share].cellFlagDotNormalColor;
        }
            break;
        case YQDateTypeToday:{
            self.textCircleLayer.hidden = NO;
            self.textCircleLayer.fillColor = [YQCalendarAppearence share].cellTextCircleTodayColor.CGColor;
            self.dateLabel.textColor = [YQCalendarAppearence share].cellTextTodayColor;
            self.flagDot.backgroundColor = [YQCalendarAppearence share].cellFlagDotTodayColor;
        }
            break;
        case YQDateTypeNextMonth:{
            self.textCircleLayer.hidden = YES;
            self.dateLabel.textColor = [YQCalendarAppearence share].cellTextOtherMonthColor;
            self.flagDot.backgroundColor = [YQCalendarAppearence share].cellFlagDotNormalColor;
        }
            break;
        default:
            break;
    }

}

- (void)highlight{
    
}
- (void)select{
    [self selectWithAnimation:YES];
}

- (void)showFlagDot:(BOOL)show{
    self.flagDot.hidden = !show;
}
@end
