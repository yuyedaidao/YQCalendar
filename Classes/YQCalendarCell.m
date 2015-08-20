//
//  YQCalendarCell.m
//  YQCalendar
//
//  Created by Wang on 15/8/20.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "YQCalendarCell.h"
#import <DateTools.h>

@interface YQCalendarCell ()
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation YQCalendarCell

- (void)awakeFromNib {
    // Initialization code
    
}
- (void)setModel:(YQCellModel *)model{
    if(_model != model){
        _model = model;
    }
    
    //为了显示信息保证最新，不能再条件判断内执行
    self.dateLabel.text = [model.date formattedDateWithFormat:@"MM:dd"];
    switch (model.dateType) {
        case YQDateTypePreMonth:
            self.backgroundColor = [UIColor grayColor];
            break;
        case YQDateTypeCurrentMoth:
            self.backgroundColor = [UIColor greenColor];
            break;
        case YQDateTypeToday:
            self.backgroundColor = [UIColor orangeColor];
            break;
        case YQDateTypeNextMonth:
            self.backgroundColor = [UIColor grayColor];
            break;
        default:
            break;
    }

}
@end
