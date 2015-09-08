//
//  YQCalendarWeekLabel.m
//  YQCalendar
//
//  Created by Wang on 15/8/31.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "YQCalendarWeekLabel.h"
#import <DateTools.h>
#import "YQCalendarAppearence.h"
@interface YQCalendarWeekLabel ()
@property (nonatomic, strong) NSMutableArray *weekLabelArray;
@end

@implementation YQCalendarWeekLabel

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self prepare];
    }
    return self;
}
- (void)prepare{
     self.backgroundColor = [YQCalendarAppearence share].headerBackgroundColor;
     _weekLabelArray = [NSMutableArray array];
     NSArray *textArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
     for (int i = 0; i< ColumnCount; i++) {
         UILabel *label = [[UILabel alloc] init];
         label.textColor = [YQCalendarAppearence share].headerWeekTextColor;
         label.font = [YQCalendarAppearence share].headerWeekFont;
         label.textAlignment = NSTextAlignmentCenter;
         label.backgroundColor = self.backgroundColor;
         label.text = textArray[[YQCalendarAppearence share].firstDayIsSunday ? i:(i+1+ColumnCount)%ColumnCount];
         [self addSubview:label];
         [self.weekLabelArray addObject:label];
     }
    
 }
- (void)awakeFromNib{
    [self prepare];
}

- (void)layoutSubviews{
    [super layoutSubviews];
 
    CGFloat width = CGRectGetWidth(self.bounds)/ColumnCount;
    [self.weekLabelArray enumerateObjectsUsingBlock:^(UILabel *obj, NSUInteger idx, BOOL *stop) {
        [obj sizeToFit];
        obj.center = CGPointMake(width*idx+width/2, CGRectGetMidY(self.bounds));
    }];
}


@end
