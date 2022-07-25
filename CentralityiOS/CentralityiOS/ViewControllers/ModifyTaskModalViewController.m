//
//  ModifyTaskModalViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/21/22.
//

#import "ModifyTaskModalViewController.h"
#import "DateFormatHelper.h"
#import "DateTools.h"
#import "IQKeyboardManager.h"

@interface ModifyTaskModalViewController () <UITextFieldDelegate, UITextViewDelegate>

@end

static NSString * const kAddTaskMode = @"Addding";
static NSString * const kEditTaskMode = @"Editing";
static const CGFloat kKeyboardDistanceFromTitleInput = 130.0;
static const CGFloat kKeyboardDistanceFromDescInput = 120.0;


@implementation ModifyTaskModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self.modifyMode isEqualToString:kEditTaskMode]){
        [self initModalForEditTaskMode];
    }
    else if([self.modifyMode isEqualToString:kAddTaskMode]){
        [self initModalForAddTaskMode];
    }
    
    NSMutableAttributedString *toInput = [[NSMutableAttributedString alloc] initWithString:self.taskTitleInput.text attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.taskTitleInput.attributedText = toInput;
    
    [self.taskTitleInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.taskTitleInput.delegate = self;
    self.taskDescInput.delegate = self;
    IQKeyboardManager.sharedManager.enable = true;
}


- (void)textFieldDidChange :(UITextField *) textField{
    NSMutableAttributedString *toInput = [[NSMutableAttributedString alloc] initWithString:textField.text attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    textField.attributedText = toInput;
    
    NSArray *todayKeywords = @[@"today", @"now", @"EOD"];
        [self highlightKeyword:todayKeywords inInputField:textField methodToExecute:@selector(todayKeywordAction)];
    
    NSArray *tomorrowKeywords = @[@"tmrw", @"tomorrow", @"2mrw"];
        [self highlightKeyword:tomorrowKeywords inInputField:textField methodToExecute:@selector(tomorrowKeywordAction)];
}

-(void)todayKeywordAction{
    NSLog(@"Today Variant Found!");
    self.taskDueDate = NSDate.date;
    [self reloadDueDateView:self.taskDueDate];
}
-(void)tomorrowKeywordAction{
    NSLog(@"Tomorrow Variant Found!");
    NSDate *newDate = [NSDate.date dateByAddingDays:1];
    self.taskDueDate = newDate;
    [self reloadDueDateView:self.taskDueDate];
}

- (void)highlightKeyword : (NSArray*) keywords inInputField:(UITextField*) inputField methodToExecute:(SEL)methodToExecute{
    
    NSMutableAttributedString *toInput = [[NSMutableAttributedString alloc] initWithString:inputField.text attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    for (NSString* keyword in keywords)
    {
        if ([inputField.text containsString:keyword]) {
            NSInteger subStringStartLocation = [inputField.text rangeOfString:keyword].location;
            NSInteger subStringLength = keyword.length;
            
            NSRange highlightRange = NSMakeRange(subStringStartLocation, subStringLength);
            [toInput addAttribute:NSBackgroundColorAttributeName value:[UIColor systemGreenColor] range:highlightRange];
            
            [self performSelector:methodToExecute];
            inputField.attributedText = toInput;
        }
    }
    
}

- (void)initModalForEditTaskMode{
    self.taskTitleInput.text = self.taskFromFeed.taskTitle;
    self.taskDescInput.text = self.taskFromFeed.taskDesc;
    self.modalTitle.text = @"Edit Task";
    [self.modifyButton setTitle:@"Update Task" forState:UIControlStateNormal];
    if (self.taskCategory){
        [self.changeCategoryButton setTitle:self.taskCategory.categoryName forState:UIControlStateNormal];
    }
    else{
        [self.changeCategoryButton setTitle:@"None" forState:UIControlStateNormal];
    }
    if (self.taskDueDate){
        NSString* formattedDate = [DateFormatHelper formatDateAsString:self.taskDueDate];
        [self.changeDateButton setTitle:formattedDate forState:UIControlStateNormal];
    }
    else{
        [self.changeCategoryButton setTitle:@"None" forState:UIControlStateNormal];
    }
}

-(void)initModalForAddTaskMode{
    
    self.taskTitleInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name this task" attributes:@{NSForegroundColorAttributeName: [UIColor systemGrayColor]}];
    
    [self.modifyButton setTitle:@"Add Task" forState:UIControlStateNormal];
    self.modalTitle.text = @"Add a Task";
}

- (IBAction)changeCategoryAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"Main" bundle:nil];
    CategoryModalViewController *categoryTaskModalVC = [storyboard instantiateViewControllerWithIdentifier:@"CategoryModalViewController"];
    categoryTaskModalVC.delegate = self;
    [self presentViewController:categoryTaskModalVC animated:YES completion:^{}];
}

- (IBAction)changeDueDateAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                    @"Main" bundle:nil];
    DueDateModalViewController *dueDateModalVC = [storyboard instantiateViewControllerWithIdentifier:@"DueDateModalViewController"];
    dueDateModalVC.delegate = self;
    [self presentViewController:dueDateModalVC animated:YES completion:^{}];
}

