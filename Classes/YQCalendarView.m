//
//  YQCalendarView.m
//  YQCalendar
//
//  Created by Wang on 15/8/28.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "YQCalendarView.h"
#import "YQCalendarWeekLabel.h"
#import <POP.h>

static NSString *const ContentInsetAnimation = @"ContentInsetAnimation";

typedef NS_ENUM(NSUInteger, YQScrollState) {
    YQScrollStateDefault,
    YQScrollStateWillUp,
    YQScrollStateWillDown,
};

@implementation UIScrollView (YQCalendar)

//- (void)setCalendarScrollDelegate:(id<YQCalendarScrollDelegate>)calendarScrollDelegate{
//    objc_setAssociatedObject(self, @selector(calendarScrollDelegate), calendarScrollDelegate, OBJC_ASSOCIATION_ASSIGN);
//}
//- (id<YQCalendarScrollDelegate>)calendarScrollDelegate{
//    return objc_getAssociatedObject(self, _cmd);
//}

- (void)addCalendarView:(YQCalendarView *)calendarView{
    if(calendarView){
        calendarView.frame = CGRectOffset(calendarView.frame, 0, -CGRectGetHeight(calendarView.bounds)+self.contentInset.top);
        self.contentInset = UIEdgeInsetsMake(self.contentInset.top+CGRectGetHeight(calendarView.bounds), 0, 0, 0);
        calendarView.scrollView = self;
        [self addSubview:calendarView];
    }
}

@end



@interface YQCalendarView ()<YQCalendarDelegate>

@property (nonatomic, strong) YQCalendar *weekCalendar;
@property (nonatomic, strong) YQCalendar *monthCalendar;
//@property (nonatomic, strong) YQCalendarWeekLabel *weekLabel;

@property (nonatomic, assign) CGFloat criticalOriginY;
@property (nonatomic, assign) CGFloat begeinDragOffset;
@property (nonatomic, assign) CGFloat minInsetTop;
@property (nonatomic, assign) CGFloat originalInsetTop;
@property (nonatomic, assign) CGFloat minMoveDistance;
@property (nonatomic, assign) YQScrollState scrollState;

@end

