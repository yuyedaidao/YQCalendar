//
//  NewCalendarViewController.m
//  YQCalendar
//
//  Created by Wang on 15/8/31.
//  Copyright (c) 2015年 王叶庆. All rights reserved.
//

#import "NewCalendarViewController.h"
#import "YQCalendarView.h"
#import "YQCalendarWeekLabel.h"

@interface NewCalendarViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) YQCalendarView *calendarView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation NewCalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    

    self.calendarView = [[YQCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50*6)];
    [self.tableView addCalendarView:self.calendarView];
    
}


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
    [self.calendarView calendarScrollViewDidScroll:scrollView];
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self.calendarView calendarScrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.calendarView calendarScrollViewWillBeginDragging:scrollView];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self.calendarView calendarScrollViewDidEndDecelerating:scrollView];
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    [self.calendarView calendarScrollViewWillBeginDecelerating:scrollView];
}
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    [self.calendarView calendarScrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
