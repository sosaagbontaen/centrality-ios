//
//  TaskCell.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/11/22.
//

#import "TaskCell.h"
#import "TaskObject.h"

@implementation TaskCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
- (IBAction)completeAction:(id)sender {
    if (self.task.isCompleted == NO){
        self.task.isCompleted = YES;
    }
    else{
        self.task.isCompleted = NO;
    }
    [self.task saveInBackground];
    [self refreshCell];
}

- (void)refreshCell{
    UIImage *incompleteImage = [UIImage systemImageNamed:@"circle"];
    UIImage *completeImage = [UIImage systemImageNamed:@"checkmark.circle.fill"];
    UIColor *completeColor = [UIColor grayColor];
    UIColor *inCompleteColor = [UIColor blackColor];
    
    [self.completeButton setSelected:FALSE];
    [self.completeButton setHighlighted:FALSE];
    
    if (self.task.isCompleted == YES){
        [self.completeButton setImage:completeImage forState:UIControlStateNormal];
        self.taskNameLabel.textColor = completeColor;
    }
    else{
        [self.completeButton setImage:incompleteImage forState:UIControlStateNormal];
        self.taskNameLabel.textColor = inCompleteColor;
    }
}

@end
