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

static NSInteger const RowCount = 6;
static NSInteger const ColumnCount = 7;
static NSString *const Identifier = @"YQCalendarCell";

@interface YQCalendar ()<UICollectionViewDataSource,UICollectionViewDelegate>

/**
 *  最小时间月份的初始时间
 */
@property (nonatomic, strong, readonly) NSDate *minBeginningDate;


@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionLayout;
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

    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionLayout];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    [self.collectionView registerNib:[UINib nibWithNibName:Identifier bundle:nil] forCellWithReuseIdentifier:Identifier];
    
    self.collectionView.backgroundColor = self.appearence.calendarBackgroundColor;
    
    [self addSubview:self.collectionView];
//    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
    
    //改变collectionView的位置时会触发数据的加载
    DDLogDebug(@"sectionIndexOfCurrent = %ld",[self sectionIndexOfDate:[NSDate date]]);


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
    //列、排
    NSInteger column = indexPath.item/RowCount;
    NSInteger row = indexPath.item%RowCount;
    NSInteger index = row*ColumnCount+column;
    YQCellModel *model = [[YQCellModel alloc] init];
    model.indexPath = indexPath;
    //确定月份的第一天
    NSDate *firstDay = [self.minBeginningDate dateByAddingMonths:indexPath.section];
    model.month = firstDay.month;
    //星期几
    NSInteger week = firstDay.weekday;//如果星期天是一周的第一天，那么这个月的第一天就在indexPath.row为week-1的位置上
    model.date = [firstDay dateByAddingDays:index-week+(self.firstIsSunday?1:2)];
    return model;
}

#pragma mark override

- (void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
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
- (YQCalendarAppearence *)appearence{
    if(!_appearence){
        _appearence = [[YQCalendarAppearence alloc] init];
    }
    return _appearence;
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
    YQCellModel *model = [self cellModelForIndexPath:indexPath];
    cell.model = model;
    return cell;
}

#pragma mark test

- (void)testItemsLocation{
    [[self.collectionView visibleCells] enumerateObjectsUsingBlock:^(YQCalendarCell *obj, NSUInteger idx, BOOL *stop) {
        DDLogDebug(@"obj indexPath = %@",obj.model.indexPath);
        DDLogDebug(@"obj date day = %ld",obj.model.date.day);
        DDLogDebug(@"obj location = %@",NSStringFromCGRect(obj.frame));
    }];
}
@end
