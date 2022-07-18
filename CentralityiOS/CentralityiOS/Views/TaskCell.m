//
//  TaskCell.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import "TaskCell.h"
#import "TaskObject.h"

static NSString * const kIncompleteImageName = @"circle";
static NSString * const kCompleteImageName = @"checkmark.circle.fill";

@implementation TaskCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (IBAction)completeAction:(id)sender {
    self.task.isCompleted = !self.task.isCompleted;
    [self.task saveInBackground];
    [self refreshCell];
}

- (void)refreshCell{
    UIImage *incompleteImage = [UIImage systemImageNamed:kIncompleteImageName];
    UIImage *completeImage = [UIImage systemImageNamed:kCompleteImageName];
    UIColor *completeColor = [UIColor grayColor];
    UIColor *inCompleteColor = [UIColor blackColor];
    
    [self.completeButton setSelected:NO];
    [self.completeButton setHighlighted:NO];
    
    if (self.task.isCompleted){
        [self.completeButton setImage:completeImage forState:UIControlStateNormal];
        self.taskNameLabel.textColor = completeColor;
    }
    else{
        [self.completeButton setImage:incompleteImage forState:UIControlStateNormal];
        self.taskNameLabel.textColor = inCompleteColor;
    }
}

@end
