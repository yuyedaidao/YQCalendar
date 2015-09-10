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

    [self.scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:NULL];
}

#pragma mark observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    NSLog(@"change == %@",change);
}
#pragma mark override
-(void)layoutSubviews{
    [super layoutSubviews];
    self.originalInsetTop = self.scrollView.contentInset.top;
    self.minInsetTop = CGRectGetHeight(self.weekCalendar.bounds);
    self.weekCalendar.frame = CGRectMake(CGRectGetMinX(self.scrollView.frame), CGRectGetMinY(self.scrollView.frame), self.scrollView.frame.size.width, self.weekCalendar.frame.size.height);
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
//        if(-scrollView.contentOffset.y>=self.minInsetTop && -scrollView.contentOffset.y<=self.originalInsetTop){//
////            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
////            scrollView.contentOffset = scrollView.contentOffset;
////            [self checkChangeMode];
//            
//        }else if(-scrollView.contentOffset.y>self.originalInsetTop){
//            if(scrollView.contentInset.top != self.originalInsetTop){
//                scrollView.contentInset = UIEdgeInsetsMake(self.originalInsetTop, 0, 0, 0);
//            }
//        }else if(-scrollView.contentOffset.y<self.minInsetTop){
//            if(scrollView.contentInset.top != self.minInsetTop){
//                scrollView.contentInset = UIEdgeInsetsMake(self.minInsetTop, 0, 0, 0);
//            }
//        }
        
        [self checkWeekCalendarShouldShowBySelf:self];
    }

}
- (void)calendarScrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(self.weekCalendar.hidden){
        self.criticalOriginY = self.monthCalendar.targetRowOriginY+CGRectGetMinY(self.frame);
    }else{
        self.criticalOriginY = self.weekCalendar.targetRowOriginY+CGRectGetMinY(self.frame);
    }
    NSLog(@"criticalOriginY ==== %lf",self.criticalOriginY);
    self.begeinDragOffset = scrollView.contentOffset.y;

}
- (void)calendarScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    NSLog(@"%@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    NSLog(@"end dragging");
    CGFloat difference = self.scrollView.contentOffset.y-self.begeinDragOffset;
    if(scrollView.contentInset.top == self.originalInsetTop){
        if(!decelerate){
            //正往上
//            if(difference > CGRectGetHeight(self.weekCalendar.bounds)){
                //切换
                [self checkChangeMode];
//            }
        }else{
            //正往上
            if(difference > CGRectGetHeight(self.weekCalendar.bounds)){
                //切换
                self.scrollState = YQScrollStateWillUp;
            }
        }
    }else if(scrollView.contentInset.top == self.minInsetTop){
        
        if(!decelerate){
            if(difference < -CGRectGetHeight(self.weekCalendar.bounds)){
                [self checkChangeMode];
            }
        }else{
            if(difference < -CGRectGetHeight(self.weekCalendar.bounds)){
                self.scrollState = YQScrollStateWillDown;
            }
        }
    }
}
- (void)calendarScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    //最新策略
    //先判断edgeInset，如果开始处于最大值处，往上滑,禁止减速，然后根据移动距离判断日历模式变换 往下滑不做任何处理基于bounces效果复原
    //如果开始处于最小值，往下滑，禁止减速，然后根据移动距离判断日历模式变化 往上滑不做任何处理
//    if(scrollView.contentInset.top <= self.originalInsetTop && scrollView.contentInset.top > self.minInsetTop){//最大值
//        if(velocity.y>0){//往上滑
//            NSLog(@"往上滑");
////            [scrollView setContentOffset:scrollView.contentOffset animated:NO];
////            [self checkChangeMode];
//            self.scrollState = YQScrollStateWillUp;
//        }else if(velocity.y<0){//往下滑
//            //do nothing
//            NSLog(@"往下滑");
////            [scrollView setContentOffset:scrollView.contentOffset animated:NO];
////            [self checkChangeMode];
//            self.scrollState = YQScrollStateWillDown;
//        }else{//没有减速
//            NSLog(@"没有减速");
//            [self checkChangeMode];
//        }
//    }else if(scrollView.contentInset.top > self.originalInsetTop){
//        NSLog(@"大于最大 top");
//    }else{
//        NSLog(@"小于最小top");
//    }
//    if(scrollView.contentOffset.y )
    
}
- (void)calendarScrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    NSLog(@"will decelerating");
    if(self.scrollState == YQScrollStateWillUp || self.scrollState == YQScrollStateWillDown){
        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
        NSLog(@"begin %lf now %lf",self.begeinDragOffset,scrollView.contentOffset.y);
        if(self.scrollState==YQScrollStateWillDown){
            
            CGFloat difference = self.scrollView.contentOffset.y-self.begeinDragOffset;
            NSLog(@"移动距离 %lf",difference);
        }
        [self checkChangeMode];
        self.scrollState = YQScrollStateDefault;
    }
}
- (void)calendarScrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    [self checkChangeMode];
//    NSLog(@"end dec");
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
                                      strongSelf.scrollView.contentInset = UIEdgeInsetsMake(values[0], 0, 0, 0);
                                      strongSelf.scrollView.contentOffset = CGPointMake(0, -values[0]);
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
    if(mySelf.scrollView.contentOffset.y > mySelf.criticalOriginY){//这里不能 >= 在等于的情况下是不应该显示的
        if(mySelf.weekCalendar.isHidden){
            mySelf.weekCalendar.hidden = NO;
        }
    }else{
        if(!mySelf.weekCalendar.isHidden){
            mySelf.weekCalendar.hidden = YES;
        }
    }
    
}
- (void)checkChangeMode{
    CGFloat difference = self.scrollView.contentOffset.y-self.begeinDragOffset;
    if(self.weekCalendar.hidden){
        //正往上
        if(difference > CGRectGetHeight(self.weekCalendar.bounds)){
            //切换到周视图
            
            POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
            animation.fromValue = @(self.scrollView.contentInset.top);
            animation.toValue = @(self.minInsetTop);
            
        }else{
            
            POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
            animation.fromValue = @(self.scrollView.contentInset.top);
            animation.toValue = @(self.originalInsetTop);
            
        }
    }else{
        if(difference < -CGRectGetHeight(self.weekCalendar.bounds)){
            POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
            animation.fromValue = @(self.scrollView.contentInset.top);
            animation.toValue = @(self.originalInsetTop);
            
        }else{
            POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
            animation.fromValue = @(self.scrollView.contentInset.top);
            animation.toValue = @(self.minInsetTop);
            
        }
    }
    
    
}

@end
