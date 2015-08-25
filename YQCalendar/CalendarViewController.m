//
//  CalendarViewController.m
//  YQCalendar
//
//  Created by Wang on 15/8/24.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "CalendarViewController.h"
#import "YQCalendar.h"

static CGFloat const RowHeight = 50.0f;

@interface CalendarViewController () <UITableViewDelegate,UITableViewDataSource,YQCalendarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) YQCalendar *monthCalendar;
@property (nonatomic, strong) YQCalendar *weekCalendar;
@property (nonatomic, strong) YQCalendarHeader *calendarHeader;

@property (assign, nonatomic) CGFloat criticalOriginY;
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
    
    self.monthCalendar = ({
        YQCalendar *calendar = [[YQCalendar alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, RowHeight*RowCountMonthMode)];
        [self.tableView addCalendar:calendar];
        calendar.delegate = self;
        calendar;
    });
    
    self.calendarHeader = ({
        YQCalendarHeader *header = [[YQCalendarHeader alloc] initWithFrame:CGRectMake(0,self.automaticallyAdjustsScrollViewInsets? NavHeight(self):0, self.monthCalendar.bounds.size.width, [YQCalendarAppearence share].headerHeight)];
        header.backgroundColor = [UIColor orangeColor];
        [self.view addSubview:header];
        self.monthCalendar.headerView = header;
        header;
    });
    self.weekCalendar = ({
        YQCalendar *weekCalendar = [[YQCalendar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.calendarHeader.frame), self.tableView.bounds.size.width, RowHeight) appearence:nil mode:YQCalendarModeWeek];
        [self.view addSubview:weekCalendar];
        weekCalendar.delegate = self;
        self.weekCalendar.hidden = YES;
        weekCalendar;
    });
    [self.monthCalendar scrollToDate:[NSDate date]];
    [self.weekCalendar scrollToDate:[NSDate date]];
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

    return 100;
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
    //如果目标行到了目标位置，周视图日历显示
    if(scrollView.contentOffset.y > self.criticalOriginY){
        self.weekCalendar.hidden = NO;
    }else{
        if(!self.weekCalendar.isHidden){
            self.weekCalendar.hidden = YES;
        }
    }
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if(self.weekCalendar.hidden){
        self.criticalOriginY = self.monthCalendar.targetRowOriginY+CGRectGetMinY(self.monthCalendar.frame)-NavHeight(self);
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{

}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
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
