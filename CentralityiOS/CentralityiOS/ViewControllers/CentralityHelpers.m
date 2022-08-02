//
//  CentralityHelpers.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/28/22.
//

#import "CentralityHelpers.h"
#import "Parse/Parse.h"
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

+ (NSMutableArray*)getArrayOfObjectIds:(NSMutableArray*)userArray{
    NSMutableArray* returnArray = [[NSMutableArray alloc] init];
    for (PFUser* user in userArray) {
        [returnArray addObject:user.objectId];
    }
    return returnArray;
}

+ (void) updateLabel:(UILabel*)label newText:(NSString*)newText isHidden:(BOOL)isHidden{
    label.text = newText;
    label.hidden = isHidden;
}

+ (NSArray<PFUser*>*)removeUser:(PFUser*)user FromArray:(NSArray<PFUser*>*)arrayToCheck{
    for (int i = 0; i < arrayToCheck.count; i++) {
        if ([arrayToCheck[i].objectId isEqualToString:user.objectId]){
            NSMutableArray *copyOfArrayToCheck = [arrayToCheck mutableCopy];
            [copyOfArrayToCheck removeObjectAtIndex:i];
            arrayToCheck = copyOfArrayToCheck;
        }
    }
    return arrayToCheck;
}

+ (NSArray<PFUser*>*)addUser:(PFUser*)user ToArray:(NSArray<PFUser*>*)receivingArray{
        NSMutableArray *copyOfReceivingArray = [receivingArray mutableCopy];
        [copyOfReceivingArray addObject:user];
        receivingArray = copyOfReceivingArray;
    return receivingArray;
}
@end
