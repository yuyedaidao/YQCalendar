//
//  YQCalendarView.m
//  YQCalendar
//
//  Created by Wang on 15/8/28.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "YQCalendarView.h"

@interface YQCalendarView ()<YQCalendarDelegate>

@property (nonatomic, strong) YQCalendar *weekCalendar;
@property (nonatomic, strong) YQCalendar *monthCalendar;

@end

@implementation YQCalendarView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)init{
    if(self = [super init]){
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if(self == [super initWithFrame:frame]){
    
    }
    return self;
}
- (void)awakeFromNib{
    [self prepareView];
}
- (void)prepareView{
    
    self.monthCalendar = [[YQCalendar alloc] initWithFrame:self.bounds];
    self.weekCalendar = [[YQCalendar alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/RowCountMonthMode)];
    
    self.monthCalendar.mode = YQCalendarModeMonth;
    self.weekCalendar.mode = YQCalendarModeWeek;
    
    self.weekCalendar.hidden = YES;
    
    self.monthCalendar.delegate = self;
    self.weekCalendar.delegate = self;
    [self addSubview:self.monthCalendar];
    [self addSubview:self.weekCalendar];
    
    NSDate *date = [NSDate date];
    [self.monthCalendar scrollToDate:date];
    [self.weekCalendar scrollToDate:date];
}


#pragma mark calendar delegate
- (void)calendar:(YQCalendar *)calendar didSelectDate:(NSDate *)date{
    if(calendar == self.monthCalendar){
        [self.weekCalendar setSelectedDate:date];
        [self.weekCalendar scrollToDate:date];
    }else{
        [self.monthCalendar setSelectedDate:date];
        [self.monthCalendar scrollToDate:date];
    }
}
- (void)calendar:(YQCalendar *)calendar didChangeMonth:(NSDate *)date{
    if(calendar == self.monthCalendar){
        [self.weekCalendar scrollToDate:date];
    }else if(calendar == self.weekCalendar){
        [self.monthCalendar scrollToDate:date];
    }
}


@end
