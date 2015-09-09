//
//  YQCalendarView.h
//  YQCalendar
//
//  Created by Wang on 15/8/28.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQCalendar.h"

static CGFloat HeightWeekLabel = 30.0f;

@class YQCalendarView;



//@protocol YQCalendarScrollDelegate <NSObject>
//- (void)calendarScrollViewDidScroll:(UIScrollView *)scrollView;
//- (void)calendarScrollViewWillBeginDragging:(UIScrollView *)scrollView;
//- (void)calendarScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
//- (void)calendarScrollViewDidEndDecelerating:(UIScrollView *)scrollView;
//
//@optional
//- (void)calendarScrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
//- (void)calendarScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
//@end

@interface UIScrollView (YQCalendar)
//@property (nonatomic, weak) id<YQCalendarScrollDelegate> calendarScrollDelegate;
- (void)addCalendarView:(YQCalendarView *)calendarView;
@end




@protocol YQCalendarViewDelegate <NSObject>
- (void)calendarView:(YQCalendarView *)calendarView didSelectDate:(NSDate *)date;
/**
 *  月改变后调用此方法
 *
 *  @param calendar
 *  @param date     当前月的初始时间
 */
- (void)calendar:(YQCalendarView *)calendarView didChangeMonth:(NSDate *)date;
@end

@interface YQCalendarView : UIView

@property (nonatomic, weak) UIScrollView *scrollView;
- (void)calendarScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)calendarScrollViewWillBeginDragging:(UIScrollView *)scrollView;
- (void)calendarScrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate;
- (void)calendarScrollViewDidEndDecelerating:(UIScrollView *)scrollView;
- (void)calendarScrollViewWillBeginDecelerating:(UIScrollView *)scrollView;
- (void)calendarScrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset;
//- (void)calendarScrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView;
@end
