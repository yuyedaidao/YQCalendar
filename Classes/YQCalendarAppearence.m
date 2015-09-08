//
//  YQCalendarAppearence.m
//  YQCalendar
//
//  Created by 王叶庆 on 15/8/19.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "YQCalendarAppearence.h"

@implementation YQCalendarAppearence

- (instancetype)init{
    if(self = [super init]){
        _calendarBackgroundColor = [UIColor groupTableViewBackgroundColor];
//        _firstDayIsSunday = YES;
        
        _criticalOffset = 100.0f;
        
        _headerWeekTextColor = [UIColor whiteColor];
        _headerWeekFont = [UIFont systemFontOfSize:14];
        _headerMonthTextColor = [UIColor greenColor];
        _headerMonthFont = [UIFont systemFontOfSize:15];
//        _headerBackgroundColor = _calendarBackgroundColor;
        _headerBackgroundColor = [UIColor orangeColor];
        _headerHeight = 50.0f;
        
        _cellTextNormalColor = [UIColor whiteColor];
        _cellTextTodayColor = [UIColor blueColor];
        _cellTextSelectColor = [UIColor whiteColor];
        _cellTextOtherMonthColor = [UIColor grayColor];
        _cellTextCircleNormalColor = [UIColor orangeColor];
        _cellTextCircleTodayColor = [UIColor whiteColor];
        _cellFlagDotNormalColor = [UIColor redColor];
        _cellFlagDotSelectColor = [UIColor whiteColor];
        _cellFlagDotTodayColor = [UIColor redColor];
        _cellTextFont = [UIFont systemFontOfSize:14];
        _cellFlagDotDiameter = 4;
        _cellFlagDotTextBottomSpace = 3.0f;
        _cellTextCircleScale = 0.7f;

    }
    
    return self;
}

+ (instancetype)share{
    static dispatch_once_t onceToken;
    static YQCalendarAppearence *_yqAppearence = nil;
    dispatch_once(&onceToken, ^{
        _yqAppearence = [[YQCalendarAppearence alloc] init];
    });
    return _yqAppearence;
}

@end
