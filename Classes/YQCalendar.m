//
//  YQCalendar.m
//  YQCalendar
//
//  Created by 王叶庆 on 15/8/19.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "YQCalendar.h"
#import <Masonry.h>
#import <DateTools.h>
#import "YQCalendarCell.h"
#import <ReactiveCocoa.h>

static NSString *const Identifier = @"YQCalendarCell";
static NSString *const KeyPathContentOffset = @"contentOffset";

static void *ObserverContextScrollView;

@implementation UIScrollView (YQCalendar)

- (void)addCalendar:(YQCalendar *)calendar{
    if(calendar){
        calendar.frame = CGRectOffset(calendar.frame, 0, -CGRectGetHeight(calendar.bounds)+self.contentInset.top);
        if(calendar.mode == YQCalendarModeMonth){
            self.contentInset = UIEdgeInsetsMake(self.contentInset.top+CGRectGetHeight(calendar.bounds)+[YQCalendarAppearence share].headerHeight, 0, 0, 0);
            NSLog(@"calendar inset = %@",NSStringFromUIEdgeInsets(self.contentInset));
        }else if(calendar.mode == YQCalendarModeWeek){
            //TODO:实现单个时候的inset
        }
        
        [self addSubview:calendar];
        [self sendSubviewToBack:calendar];
        
    }
}

@end



@interface YQCalendar ()<UICollectionViewDataSource,UICollectionViewDelegate>

/**
 *  最小时间月份的初始时间
 */
@property (nonatomic, strong, readonly) NSDate *minBeginningDate;
@property (nonatomic, strong, readonly) NSDate *selectedBeginningDate;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionLayout;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) NSDate *currentMonthBeginningDate;
//@property (nonatomic, strong) NSIndexPath *targetIndexPath;
@property (nonatomic, assign) NSInteger targetRow;

//父视图
@property (nonatomic, weak) UIScrollView *scrollView;

@end

@implementation YQCalendar

- (instancetype)init{
    return [self initWithFrame:CGRectZero appearence:nil mode:YQCalendarModeMonth];
}

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame appearence:nil mode:YQCalendarModeMonth];
}

- (instancetype)initWithAppearence:(YQCalendarAppearence *)appearence{
    return [self initWithFrame:CGRectZero appearence:appearence mode:YQCalendarModeMonth];
}
- (instancetype)initWithFrame:(CGRect)frame appearence:(YQCalendarAppearence *)appearence{
    return [self initWithFrame:frame appearence:appearence mode:YQCalendarModeMonth];
}
- (instancetype)initWithFrame:(CGRect)frame appearence:(YQCalendarAppearence *)appearence mode:(YQCalendarMode)mode{
    return [self initWithFrame:frame appearence:appearence mode:mode hasNavigation:YES];
}
- (instancetype)initWithFrame:(CGRect)frame appearence:(YQCalendarAppearence *)appearence mode:(YQCalendarMode)mode hasNavigation:(BOOL)hasNav{

    if(self = [super initWithFrame:frame]){
        _hasNavigation = hasNav;
        _appearence = appearence;
        _mode = mode;
        [self prepare];
        
    }
    return self;
}

- (void)awakeFromNib{
    [self prepare];
}

#pragma mark self handler

- (void)prepare{
    
    
    self.maxDate = [NSDate dateWithYear:2099 month:12 day:31];
    self.minDate = [NSDate dateWithYear:1970 month:1 day:1];
    
    _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionLayout.itemSize = CGSizeZero;
    self.collectionLayout.minimumLineSpacing = 0;
    self.collectionLayout.minimumInteritemSpacing = 0;
    self.collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    CGFloat width = CGRectGetWidth(self.bounds)/ColumnCount;
    CGFloat height = 0;
    if(self.mode == YQCalendarModeMonth){
        height = CGRectGetHeight(self.bounds)/RowCountMonthMode;
    }else{
        height = CGRectGetHeight(self.bounds)/RowCountWeekMode;
    }
    self.collectionLayout.itemSize = CGSizeMake(width, height);
    
    if(!_appearence){
        _appearence = [[YQCalendarAppearence alloc] init];
    }
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.collectionLayout];
    self.collectionView.backgroundColor = self.appearence.calendarBackgroundColor;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.clipsToBounds = YES;
    
    [self.collectionView registerClass:[YQCalendarCell class] forCellWithReuseIdentifier:Identifier];
    
    [self addSubview:self.collectionView];


    @weakify(self)
    [RACObserve(self, currentMonthBeginningDate) subscribeNext:^(NSDate *date) {
        @strongify(self)
        if(self.mode == YQCalendarModeMonth){
            if(self.headerView){
                self.headerView.monthLabel.text = [date formattedDateWithFormat:@"yyyy-MM"];
            }
            //TODO:改变策略，获取当前的目标row
            //如果当前月有select按select所在行，如果有今天，按今天所在行，如果没有按第一行
            NSDate *today = [NSDate date];
            if(self.selectedDate && self.selectedDate.month == date.month){
                //有选中并且已找到
                YQCalendarCell *cell = (YQCalendarCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
                self.targetRow = cell.model.row;
                
            }else if(today.month == date.month){
                //今天
                self.targetRow = [today daysLaterThan:date]/ColumnCount;
            }else{
                self.targetRow = 0;
            }
            
            self.targetRowOriginY = self.targetRow*self.collectionLayout.itemSize.height-self.headerView.frame.size.height;
            //相应的周视图也要改
            if([self.delegate respondsToSelector:@selector(calendar:didChangeMonth:)]){
                [self.delegate calendar:self didChangeMonth:date];
            }
        }
    }];
    
    NSDate *date = [NSDate date];
    self.currentMonthBeginningDate = [NSDate dateWithYear:date.year month:date.month day:1];
}

