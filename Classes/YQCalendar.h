//
//  YQCalendar.h
//  YQCalendar
//
//  Created by 王叶庆 on 15/8/19.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQCalendarAppearence.h"

@class YQCalendar;

@protocol YQCalendarDelegate <NSObject>
- (void)calendar:(YQCalendar *)calendar didSelectDate:(NSDate *)date;
@end


@interface YQCalendar : UIView

- (instancetype)init;
- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithAppearence:(YQCalendarAppearence *)appearence;
- (instancetype)initWithFrame:(CGRect)frame appearence:(YQCalendarAppearence *)appearence;

@property (nonatomic, strong) YQCalendarAppearence *appearence;
@property (nonatomic, weak) id<YQCalendarDelegate> delegate;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) IBInspectable NSDate *minDate;
@property (nonatomic, strong) IBInspectable NSDate *maxDate;

@property (nonatomic, assign) YQCalendarMode mode;

- (void)changeModel;

@end
