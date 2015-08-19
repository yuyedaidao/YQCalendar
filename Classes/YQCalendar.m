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

@interface YQCalendar ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) NSDate *minDate;
@property (nonatomic, strong) NSDate *maxDate;

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
    self.collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionLayout];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.scrollsToTop = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark override

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = CGRectGetWidth(self.collectionView.bounds);
    self.collectionLayout.itemSize = CGSizeMake(width, width);
}

#pragma mark collection delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    //返回一共有多少需要多少个月
    return [self.maxDate yearsLaterThan:self.minDate]*12+self.maxDate.month+(13-self.minDate.month);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 5*7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    return nil;
}
@end