- (void)setCurrentMonthBegginningDateWithOffset:(CGFloat)offset{
    if(self.mode == YQCalendarModeMonth){
        self.currentMonthBeginningDate = [self.minBeginningDate dateByAddingMonths:offset/CGRectGetWidth(self.collectionView.bounds)];
    }else if(self.mode == YQCalendarModeWeek){
        //TODO:这里应该计算本周第一天的时间 暂时不需要计算
    }
}
- (NSInteger)sectionIndexOfDate:(NSDate *)date{
    if([date isLaterThan:self.minDate]){
        //同一年
        if(self.maxDate.year == self.minDate.year){
            return date.month-self.minDate.month;
        }
        //不同年 且最大日期月份大于最小日期月份
        if(date.month >= self.minDate.month){//不同年 且最大日期月份大于最小日期月份
            return (date.year-self.minDate.year)*12+(date.month-self.minDate.month);
        }else{//不同年 且最大日期月份小于最小日期月份
            return (date.year-self.minDate.year)*12-(self.minDate.month-date.month);
        }
    }
    return 0;
}

/**
 *  需要注意横向滚动时cell的加载顺序，是先上下再左右
 *
 *  @param indexPath
 *
 *  @return YQCellModel
 */
- (YQCellModel *)cellModelForIndexPath:(NSIndexPath *)indexPath{

    YQCellModel *model = [[YQCellModel alloc] init];
    model.indexPath = indexPath;
    model.cellMode = self.mode;
    
    if(self.mode == YQCalendarModeMonth){
        model.column = indexPath.item/RowCountMonthMode;
        model.row = indexPath.item%RowCountMonthMode;
        NSInteger index = model.row*ColumnCount+model.column;
        //确定月份的第一天
        NSDate *firstDay = [self.minBeginningDate dateByAddingMonths:indexPath.section];
        model.month = firstDay.month;
        //星期几
        NSInteger week = firstDay.weekday;//如果星期天是一周的第一天，那么这个月的第一天就在indexPath.row为week-1的位置上
        model.date = [firstDay dateByAddingDays:index-week+([YQCalendarAppearence share].firstDayIsSunday?1:2)];
    }else if(self.mode == YQCalendarModeWeek){
        model.date = [self.minBeginningDate dateByAddingDays:indexPath.item];
    }
    
    return model;
}

#pragma mark observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    DDLogError(@"-------offset y = %lf",self.scrollView.contentOffset.y);
//    if(self.expanded){//展开状态如果往上超过了临界值，自动关闭
//        CGFloat offsetY = self.scrollView.contentOffset.y;
//        if(offsetY >= -self.tempOffsetY-[YQCalendarAppearence share].criticalOffset){
//            DDLogInfo(@"temp+cri = %lf offset = %lf",-self.tempOffsetY-[YQCalendarAppearence share].criticalOffset,offsetY);
//            //执行动画
//            [UIView animateWithDuration:YQAnmiationDuration animations:^{
//                [self.scrollView setContentInset:self.scrollViewOriginalInset];
//                self.scrollView.contentOffset = CGPointMake(0, -self.scrollViewOriginalInset.top);
//            } completion:^(BOOL finished) {
//                self.tempOffsetY = self.scrollView.contentOffset.y;
//                self.expanded = NO;
//            }];
//        }
//    }else{//关闭状态如果向下超过了临界值，自动展开
//        CGFloat offsetY = self.scrollView.contentOffset.y;
//        if(offsetY <= -self.tempOffsetY-[YQCalendarAppearence share].criticalOffset){
//            //执行动画
//            [UIView animateWithDuration:YQAnmiationDuration animations:^{
//                [self.scrollView setContentInset:UIEdgeInsetsMake(CGRectGetHeight(self.bounds), 0, 0, 0)];
//                self.scrollView.contentOffset = CGPointMake(0, -CGRectGetHeight(self.bounds));
//            } completion:^(BOOL finished) {
//                self.tempOffsetY = self.scrollView.contentOffset.y;
//                self.expanded = YES;
//            }];
//        }
//    }
    
}

#pragma mark override


//- (void)layoutSubviews{
//    [super layoutSubviews];
//}

