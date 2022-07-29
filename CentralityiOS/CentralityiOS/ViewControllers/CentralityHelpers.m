//
//  CentralityHelpers.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/28/22.
//

#import "CentralityHelpers.h"

@interface CentralityHelpers ()

@end

@implementation CentralityHelpers
+ (void)showAlert:(NSString*)alertTitle alertMessage:(NSString*)alertMessage currentVC:(UIViewController*)currentVC{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:alertTitle
                               message:alertMessage
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    [currentVC presentViewController:alert animated:YES completion:nil];
}
@end