@implementation YQCalendarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init{
    if(self = [super init]){
        [self prepareView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if(self == [super initWithFrame:frame]){
        [self prepareView];
    }
    return self;
}
- (void)awakeFromNib{
    [self prepareView];
}
- (void)prepareView{
    
//    self.weekLabel = [[YQCalendarWeekLabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), HeightWeekLabel)];
//    [self addSubview:self.weekLabel];
    self.monthCalendar = [[YQCalendar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) mode:YQCalendarModeMonth];
    self.weekCalendar = [[YQCalendar alloc] initWithFrame:CGRectMake(0,  0, self.bounds.size.width, CGRectGetHeight(self.monthCalendar.bounds)/RowCountMonthMode) mode:YQCalendarModeWeek];

    
    self.weekCalendar.hidden = YES;
    
    self.monthCalendar.delegate = self;
    self.weekCalendar.delegate = self;
    [self addSubview:self.monthCalendar];
    
    NSDate *date = [NSDate date];
    [self.monthCalendar scrollToDate:date];
    [self.weekCalendar scrollToDate:date];
    
    self.originalInsetTop = self.scrollView.contentInset.top;
    self.minInsetTop = CGRectGetMaxY(self.weekCalendar.frame);

}


#pragma mark override
-(void)layoutSubviews{
    [super layoutSubviews];
    self.originalInsetTop = self.scrollView.contentInset.top;
    self.minInsetTop = CGRectGetHeight(self.weekCalendar.bounds);
    self.weekCalendar.frame = CGRectMake(CGRectGetMinX(self.scrollView.frame), CGRectGetMinY(self.scrollView.frame), self.scrollView.frame.size.width, self.weekCalendar.frame.size.height);
    self.minMoveDistance = CGRectGetHeight(self.weekCalendar.frame)/2;
}
- (void)willMoveToSuperview:(UIView *)newSuperview{
//    [newSuperview addSubview:self.weekCalendar];
    [self.scrollView.superview addSubview:self.weekCalendar];
    
    
}
#pragma mark calendar delegate
- (void)calendar:(YQCalendar *)calendar didSelectDate:(NSDate *)date{
    
    if(calendar == self.monthCalendar){
//        [self.weekCalendar setSelectedDate:date];
        [self.weekCalendar scrollToDate:date];
    }else{
//        [self.monthCalendar setSelectedDate:date];
        [self.monthCalendar scrollToDate:date];
    }
}
- (void)calendar:(YQCalendar *)calendar didChangeMonth:(NSDate *)date{
    if(calendar == self.monthCalendar){
        [self.weekCalendar scrollToDate:date];
    }else if(calendar == self.weekCalendar){
        [self.monthCalendar scrollToDate:date];
    }
}

#pragma mark calendarScroll delegate
- (void)calendarScrollViewDidScroll:(UIScrollView *)scrollView{
    
    if(scrollView.isDragging || scrollView.isDecelerating){
        if(scrollView.contentOffset.y >= -self.originalInsetTop && scrollView.contentOffset.y <= -self.minInsetTop){
            [scrollView setContentInset:UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)];
        }
        [self checkWeekCalendarShouldShowBySelf:self];
    }

}
- (void)calendarScrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(self.weekCalendar.hidden){
        self.criticalOriginY = self.monthCalendar.targetRowOriginY+CGRectGetMinY(self.frame);
    }else{
        self.criticalOriginY = self.weekCalendar.targetRowOriginY+CGRectGetMinY(self.frame);
    }
    self.begeinDragOffset = scrollView.contentOffset.y;

}
- (void)calendarScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{

    if(!decelerate){
        [self checkChangeMode];
    }
}
- (void)calendarScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    //如果往上滑目标到不了最高边界，直接到最低边界
   
    if(velocity.y > 0){//往上，如果是回弹效果的话，不是往上是往下
        NSLog(@"减速 将要往上");
        //如果当前在最低以下，目标位置不管在哪都到最高处 当然移动范围得超过阀值
        if(scrollView.contentOffset.y <= -self.minInsetTop){
            CGFloat distance = self.scrollView.contentOffset.y-self.begeinDragOffset;
            if(distance > self.minMoveDistance){
                //移动到最高处
                self.scrollState = YQScrollStateWillUp;
            }else{
                //移动到最低处
                self.scrollState = YQScrollStateWillDown;
            }
        }
        
    }else if(velocity.y < 0){
        NSLog(@"减速 将要往下");
        if(scrollView.contentOffset.y >= -self.originalInsetTop){
            
            CGFloat distance = self.scrollView.contentOffset.y-self.begeinDragOffset;
            if(scrollView.contentOffset.y <= -self.minInsetTop){//脱手点在最高线和最低线之间
                if(-distance > self.minMoveDistance){
                    //移到最低处
                    self.scrollState = YQScrollStateWillDown;
                }else{
                    //移到最高处
                    self.scrollState = YQScrollStateWillUp;
                }
            }else{//脱手点在最高点纸上
                //如果目标在最高线和最低线之间，到最高线，如果在最高线纸上不管
                if(targetContentOffset->y >= -self.originalInsetTop && targetContentOffset->y <= -self.minInsetTop){
//                    targetContentOffset->y = -self.minInsetTop;
                    self.scrollState = YQScrollStateWillUp;//这里的标志并不是很好，其实真是意思是滑动到最顶端这个值处
                }
            }
            
        }
    }
    
}
- (void)calendarScrollViewWillBeginDecelerating:(UIScrollView *)scrollView{

    if(self.scrollState == YQScrollStateWillUp){
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
        animation.fromValue = @(self.scrollView.contentOffset.y);
        animation.toValue = @(-self.minInsetTop);
    }else if(self.scrollState == YQScrollStateWillDown){
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
        animation.fromValue = @(self.scrollView.contentOffset.y);
        animation.toValue = @(-self.originalInsetTop);
    }
    self.scrollState = YQScrollStateDefault;
}

