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
    }
    
    return self;
}
@end
