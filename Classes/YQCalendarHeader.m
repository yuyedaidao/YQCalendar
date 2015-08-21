//
//  YQCalendarHeader.m
//  YQCalendar
//
//  Created by 王叶庆 on 15/8/21.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "YQCalendarHeader.h"
#import "YQCalendarAppearence.h"
@interface YQCalendarHeader()
@property (nonatomic, strong) NSMutableArray *weekLabelArray;
@property (nonatomic, assign) BOOL firstDayIsSunday;
@end

@implementation YQCalendarHeader

- (instancetype)initWithFrame:(CGRect)frame firstDayIsSunday:(BOOL)isSunday{
    if(self = [super initWithFrame:frame]){
        _firstDayIsSunday = isSunday;
    }
    return self;
}

- (void)prepare{
    NSArray *textArray = @[@"日",@"-",@"二",@"三",@"四",@"五",@"六"];
    for (int i = 0; i< ColumnCount; i++) {
        UILabel *label = [[UILabel alloc] init];
    }
}
@end