- (void)reloadCategoryView:(CategoryObject*)newCategory{
    if (newCategory){
        self.taskCategory = newCategory;
        [self.changeCategoryButton setTitle:self.taskCategory.categoryName forState:UIControlStateNormal];
    }
    else{
        [self.changeCategoryButton setTitle:@"None" forState:UIControlStateNormal];
    }
}

- (void)didChangeCategory:(CategoryObject *)item toFeed:(CategoryModalViewController *)controller{
    [self reloadCategoryView:item];
}

- (void)reloadDueDateView:(NSDate*)newDate{
    if (newDate){
        self.taskDueDate = newDate;
        NSString* formattedDate = [DateFormatHelper formatDateAsString:self.taskDueDate];
        [self.changeDateButton setTitle:formattedDate forState:UIControlStateNormal];
    }
    else{
        NSLog(@"Invalid date selected.");
        return;
    }
}

- (void)didChangeDuedate:(NSDate *)item toFeed:(DueDateModalViewController *)controller{
    [self reloadDueDateView:item];
}

- (IBAction)modifyTaskAction:(id)sender {
    if ([self.modifyMode isEqualToString:kAddTaskMode]){
        if ([self.taskTitleInput.text isEqualToString:@""]){
            NSLog(@"Empty title");
            return;
        }
            
        TaskObject *newTask = [TaskObject new];
        newTask.owner = [PFUser currentUser];
        newTask.taskTitle = self.taskTitleInput.text;
        newTask.taskDesc = self.taskDescInput.text;
        newTask.category = self.taskCategory;
        newTask.dueDate = self.taskDueDate;
        newTask.isCompleted = NO;
        
        [newTask saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self.delegate didAddNewTask:newTask toFeed:self];
                [self dismissViewControllerAnimated:YES completion:^{}];
            }
            else {
                NSLog(@"Task not added to Parse : %@", error.localizedDescription);
            }
        }];
    }
    else if([self.modifyMode isEqualToString:kEditTaskMode]){
        if ([self.taskTitleInput.text isEqualToString:@""]){
            NSLog(@"Empty title");
            return;
        }
        self.taskFromFeed.taskTitle = self.taskTitleInput.text;
        self.taskFromFeed.taskDesc = self.taskDescInput.text;
        self.taskFromFeed.category = self.taskCategory;
        self.taskFromFeed.dueDate = self.taskDueDate;
        [self.delegate didEditTask:self.taskFromFeed toFeed:self];
        [self dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    IQKeyboardManager.sharedManager.keyboardDistanceFromTextField = kKeyboardDistanceFromTitleInput;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    IQKeyboardManager.sharedManager.keyboardDistanceFromTextField = kKeyboardDistanceFromDescInput;
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}





#pragma mark - keyboard movements



@end
