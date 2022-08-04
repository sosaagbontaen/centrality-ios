//
//  TaskCell.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "TaskObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface TaskCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskDescLabel;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *sharedLabel;
@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceBetweenCategoryAndDate;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceBetweenDateAndShared;
@property TaskObject* task;
- (void)refreshCell;
@end

NS_ASSUME_NONNULL_END
