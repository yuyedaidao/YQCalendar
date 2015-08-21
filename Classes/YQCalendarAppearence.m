//
//  YQCalendarAppearence.m
//  YQCalendar
//
//  Created by 王叶庆 on 15/8/19.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "YQCalendarAppearence.h"


static YQCalendarAppearence *_yqAppearence = nil;
@implementation YQCalendarAppearence

- (instancetype)init{
    if(self = [super init]){
        _calendarBackgroundColor = [UIColor groupTableViewBackgroundColor];
        
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
        
        _yqAppearence = self;
    }
    
    return self;
}

+ (instancetype)share{
    return _yqAppearence;
}

@end
