//
//  LoginViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/18/22.
//

#import "LoginViewController.h"
#import "Parse/Parse.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIButton *signupButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@end

@implementation LoginViewController
- (IBAction)loginAction:(id)sender {
    if ([self.usernameField.text isEqual:@""] && [self.passwordField.text isEqual:@""]){
        [self alert:@"Invalid username and password" messageLabel:@"Username and password fields are empty" label:@"OK"];
        return;
    }
    else if ([self.usernameField.text isEqual:@""]){
        [self alert:@"Invalid username" messageLabel:@"Username field is empty" label:@"OK"];
        return;
    }
    else if ([self.passwordField.text isEqual:@""]){
        [self alert:@"Invalid password" messageLabel:@"Password field is empty" label:@"OK"];
        return;
    }
    
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
        
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error != nil) {
            NSLog(@"User log in failed: %@", error.localizedDescription);
            [self alert:@"Incorrect Password" messageLabel:@"The password you entered is incorrect. Please try again." label:@"OK"];
        } else {
            NSLog(@"User logged in successfully");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}
- (IBAction)signupAction:(id)sender {
    if ([self.usernameField.text isEqual:@""] && [self.passwordField.text isEqual:@""]){
        [self alert:@"Invalid username and password" messageLabel:@"Username and password fields are empty" label:@"OK"];
        return;
    }
    else if ([self.usernameField.text isEqual:@""]){
        [self alert:@"Invalid username" messageLabel:@"Username field is empty" label:@"OK"];
        return;
    }
    else if ([self.passwordField.text isEqual:@""]){
        [self alert:@"Invalid password" messageLabel:@"Password field is empty" label:@"OK"];
        return;
    }
    
    // initialize a user object
    PFUser *newUser = [PFUser user];
    
    // set user properties
    newUser.username = self.usernameField.text;
    newUser.password = self.passwordField.text;
    
    // call sign up function on the object
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error != nil) {
            NSLog(@"Error: %@", error.localizedDescription);
            [self alert:@"Invalid Username or Password" messageLabel:@"Username may be taken." label:@"OK"];
        } else {
            NSLog(@"User registered successfully");
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
}

- (void)alert:(NSString *)titleLabel messageLabel:(NSString *)messageLabel leftLabel: (NSString *)leftLabel rightLabel: (NSString *)rightLabel{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleLabel
                                                                               message:messageLabel
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:leftLabel
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle cancel response here. Doing nothing will dismiss the view.
                                                      }];
    [alert addAction:cancelAction];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:rightLabel
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle response here.
                                                     }];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}

- (void)alert:(NSString *)titleLabel messageLabel:(NSString *)messageLabel label: (NSString *)label{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleLabel
                                                                               message:messageLabel
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *onlyAction = [UIAlertAction actionWithTitle:label
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                             // handle cancel response here. Doing nothing will dismiss the view.
                                                      }];
    [alert addAction:onlyAction];
    
    [self presentViewController:alert animated:YES completion:^{
        // optional code for what happens after the alert controller has finished presenting
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    BOOL isFirstResponder = self.passwordField.isFirstResponder;
    if (isFirstResponder){
        [self.passwordField resignFirstResponder];
    }
    self.passwordField.secureTextEntry = !self.passwordField.secureTextEntry;
    if (isFirstResponder){
        [self.passwordField becomeFirstResponder];
    };
}

@end
