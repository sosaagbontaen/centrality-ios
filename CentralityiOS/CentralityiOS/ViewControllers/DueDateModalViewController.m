//
//  DueDateModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/21/22.
//

#import "DueDateModalViewController.h"


@interface DueDateModalViewController () <FSCalendarDelegate, FSCalendarDataSource>

@end

@implementation DueDateModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.calendarView.dataSource = self;
    self.calendarView.delegate = self;
    [self.view addSubview:self.calendarView];
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
