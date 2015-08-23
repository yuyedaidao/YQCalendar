//
//  YQCellModel.m
//  YQCalendar
//
//  Created by Wang on 15/8/20.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "YQCellModel.h"
#import <DateTools.h>

@implementation YQCellModel

- (void)setDate:(NSDate *)date{
    if(_date != date){
        _date = date;
        if(self.cellMode == YQCalendarModeMonth){
            if(self.month == date.month){
                if(date.isToday){
                    _dateType = YQDateTypeToday;
                }else{
                    _dateType = YQDateTypeCurrentMoth;
                }
            }else{
                if(self.month > date.month){
                    _dateType = YQDateTypeNextMonth;
                }else{
                    _dateType = YQDateTypePreMonth;
                }
            }
        }
    }
}
@end
