//
//  YQCellModel.h
//  YQCalendar
//
//  Created by Wang on 15/8/20.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YQCalendarAppearence.h"

typedef NS_ENUM(NSUInteger, YQDateType) {
    YQDateTypeDefault = 0,
    YQDateTypeCurrentMoth = 1,
    YQDateTypeToday = 2,
    YQDateTypePreMonth, //previous
    YQDateTypeNextMonth,
};

@interface YQCellModel : NSObject

@property (nonatomic, assign) YQCalendarMode cellMode;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSIndexPath *indexPath;
/**
 *  cell在当前月份实际的列值
 */
@property (nonatomic, assign) NSInteger column;
/**
 *  cell在当前月份实际的行值
 */
@property (nonatomic, assign) NSInteger row;

@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign, readonly) YQDateType dateType;


@end
