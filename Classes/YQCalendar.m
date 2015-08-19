//
//  YQCalendar.m
//  YQCalendar
//
//  Created by 王叶庆 on 15/8/19.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "YQCalendar.h"


@interface YQCalendar ()

@property (nonatomic,strong) UICollectionView *collectionView;
@property (nonatomic,strong) UICollectionViewFlowLayout *collectionLayout;
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

- (void)awakeFromNib{
    [self prepare];
}

#pragma mark self handler

- (void)prepare{

}
@end
