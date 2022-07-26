//
//  UsageDashboardViewController.h
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/26/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UsageDashboardViewController : UIViewController
{
@protected
    NSArray *parties;
}
@property (nonatomic, strong) IBOutlet NSArray *options;
@end

NS_ASSUME_NONNULL_END
