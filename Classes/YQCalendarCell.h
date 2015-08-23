//
//  YQCalendarCell.h
//  YQCalendar
//
//  Created by Wang on 15/8/20.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQCellModel.h"
#import "YQCalendarAppearence.h"


@interface YQCalendarCell : UICollectionViewCell


@property (nonatomic, strong) YQCellModel *model;
/**
 *  用于取消点击后恢复状态
 */
- (void)reset;
/**
 *  高亮当前cell
 */
- (void)highlight;
/**
 *  选中当前cell
 */
- (void)select;
/**
 *  是否在文字下显示圆点标志
 *
 *  @param show 
 */
- (void)showFlagDot:(BOOL)show;
@end