//- (void)setAppearence:(YQCalendarAppearence *)appearence{
//    _appearence = appearence;
//    self.collectionView
//}
- (void)setMinDate:(NSDate *)minDate{
    if(_minDate != minDate){
        _minDate = minDate;
        _minBeginningDate = [NSDate dateWithYear:minDate.year month:minDate.month day:1];
        if(self.mode == YQCalendarModeWeek){
            //根据星期几设定这之前的某个时间点为最小时间
            NSInteger weekDay = _minBeginningDate.weekday;
            _minBeginningDate = [_minBeginningDate dateByAddingDays:[YQCalendarAppearence share].firstDayIsSunday? 1-weekDay:2-weekDay];
        }
    }
}
- (void)setSelectedDate:(NSDate *)selectedDate{
    _selectedDate = selectedDate;
    _selectedBeginningDate = [NSDate dateWithYear:selectedDate.year month:selectedDate.month day:1];
}
#pragma mark collection delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    NSAssert([self.maxDate isLaterThan:self.minDate], @"最大最小日期设定不合适");
    if(self.mode == YQCalendarModeMonth){
        //返回一共有多少需要多少个月
        //同一年
        if(self.maxDate.year == self.minDate.year){
            return self.maxDate.month-self.minDate.month+1;
        }
        //不同年 且最大日期月份大于最小日期月份
        if(self.maxDate.month >= self.minDate.month){//不同年 且最大日期月份大于最小日期月份
            return (self.maxDate.year-self.minDate.year)*12+(self.maxDate.month-self.minDate.month+1);
        }else{//不同年 且最大日期月份小于最小日期月份
            return (self.maxDate.year-self.minDate.year)*12-(self.minDate.month-self.maxDate.month-1);
        }
    }else if(self.mode == YQCalendarModeWeek){
        return 1;
    }
    
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.mode == YQCalendarModeMonth){
        return ColumnCount*RowCountMonthMode;
    }else if(self.mode == YQCalendarModeWeek){
        return [self.maxDate daysLaterThan:self.minBeginningDate];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    YQCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
//    [cell showFlagDot:arc4random()%2];
    
    YQCellModel *model = [self cellModelForIndexPath:indexPath];
    cell.model = model;
    if([self.selectedDate isEqualToDate:model.date]){
        self.selectedIndexPath = indexPath;
        [cell select];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if(self.selectedIndexPath && [self.selectedIndexPath compare:indexPath] != NSOrderedSame){
        YQCalendarCell *oldCell = (YQCalendarCell *)[collectionView cellForItemAtIndexPath:self.selectedIndexPath];
        [oldCell reset];
    }
 
        
    YQCalendarCell *cell = (YQCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if(cell.model.dateType == YQDateTypeToday || cell.model.dateType == YQDateTypeCurrentMoth){
        self.selectedDate = cell.model.date;
        self.selectedIndexPath = indexPath;
        if(self.mode == YQCalendarModeMonth){
            self.targetRowOriginY = cell.model.row*self.collectionLayout.itemSize.height-self.headerView.frame.size.height;
        }
        [cell select];
    }else if(cell.model.dateType == YQDateTypePreMonth){
        //往前滚动一个月
    }else if(cell.model.dateType == YQDateTypeNextMonth){
        //往后滚动一个月
    }
    if([self.delegate respondsToSelector:@selector(calendar:didSelectDate:)]){
        [self.delegate calendar:self didSelectDate:cell.model.date];
        
    }
}
//- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
//    YQCalendarCell *cell = (YQCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    [cell reset];
//}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self setCurrentMonthBegginningDateWithOffset:scrollView.contentOffset.x];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self setCurrentMonthBegginningDateWithOffset:scrollView.contentOffset.x];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self setCurrentMonthBegginningDateWithOffset:scrollView.contentOffset.x];
    
}
#pragma mark public
- (void)selectCellByDate:(NSDate *)date{
    //如果跟现在的日期不同，取消原来的选中状态，重新设置
    if([self.selectedDate isEqualToDate:date]){
        return;
    }
    YQCalendarCell *cell = (YQCalendarCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPath];
    [cell reset];
    self.selectedDate = date;
    [self.collectionView reloadData];
}
- (void)scrollToDate:(NSDate *)date{
    if(self.mode == YQCalendarModeWeek){
        [self.collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.collectionView.bounds)*[date weeksLaterThan:self.minBeginningDate], 0)];
    }else{
        
        [self.collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.collectionView.bounds)*[self sectionIndexOfDate:date], 0) animated:NO];
    }
}
- (void)changeModel{
    //如果当前月份有选中时间滚动到这个时间所在的行
    //如果当前月份有今天就滚动到今天所在的行
    //如果什么都没有就滚动到第一行
    NSLog(@"%@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    if(self.mode == YQCalendarModeMonth){
        self.mode = YQCalendarModeWeek;

        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 50*2);
            
        } completion:^(BOOL finished) {
            [self.collectionView reloadData];
        }];
        
    }else{
        self.mode = YQCalendarModeMonth;
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 50*7);
        }];
        [self.collectionView reloadData];
    }

}

- (void)dealloc{
    
}
@end
