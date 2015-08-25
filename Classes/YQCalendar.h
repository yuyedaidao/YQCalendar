//
//  YQCalendar.h
//  YQCalendar
//
//  Created by 王叶庆 on 15/8/19.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQCalendarAppearence.h"
#import "YQCalendarHeader.h"


@class YQCalendar;

@protocol YQCalendarDelegate <NSObject>
- (void)calendar:(YQCalendar *)calendar didSelectDate:(NSDate *)date;
/**
 *  月视图改变后调用此方法
 *
 *  @param calendar
 *  @param date     当前月的初始时间
 */
- (void)calendar:(YQCalendar *)calendar didChangeMonth:(NSDate *)date;
@end


@interface UIScrollView (YQCalendar)
- (void)addCalendar:(YQCalendar *)calendar;
@end

@interface YQCalendar : UIView

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithAppearence:(YQCalendarAppearence *)appearence;
- (instancetype)initWithFrame:(CGRect)frame appearence:(YQCalendarAppearence *)appearence;
- (instancetype)initWithFrame:(CGRect)frame appearence:(YQCalendarAppearence *)appearence mode:(YQCalendarMode)mode;
- (instancetype)initWithFrame:(CGRect)frame appearence:(YQCalendarAppearence *)appearence mode:(YQCalendarMode)mode hasNavigation:(BOOL)hasNav;

@property (nonatomic, strong) YQCalendarHeader *headerView;
@property (nonatomic, strong) YQCalendarAppearence *appearence;
@property (nonatomic, weak) id<YQCalendarDelegate> delegate;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) IBInspectable NSDate *minDate;
@property (nonatomic, strong) IBInspectable NSDate *maxDate;

@property (nonatomic, assign) BOOL hasNavigation;
@property (nonatomic, assign) YQCalendarMode mode;
@property (nonatomic, assign) CGFloat targetRowOriginY;

- (void)scrollToDate:(NSDate *)date;
- (void)selectCellByDate:(NSDate *)date;
- (void)changeModel;

@end
