//
//  YQCalendarAppearence.h
//  YQCalendar
//
//  Created by 王叶庆 on 15/8/19.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSInteger const RowCount = 6;
static NSInteger const ColumnCount = 7;

@interface YQCalendarAppearence : NSObject

@property (nonatomic, strong) UIColor *calendarBackgroundColor;
@property (nonatomic, assign) BOOL firstDayIsSunday;

@property (nonatomic, strong) UIColor *headerTextColor;
@property (nonatomic, strong) UIFont *headerFont;
@property (nonatomic, strong) UIColor *headerBackgroundColor;
@property (nonatomic, assign) CGFloat headerHeight;

@property (nonatomic, strong) UIColor *cellTextNormalColor;
@property (nonatomic, strong) UIColor *cellTextTodayColor;
@property (nonatomic, strong) UIColor *cellTextSelectColor;
@property (nonatomic, strong) UIColor *cellTextOtherMonthColor;
@property (nonatomic, strong) UIColor *cellTextCircleNormalColor;
@property (nonatomic, strong) UIColor *cellTextCircleTodayColor;
@property (nonatomic, strong) UIColor *cellFlagDotNormalColor;
@property (nonatomic, strong) UIColor *cellFlagDotSelectColor;
@property (nonatomic, strong) UIColor *cellFlagDotTodayColor;
@property (nonatomic, strong) UIFont *cellTextFont;

/**
 *  圆圈直径占cell的百分比
 */
@property (nonatomic, assign) CGFloat cellTextCircleScale;
/**
 *  标志圆点的直径
 */
@property (nonatomic, assign) CGFloat cellFlagDotDiameter;
@property (nonatomic, assign) CGFloat cellFlagDotTextBottomSpace;

/**
 *  这并不是真正的单例，而是帮助cell快速访问已经生成的实例，所以不能通过这个方法来创建实例
 *
 *  @return
 */
+ (instancetype)share;

@end
