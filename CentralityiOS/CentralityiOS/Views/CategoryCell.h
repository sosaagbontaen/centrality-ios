//
//  CategoryCell.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/20/22.
//

#import <UIKit/UIKit.h>
#import "CategoryObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface CategoryCell : UITableViewCell
@property CategoryObject* category;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@end

NS_ASSUME_NONNULL_END
