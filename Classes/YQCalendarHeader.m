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
@end

@implementation YQCalendarHeader

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]){
        [self prepare];
    }
    return self;
}
- (instancetype)init{
    if(self = [super init]){
        [self prepare];
    }
    return self;
}

- (void)prepare{
    _weekLabelArray = [NSMutableArray array];
    NSArray *textArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    for (int i = 0; i< ColumnCount; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [YQCalendarAppearence share].headerTextColor;
        label.font = [YQCalendarAppearence share].headerFont;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = textArray[[YQCalendarAppearence share].firstDayIsSunday ? i:(i+1+ColumnCount)%ColumnCount];
        [self addSubview:label];
        [self.weekLabelArray addObject:label];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.bounds)/ColumnCount;
    [self.weekLabelArray enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL *stop) {
        [obj sizeToFit];
        obj.center = CGPointMake(width*idx+width/2, CGRectGetHeight(self.bounds)/2);
    }];
}
@end
