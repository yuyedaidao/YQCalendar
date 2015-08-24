//
//  YQCalendarAppearence.h
//  YQCalendar
//
//  Created by 王叶庆 on 15/8/19.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSInteger const RowCountMonthMode = 6;
static NSInteger const ColumnCount = 7;
static NSInteger const RowCountWeekMode = 1;

static CGFloat const YQAnmiationDuration = 0.3f;


UIKIT_STATIC_INLINE CGFloat NavHeight(UIViewController *vc){
    return vc.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height;
}

typedef NS_ENUM(NSUInteger, YQCalendarMode) {
    YQCalendarModeWeek,
    YQCalendarModeMonth,
};

@interface YQCalendarAppearence : NSObject

@property (nonatomic, strong) UIColor *calendarBackgroundColor;
@property (nonatomic, assign) BOOL firstDayIsSunday;

@property (nonatomic, strong) UIColor *headerWeekTextColor;
@property (nonatomic, strong) UIColor *headerMonthTextColor;
@property (nonatomic, strong) UIFont *headerWeekFont;
@property (nonatomic, strong) UIFont *headerMonthFont;
@property (nonatomic, strong) UIColor *headerBackgroundColor;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat headerBottomPadding;

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
 *  触发日历变换的临界值 正值 在于scorllView的contentOffset做运算是需要注意
 */
@property (nonatomic, assign) CGFloat criticalOffset;

//@property (nonatomic, assign) YQCalendarMode *mode;

/**
 *  这并不是真正的单例，而是帮助cell快速访问已经生成的实例，所以不能通过这个方法来创建实例
 *
 *  @return
 */
+ (instancetype)share;


///**
// *  可以通过这两个属性对YQCalendar做一些操作，比如布局
// */
//@property (nonatomic, weak, readonly) UIView *headerWeekView;
//@property (nonatomic, weak, readonly) UIView *headerMonthView;

@end
