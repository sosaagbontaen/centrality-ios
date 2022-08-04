//
//  ReceiverCell.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/1/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReceiverCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *taskNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskDescLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskOwnerLabel;
@property (weak, nonatomic) IBOutlet UILabel *taskSharerLabel;
@end

NS_ASSUME_NONNULL_END
