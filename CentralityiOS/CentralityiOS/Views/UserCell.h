//
//  UserCell.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/27/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
NS_ASSUME_NONNULL_BEGIN

@interface UserCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *privacyStatusLabel;
@end

NS_ASSUME_NONNULL_END
