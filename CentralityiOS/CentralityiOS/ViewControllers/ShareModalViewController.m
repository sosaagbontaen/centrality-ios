//
//  ShareModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/27/22.
//

#import "ShareModalViewController.h"
#import "UserCell.h"

@interface ShareModalViewController ()<UITableViewDelegate, UITableViewDataSource>

@end

@implementation ShareModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userTableView.dataSource = self;
    self.userTableView.delegate = self;
}

- (IBAction)addCategoryAction:(id)sender {
    
}
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

@end
