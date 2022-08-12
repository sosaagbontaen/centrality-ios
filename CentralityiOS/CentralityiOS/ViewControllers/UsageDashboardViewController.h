//
//  UsageDashboardViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UsageDashboardViewController : UIViewController
{
@protected
    NSArray *parties;
}
@property (weak, nonatomic) IBOutlet UILabel *dueTasksCounter;
@property (weak, nonatomic) IBOutlet UILabel *completedTasksCounter;
@property (weak, nonatomic) IBOutlet UILabel *completionRateCounter;
@property (weak, nonatomic) IBOutlet UILabel *collaboratorsCounter;

@property (nonatomic, strong) NSArray *options;
@end

NS_ASSUME_NONNULL_END

