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
#import "YQCalendarHeader.h"

static NSString *const Identifier = @"YQCalendarCell";

@interface YQCalendar ()<UICollectionViewDataSource,UICollectionViewDelegate>

/**
 *  最小时间月份的初始时间
 */
@property (nonatomic, strong, readonly) NSDate *minBeginningDate;
@property (nonatomic, strong, readonly) NSDate *selectedBeginningDate;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionLayout;
@property (nonatomic, strong) YQCalendarHeader *headerView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation YQCalendar

- (instancetype)init{
    if(self = [super init]){
        [self prepare];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        [self prepare];
    }
    return self;
}

- (instancetype)initWithAppearence:(YQCalendarAppearence *)appearence{
    return [self initWithFrame:CGRectZero appearence:appearence];
}

- (instancetype)initWithFrame:(CGRect)frame appearence:(YQCalendarAppearence *)appearence{
    if(self = [super initWithFrame:frame]){
        [self prepare];
        _appearence = appearence;;
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

    self.appearence = [[YQCalendarAppearence alloc] init];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionLayout];
    self.collectionView.backgroundColor = self.appearence.calendarBackgroundColor;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    [self.collectionView registerClass:[YQCalendarCell class] forCellWithReuseIdentifier:Identifier];
    
    [self addSubview:self.collectionView];


    //header
    _headerView = [[YQCalendarHeader alloc] init];
    [self addSubview:self.headerView];
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
    model.column = indexPath.item/RowCount;
    model.row = indexPath.item%RowCount;
    NSInteger index = model.row*ColumnCount+model.column;
    //确定月份的第一天
    NSDate *firstDay = [self.minBeginningDate dateByAddingMonths:indexPath.section];
    model.month = firstDay.month;
    //星期几
    NSInteger week = firstDay.weekday;//如果星期天是一周的第一天，那么这个月的第一天就在indexPath.row为week-1的位置上
    model.date = [firstDay dateByAddingDays:index-week+([YQCalendarAppearence share].firstDayIsSunday?1:2)];
    return model;
}

#pragma mark override

- (void)layoutSubviews{
    [super layoutSubviews];
    self.headerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.collectionView.bounds), [YQCalendarAppearence share].headerHeight);
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame),CGRectGetWidth(self.bounds) , CGRectGetHeight(self.bounds)-[YQCalendarAppearence share].headerHeight);
    CGFloat width = CGRectGetWidth(self.collectionView.bounds)/ColumnCount;
    CGFloat height = CGRectGetHeight(self.collectionView.bounds)/RowCount;
    self.collectionLayout.itemSize = CGSizeMake(width, height);
    [self.collectionView setContentOffset:CGPointMake(CGRectGetWidth(self.collectionView.bounds)*[self sectionIndexOfDate:[NSDate date]], 0) animated:NO];
}


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
    //返回一共有多少需要多少个月
    NSAssert([self.maxDate isLaterThan:self.minDate], @"最大最小日期设定不合适");
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
    
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return ColumnCount*RowCount;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    DDLogInfo(@"scroll animation end");
}

#pragma mark public
- (void)changeModel{
    //如果当前月份有选中时间滚动到这个时间所在的行
    //如果当前月份有今天就滚动到今天所在的行
    //如果什么都没有就滚动到第一行

}
@end
