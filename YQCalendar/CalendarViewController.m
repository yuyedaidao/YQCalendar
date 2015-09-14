//
//  CalendarViewController.m
//  YQCalendar
//
//  Created by Wang on 15/8/24.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "CalendarViewController.h"
#import "YQCalendar.h"
#import <POP.h>
static CGFloat const RowHeight = 50.0f;
@interface CalendarViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) YQCalendar *monthCalendar;
@property (nonatomic, strong) YQCalendar *weekCalendar;
@property (nonatomic, strong) YQCalendarHeader *calendarHeader;

@property (assign, nonatomic) CGFloat criticalOriginY;
@property (assign, nonatomic) CGFloat begeinDragOffset;
@property (assign, nonatomic) CGFloat originalInsetTop;
@property (assign, nonatomic) CGFloat minInsetTop;
@property (assign, nonatomic) BOOL expanded;
@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.frame = [UIScreen mainScreen].bounds;

    self.expanded = YES;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.frame = self.view.bounds;
    

    self.monthCalendar = [[YQCalendar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, RowHeight*RowCountMonthMode)];
//    [self.tableView addCalendar:self.monthCalendar];
    self.originalInsetTop = self.tableView.contentInset.top+NavHeight(self);
    self.monthCalendar.delegate = self;
 
   
    self.calendarHeader = [[YQCalendarHeader alloc] initWithFrame:CGRectMake(0,self.automaticallyAdjustsScrollViewInsets? NavHeight(self):0, self.monthCalendar.bounds.size.width, [YQCalendarAppearence share].headerHeight)];
    self.calendarHeader.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:self.calendarHeader];
    self.monthCalendar.headerView = self.calendarHeader;
   
   
//    self.weekCalendar = [[YQCalendar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.calendarHeader.frame), self.tableView.bounds.size.width, RowHeight) appearence:nil mode:YQCalendarModeWeek];
    [self.view addSubview:self.weekCalendar];
    self.weekCalendar.delegate = self;
    self.weekCalendar.hidden = YES;
    self.weekCalendar.backgroundColor = [UIColor greenColor];

    self.minInsetTop = CGRectGetMaxY(self.weekCalendar.frame);

    [self.monthCalendar scrollToDate:[NSDate date]];
    [self.weekCalendar scrollToDate:[NSDate date]];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.tableView scrollRectToVisible:CGRectMake(0, 700, self.tableView.bounds.size.width, 10) animated:YES];
////        [UIView animateWithDuration:1.5 animations:^{
////            self.tableView.contentOffset = CGPointMake(0, 700);
////        }];
//    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark yqcalendar
- (void)calendar:(YQCalendar *)calendar didSelectDate:(NSDate *)date{
    if(calendar == self.monthCalendar){
        [self.weekCalendar selectCellByDate:date];
        [self.weekCalendar scrollToDate:date];
    }else{
        [self.monthCalendar selectCellByDate:date];
        [self.monthCalendar scrollToDate:date];
    }
}
- (void)calendar:(YQCalendar *)calendar didChangeMonth:(NSDate *)date{
    if(calendar == self.monthCalendar){
        [self.weekCalendar scrollToDate:date];
    }else if(calendar == self.weekCalendar){
        
    }
}

#pragma mark table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 44.0f;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = [@(indexPath.row) stringValue];
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(scrollView.isDragging || scrollView.isDecelerating){
        if(-scrollView.contentOffset.y>=self.minInsetTop && -scrollView.contentOffset.y<=self.originalInsetTop){
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
 
        }else if(-scrollView.contentOffset.y>self.originalInsetTop){
            if(scrollView.contentInset.top != self.originalInsetTop){
                scrollView.contentInset = UIEdgeInsetsMake(self.originalInsetTop, 0, 0, 0);
            }
        }else if(-scrollView.contentOffset.y<self.minInsetTop){
            if(scrollView.contentInset.top != self.minInsetTop){
                scrollView.contentInset = UIEdgeInsetsMake(self.minInsetTop, 0, 0, 0);
            }
        }
 
        [self checkWeekCalendarShouldShowBySelf:self];
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(self.weekCalendar.hidden){
        self.criticalOriginY = self.monthCalendar.targetRowOriginY+CGRectGetMinY(self.monthCalendar.frame)-NavHeight(self);
    }
    self.begeinDragOffset = scrollView.contentOffset.y;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if(!decelerate){
        [self checkChangeMode];
    }
}

- (POPBasicAnimation *)scrollViewContentInsetAnimation{
    POPBasicAnimation *animation = [self.tableView pop_animationForKey:ContentInsetAnimation];
    if(!animation){
        __weak typeof(self) weakSelf = self;
        animation = [POPBasicAnimation animation];
        animation.property = [POPMutableAnimatableProperty
                              propertyWithName:ContentInsetAnimation
                              initializer:^(POPMutableAnimatableProperty *prop) {
                                  prop.writeBlock = ^(UIScrollView *scrollView, const CGFloat values[]) {
                                      __strong typeof(weakSelf) strongSelf = weakSelf;
                                      strongSelf.tableView.contentInset = UIEdgeInsetsMake(values[0], 0, 0, 0);
                                      strongSelf.tableView.contentOffset = CGPointMake(0, -values[0]);
                                      [strongSelf checkWeekCalendarShouldShowBySelf:strongSelf];
                                  };
                              }];
        
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animation.duration = YQAnmiationDuration;
        [self.tableView pop_addAnimation:animation forKey:ContentInsetAnimation];
    }
    return animation;
}
- (void)checkWeekCalendarShouldShowBySelf:(CalendarViewController *)weakSelf{
    if(weakSelf.tableView.contentOffset.y > weakSelf.criticalOriginY){//这里不能 >= 在等于的情况下是不应该显示的
        weakSelf.weekCalendar.hidden = NO;
    }else{
        if(!weakSelf.weekCalendar.isHidden){
            weakSelf.weekCalendar.hidden = YES;
        }
    }

}
- (void)checkChangeMode{
    CGFloat difference = self.tableView.contentOffset.y-self.begeinDragOffset;
    if(self.weekCalendar.hidden){
        //正往上
        if(difference > CGRectGetHeight(self.weekCalendar.bounds)){
            //切换到周视图

            POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
            animation.fromValue = @(self.tableView.contentInset.top);
            animation.toValue = @(self.minInsetTop);
            
        }else{
            
            POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
            animation.fromValue = @(self.tableView.contentInset.top);
            animation.toValue = @(self.originalInsetTop);
            
        }
    }else{
        if(difference < -CGRectGetHeight(self.weekCalendar.bounds)){
            POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
            animation.fromValue = @(self.tableView.contentInset.top);
            animation.toValue = @(self.originalInsetTop);
           
        }else{
            POPBasicAnimation *animation = [self scrollViewContentInsetAnimation];
            animation.fromValue = @(self.tableView.contentInset.top);
            animation.toValue = @(self.minInsetTop);

        }
    }
    
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
