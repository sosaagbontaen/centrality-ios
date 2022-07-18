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
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    BOOL usernameIsEmpty = [username isEqual:@""];
    BOOL passwordIsEmpty = [password isEqual:@""];
    
    if (usernameIsEmpty && passwordIsEmpty){
        [self alert:@"Invalid username and password" messageLabel:@"Username and password fields are empty" label:@"OK"];
        return;
    }
    else if (usernameIsEmpty){
        [self alert:@"Invalid username" messageLabel:@"Username field is empty" label:@"OK"];
        return;
    }
    else if (passwordIsEmpty){
        [self alert:@"Invalid password" messageLabel:@"Password field is empty" label:@"OK"];
        return;
    }
        
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
    
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    BOOL usernameIsEmpty = [username isEqual:@""];
    BOOL passwordIsEmpty = [password isEqual:@""];
    
    if (usernameIsEmpty && passwordIsEmpty){
        [self alert:@"Invalid username and password" messageLabel:@"Username and password fields are empty" label:@"OK"];
        return;
    }
    else if (usernameIsEmpty){
        [self alert:@"Invalid username" messageLabel:@"Username field is empty" label:@"OK"];
        return;
    }
    else if (passwordIsEmpty){
        [self alert:@"Invalid password" messageLabel:@"Password field is empty" label:@"OK"];
        return;
    }
    
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    
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

- (void)alert:(NSString *)titleLabel messageLabel:(NSString *)messageLabel label: (NSString *)label{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:titleLabel
                                                                               message:messageLabel
                                                                        preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *onlyAction = [UIAlertAction actionWithTitle:label
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                      }];
    [alert addAction:onlyAction];
    
    [self presentViewController:alert animated:YES completion:^{
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
