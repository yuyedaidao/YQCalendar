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
 *  月改变后调用此方法
 *
 *  @param calendar
 *  @param date     当前月的初始时间
 */
- (void)calendar:(YQCalendar *)calendar didChangeMonth:(NSDate *)date;
- (void)calendar:(YQCalendar *)calendar anotherShouldReloadWithDate:(NSDate *)date;
@end

@interface YQCalendar : UIView

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame mode:(YQCalendarMode)mode;


@property (nonatomic, strong) YQCalendarHeader *headerView;
@property (nonatomic, weak) id<YQCalendarDelegate> delegate;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) IBInspectable NSDate *minDate;
@property (nonatomic, strong) IBInspectable NSDate *maxDate;

@property (nonatomic, assign) YQCalendarMode mode;
@property (nonatomic, assign) CGFloat targetRowOriginY;

- (void)scrollToDate:(NSDate *)date;
- (void)scrollToDate:(NSDate *)date selected:(BOOL)selected;
- (void)selectCellByDate:(NSDate *)date;
- (void)changeModel;

@end