- (POPBasicAnimation *)scrollViewContentInsetAnimation{
    POPBasicAnimation *animation = [self.scrollView pop_animationForKey:ContentInsetAnimation];
    if(!animation){
        __weak typeof(self) weakSelf = self;
        animation = [POPBasicAnimation animation];
        animation.property = [POPMutableAnimatableProperty
                              propertyWithName:ContentInsetAnimation
                              initializer:^(POPMutableAnimatableProperty *prop) {
                                  prop.writeBlock = ^(UIScrollView *scrollView, const CGFloat values[]) {
                                      __strong typeof(weakSelf) strongSelf = weakSelf;
//                                      strongSelf.scrollView.contentInset = UIEdgeInsetsMake(values[0], 0, 0, 0);
//                                      strongSelf.scrollView.contentOffset = CGPointMake(0, -values[0]);
                                      strongSelf.scrollView.contentOffset = CGPointMake(0, values[0]);
                                      [strongSelf checkWeekCalendarShouldShowBySelf:strongSelf];
                                  };
                              }];
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.duration = YQAnmiationDuration;
        [self.scrollView pop_addAnimation:animation forKey:ContentInsetAnimation];
    }
    return animation;
}
- (void)checkWeekCalendarShouldShowBySelf:(YQCalendarView *)mySelf{
    //这里不能 >= 在等于的情况下是不应该显示的,但是如果选中的在最后一行，此时如果等于也需要显示
    if(mySelf.criticalOriginY == -CGRectGetHeight(self.weekCalendar.frame)){
        
        if(mySelf.scrollView.contentOffset.y >= mySelf.criticalOriginY){
            if(mySelf.weekCalendar.isHidden){
                mySelf.weekCalendar.hidden = NO;
            }
        }else{
            if(!mySelf.weekCalendar.isHidden){
                mySelf.weekCalendar.hidden = YES;
            }
        }
    }else{
        if(mySelf.scrollView.contentOffset.y > mySelf.criticalOriginY){
            if(mySelf.weekCalendar.isHidden){
                mySelf.weekCalendar.hidden = NO;
            }
        }else{
            
            if(!mySelf.weekCalendar.isHidden){
                mySelf.weekCalendar.hidden = YES;
            }
        }
    }
    
}
- (void)checkChangeMode{
    if(self.scrollView.contentOffset.y > -self.originalInsetTop && self.scrollView.contentOffset.y < -self.minInsetTop){
        CGFloat difference = self.scrollView.contentOffset.y-self.begeinDragOffset;
        if(self.weekCalendar.hidden){
            //正往上
            if(difference > self.minMoveDistance){
                //切换到周视图
                NSLog(@"正常 将要往上 变换");
                POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
//                animation.fromValue = @(self.scrollView.contentInset.top);
//                animation.toValue = @(self.minInsetTop);
                animation.fromValue = @(self.scrollView.contentOffset.y);
                animation.toValue = @(-self.minInsetTop);
                
            }else{
                NSLog(@"正常 将要往下 原样");
                POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
//                animation.fromValue = @(self.scrollView.contentInset.top);
//                animation.toValue = @(self.originalInsetTop);
                animation.fromValue = @(self.scrollView.contentOffset.y);
                animation.toValue = @(-self.originalInsetTop);
            }
        }else{
            if(difference < -self.minMoveDistance){
                NSLog(@"正常 将要往下 变化");
                POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
//                animation.fromValue = @(self.scrollView.contentInset.top);
//                animation.toValue = @(self.originalInsetTop);
                animation.fromValue = @(self.scrollView.contentOffset.y);
                animation.toValue = @(-self.originalInsetTop);
            }else{
                NSLog(@"正常 将要往上 原样");
                POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
//                animation.fromValue = @(self.scrollView.contentInset.top);
//                animation.toValue = @(self.minInsetTop);
                animation.fromValue = @(self.scrollView.contentOffset.y);
                animation.toValue = @(-self.minInsetTop);
            }
        }

    }
    
}

@end
