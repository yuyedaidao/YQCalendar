//
//  YQCalendarHeader.m
//  YQCalendar
//
//  Created by 王叶庆 on 15/8/21.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "YQCalendarHeader.h"
#import "YQCalendarAppearence.h"
#import <DateTools.h>

@interface YQCalendarHeader()
@property (nonatomic, strong) NSMutableArray *weekLabelArray;
@property (nonatomic, strong) UIButton *todayButton;
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
    
    _monthLabel = [[UILabel alloc] init];
    self.monthLabel.textColor = [YQCalendarAppearence share].headerMonthTextColor;
    self.monthLabel.font = [YQCalendarAppearence share].headerMonthFont;
    self.monthLabel.text = [[NSDate date] formattedDateWithFormat:@"yyyy-MM"];
    [self addSubview:self.monthLabel];
    
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(todayAction:)];
    self.monthLabel.userInteractionEnabled = YES;
    doubleTap.numberOfTapsRequired = 2;
    [self.monthLabel addGestureRecognizer:doubleTap];
    
//    _todayButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    self.todayButton.titleLabel.font = self.monthLabel.font;
//    [self.todayButton setTitle:@"今天" forState:UIControlStateNormal];
//    [self.todayButton addTarget:self action:@selector(todayAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.todayButton];
    
    _weekLabelArray = [NSMutableArray array];
    NSArray *textArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    for (int i = 0; i< ColumnCount; i++) {
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [YQCalendarAppearence share].headerWeekTextColor;
        label.font = [YQCalendarAppearence share].headerWeekFont;
        label.textAlignment = NSTextAlignmentCenter;
        label.text = textArray[[YQCalendarAppearence share].firstDayIsSunday ? i:(i+1+ColumnCount)%ColumnCount];
        [self addSubview:label];
        [self.weekLabelArray addObject:label];
    }
}

- (void)todayAction:(id)sender{
    DDLogDebug(@"TodayAction");
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat height = CGRectGetHeight(self.bounds)/4;
    [self.monthLabel sizeToFit];
    self.monthLabel.center = CGPointMake(CGRectGetMidX(self.bounds), height);
    CGFloat width = CGRectGetWidth(self.bounds)/ColumnCount;
    
//    [self.todayButton sizeToFit];
//    self.todayButton.center = CGPointMake(CGRectGetWidth(self.bounds)-CGRectGetWidth(self.todayButton.bounds)/2-20, CGRectGetMidY(self.monthLabel.frame));
    
    [self.weekLabelArray enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL *stop) {
        [obj sizeToFit];
        obj.center = CGPointMake(width*idx+width/2, height*3);
    }];
}
@end
