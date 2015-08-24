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
@property (nonatomic, strong) NSIndexPath *targetIndexPath;

//父视图
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, assign) UIEdgeInsets scrollViewOriginalInset;
@property (nonatomic, assign) CGFloat tempOffsetY;
/**
 *  标记是否是展开状态
 */
@property (nonatomic, assign) BOOL expanded;
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
    
    if(self.mode == YQCalendarModeMonth){
        self.expanded = YES;
    }
    
    self.maxDate = [NSDate dateWithYear:2099 month:12 day:31];
    self.minDate = [NSDate dateWithYear:1970 month:1 day:1];
    
    _collectionLayout = [[UICollectionViewFlowLayout alloc] init];
    self.collectionLayout.itemSize = CGSizeZero;
    self.collectionLayout.minimumLineSpacing = 0;
    self.collectionLayout.minimumInteritemSpacing = 0;
    self.collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    if(!_appearence){
        _appearence = [[YQCalendarAppearence alloc] init];
    }
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionLayout];
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

//    self.scrollViewOriginalInset = self.scrollView.contentInset;
//    self.tempOffsetY = -self.scrollViewOriginalInset.top;
    
    RAC(self.headerView,monthLabel.text) = [RACObserve(self, currentMonthBeginningDate) map:^id(NSDate *value) {
        return [value formattedDateWithFormat:@"yyyy-MM"];
    }];
    [RACObserve(self, currentMonthBeginningDate) subscribeNext:^(id x) {
        //TODO:改变策略，获取当前的目标row
    }];
    
    NSDate *date = [NSDate date];
    self.currentMonthBeginningDate = [NSDate dateWithYear:date.year month:date.month day:1];
}

- (void)setCurrentMonthBegginningDateWithOffset:(CGFloat)offset{
    if(self.mode == YQCalendarModeMonth){
        self.currentMonthBeginningDate = [self.minBeginningDate dateByAddingMonths:offset/CGRectGetWidth(self.collectionView.bounds)];
    }else if(self.mode == YQCalendarModeWeek){
        //TODO:这里应该计算本周第一天的时间
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
- (void)willMoveToSuperview:(UIView *)newSuperview{
    [super willMoveToSuperview:newSuperview];
//    DDLogDebug(@"ff = %@",newSuperview.superview);
//    // 旧的父控件
//    [self.superview removeObserver:self forKeyPath:KeyPathContentOffset context:nil];
//    
//    if (newSuperview) { // 新的父控件
//        [newSuperview addObserver:self forKeyPath:KeyPathContentOffset options:NSKeyValueObservingOptionNew context:nil];
//        self.scrollView = (UIScrollView *)newSuperview;
//        // 记录UIScrollView最开始的contentInset
//        
//        DDLogDebug(@"temp offset y = %lf",self.tempOffsetY);
//        
//    }

}


- (void)layoutSubviews{
    NSLog(@"%@:%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [super layoutSubviews];

    self.collectionView.frame = self.bounds;
    
    CGFloat width = CGRectGetWidth(self.collectionView.bounds)/ColumnCount;
    CGFloat height = 0;
    if(self.mode == YQCalendarModeMonth){
        height = CGRectGetHeight(self.collectionView.bounds)/RowCountMonthMode;
    }else{
        height = CGRectGetHeight(self.collectionView.bounds)/RowCountWeekMode;
    }
    
    self.collectionLayout.itemSize = CGSizeMake(width, height);
    if(self.mode == YQCalendarModeMonth){
        [self.collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.collectionView.bounds)*[self sectionIndexOfDate:[NSDate date]], 0) animated:NO];
    }else if(self.mode == YQCalendarModeWeek){
        self.collectionView.contentOffset =CGPointMake([[NSDate date] daysLaterThan:self.minBeginningDate]*self.collectionLayout.itemSize.width, 0);
    }
}

//- (void)setAppearence:(YQCalendarAppearence *)appearence{
//    _appearence = appearence;
//    self.collectionView
//}
- (void)setMinDate:(NSDate *)minDate{
    if(_minDate != minDate){
        _minDate = minDate;
        _minBeginningDate = [NSDate dateWithYear:minDate.year month:minDate.month day:1];
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
//        return ColumnCount;
        return [self.maxDate daysLaterThan:self.minBeginningDate];
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    YQCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    [cell showFlagDot:arc4random()%2];
    YQCellModel *model = [self cellModelForIndexPath:indexPath];
    cell.model = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    YQCalendarCell *cell = (YQCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if(cell.model.dateType == YQDateTypeToday || cell.model.dateType == YQDateTypeCurrentMoth){
        self.selectedDate = cell.model.date;
        self.selectedIndexPath = indexPath;
        [cell select];
    }else if(cell.model.dateType == YQDateTypePreMonth){
        //往前滚动一个月
    }else if(cell.model.dateType == YQDateTypeNextMonth){
        //往后滚动一个月
    }
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    YQCalendarCell *cell = (YQCalendarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell reset];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    DDLogInfo(@"scroll x = %lf",scrollView.contentOffset.x);
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

- (CGFloat)targetRowOriginY{
    YQCalendar *cell =
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
