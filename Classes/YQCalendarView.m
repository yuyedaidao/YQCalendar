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
//@property (nonatomic, assign) CGFloat minInsetTop;
//@property (nonatomic, assign) CGFloat originalInsetTop;
@property (nonatomic, assign) CGFloat targetMinOffset;
@property (nonatomic, assign) CGFloat targetMaxOffset;

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
    
//    self.originalInsetTop = self.scrollView.contentInset.top;
//    self.minInsetTop = CGRectGetMaxY(self.weekCalendar.frame);

}
#pragma mark override
-(void)layoutSubviews{
    [super layoutSubviews];
    NSLog(@"%@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
//    self.originalInsetTop = self.scrollView.contentInset.top;
//    self.minInsetTop = CGRectGetHeight(self.weekCalendar.bounds);
    self.weekCalendar.frame = CGRectMake(CGRectGetMinX(self.scrollView.frame), CGRectGetMinY(self.scrollView.frame), self.scrollView.frame.size.width, self.weekCalendar.frame.size.height);
    self.targetMinOffset = -CGRectGetHeight(self.monthCalendar.frame);
    self.targetMaxOffset = -CGRectGetHeight(self.weekCalendar.frame);
    
    NSLog(@"min %lf,max %lf offset = %lf,inset %lf",self.targetMinOffset,self.targetMaxOffset,self.scrollView.contentOffset.y,self.scrollView.contentInset.top);
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
//
//    if(scrollView.isDragging || scrollView.isDecelerating){
//        if(-scrollView.contentOffset.y>=self.minInsetTop && -scrollView.contentOffset.y<=self.originalInsetTop){//
////            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
////            scrollView.contentOffset = scrollView.contentOffset;
////            [self checkChangeMode];
////            scrollView.panGestureRecognizer.enabled = NO;
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
//    }
//    NSLog(@"inset y = %lf offset y = %lf",scrollView.contentInset.top,scrollView.contentOffset.y);
}
- (void)calendarScrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    NSLog(@"%@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    if(self.weekCalendar.hidden){
        self.criticalOriginY = self.monthCalendar.targetRowOriginY+CGRectGetMinY(self.frame);
    }else{
        self.criticalOriginY = self.weekCalendar.targetRowOriginY+CGRectGetMinY(self.frame);
    }
    self.begeinDragOffset = scrollView.contentOffset.y;
    NSLog(@"begin ==== %lf",scrollView.contentOffset.y);

}
-(void)calendarScrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
//    NSLog(@"%@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),NSStringFromCGPoint(scrollView.contentOffset));
    
//    //如果在范围内，应该先停止减速运动再
//    if(-scrollView.contentOffset.y>=self.minInsetTop && -scrollView.contentOffset.y<=self.originalInsetTop){
////        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//        NSLog(@"减速中判断");
//        [scrollView setContentOffset:scrollView.contentOffset animated:NO];
//        [self checkChangeMode];
//    }

}
- (void)calendarScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    NSLog(@"%@:%@ %@",NSStringFromClass([self class]),NSStringFromSelector(_cmd),NSStringFromCGPoint(scrollView.contentOffset));
//    if(!decelerate){
//        [self checkChangeMode];
//    }

}
- (void)calendarScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    NSLog(@"velocity === %lf target= %lf currentoff y =%lf",velocity.y,(*targetContentOffset).y,scrollView.contentOffset.y);

    //如果当前位置在目标范围内
        //没有减速 -->A
            //移动范围大于临界值 改变模式，
            //小于临界值 返回到目标边界
        //有减速 禁止减速 按A处理
    //如果当前位置不在目标范围内
        //有减速
            //如果减速后位置在目标范围内 禁止减速 按A处理
    
    if(scrollView.contentOffset.y > self.targetMinOffset){
        if(velocity.y == 0){
            if(scrollView.contentOffset.y < self.targetMaxOffset){
                [self checkChangeMode];
            }
        }else{
            [scrollView setContentOffset:scrollView.contentOffset animated:NO];
            [self checkChangeMode];
        }
    }else{
        if(velocity.y != 0){
            if(targetContentOffset->y > self.targetMinOffset){
                [scrollView setContentOffset:scrollView.contentOffset animated:NO];
                [self checkChangeMode];
            }
        }
    }
    
}
- (void)calendarScrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"end decelerating = %lf",scrollView.contentOffset.y);
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
- (void)checkChangeModeWithMoveDistance:(CGFloat)distance{
    
}
- (void)checkChangeMode{
    CGFloat difference = self.scrollView.contentOffset.y-self.begeinDragOffset;
    if(self.weekCalendar.hidden){
        //正往上
        if(difference > CGRectGetHeight(self.weekCalendar.bounds)){
            //切换到周视图
            
            POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
            animation.fromValue = @(self.scrollView.contentOffset.y);
            animation.toValue = @(self.targetMaxOffset);
            
        }else{
            
            POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
            animation.fromValue = @(self.scrollView.contentOffset.y);
            animation.toValue = @(self.targetMinOffset);
            
        }
    }else{
        if(difference < -CGRectGetHeight(self.weekCalendar.bounds)){
            POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
            animation.fromValue = @(self.scrollView.contentOffset.y);
            animation.toValue = @(self.targetMinOffset);
            
        }else{
            POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
            animation.fromValue = @(self.scrollView.contentOffset.y);
            animation.toValue = @(self.targetMaxOffset);

        }
    }
    
}
- (void)changeModeTo:(YQCalendarMode)mode{
//    if(YQCalendarModeWeek == mode){
//        POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
//        animation.fromValue = @(self.scrollView.contentInset.top);
//        animation.toValue = @(self.minInsetTop);
//    }else{
//        POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
//        animation.fromValue = @(self.scrollView.contentInset.top);
//        animation.toValue = @(self.originalInsetTop);
//    }
}
@end
