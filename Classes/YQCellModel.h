//
//  YQCellModel.h
//  YQCalendar
//
//  Created by Wang on 15/8/20.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YQDateType) {
    YQDateTypeCurrentMoth = 0,
    YQDateTypePreMonth, //previous
    YQDateTypeToday,
    YQDateTypeNextMonth,
};

@interface YQCellModel : NSObject

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