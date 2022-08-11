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
#import "DetectableKeywords.h"
#import "CentralityHelpers.h"

@interface ModifyTaskModalViewController () <UITextFieldDelegate, UITextViewDelegate>

@end


@implementation ModifyTaskModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.modifyMode == EditTaskMode){
        [self initModalForEditTaskMode];
    }
    else if(self.modifyMode == AddTaskMode){
        [self initModalForAddTaskMode];
    }
    
    NSMutableAttributedString *toInput = [[NSMutableAttributedString alloc] initWithString:self.taskTitleInput.text attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.taskTitleInput.attributedText = toInput;
    
    [self.taskTitleInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    self.taskTitleInput.delegate = self;
    self.taskDescInput.delegate = self;
    IQKeyboardManager.sharedManager.enable = YES;
    [self.shareButton setTitle:[self updateShareDisplayMessage] forState:UIControlStateNormal];
    
    
    if (!self.taskReadOnlyUsers){
        self.taskReadOnlyUsers = [[NSMutableArray alloc] init];
    }
    if (!self.taskReadAndWriteUsers){
        self.taskReadAndWriteUsers = [[NSMutableArray alloc] init];
    }
    if (!self.taskAcceptedUsers){
        self.taskAcceptedUsers = [[NSMutableArray alloc] init];
    }
}

- (NSString*)updateShareDisplayMessage{
    NSString* shareDisplayMessage = [[NSString alloc]init];
    shareDisplayMessage = [NSString stringWithFormat:@"Sharing w/ %lu user",(unsigned long)self.taskSharedOwners.count];
    shareDisplayMessage = (self.taskSharedOwners.count != 1) ? [shareDisplayMessage stringByAppendingString:@"s"] : shareDisplayMessage;
    return shareDisplayMessage;
}

- (void)textFieldDidChange :(UITextField *) textField{
    NSMutableAttributedString *toInput = [[NSMutableAttributedString alloc] initWithString:textField.text attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    textField.attributedText = toInput;
    
    [self highlightKeyword:[DetectableKeywords getTodayKeywords] inInputField:textField newDate:NSDate.date];
    [self highlightKeyword:[DetectableKeywords getTomorrowKeywords] inInputField:textField newDate:[NSDate.date dateByAddingDays:1]];
    [self highlightKeyword:[DetectableKeywords getYesterdayKeywords] inInputField:textField newDate:[NSDate.date dateBySubtractingDays:1]];
}

- (void)highlightKeyword : (NSArray<NSString *>*) keywords inInputField:(UITextField*) inputField newDate:(NSDate*)newDate{
    
    NSMutableAttributedString *toInput = [[NSMutableAttributedString alloc] initWithString:inputField.text attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    for (NSString* keyword in keywords)
    {
        if ([inputField.text containsString:[NSString stringWithFormat:@" %@ ",keyword]]) {
            NSInteger subStringStartLocation = [inputField.text rangeOfString:keyword].location;
            NSInteger subStringLength = keyword.length;
            
            NSRange highlightRange = NSMakeRange(subStringStartLocation, subStringLength);
            [toInput addAttribute:NSBackgroundColorAttributeName value:[UIColor systemGreenColor] range:highlightRange];
            
            self.taskDueDate = newDate;
            [self reloadDueDateView:self.taskDueDate];
            
            inputField.attributedText = toInput;
        }
    }
    
}

- (void)initModalForEditTaskMode{
    self.taskTitleInput.text = self.taskFromFeed.taskTitle;
    self.taskDescInput.text = self.taskFromFeed.taskDesc;
    self.modalTitle.text = @"Edit";
    [self.modifyButton setTitle:@"Update Task" forState:UIControlStateNormal];
    
    if ([self.taskCategory fetchIfNeeded]){
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
        [self.changeDateButton setTitle:@"None" forState:UIControlStateNormal];
    }
}

-(void)initModalForAddTaskMode{
    
    self.taskTitleInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Name this task" attributes:@{NSForegroundColorAttributeName: [UIColor systemGrayColor]}];
    
    [self.modifyButton setTitle:@"Add" forState:UIControlStateNormal];
    self.modalTitle.text = @"Add a Task";
}
- (IBAction)shareAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main" bundle:nil];
    ShareModalViewController *shareModalVC = [storyboard instantiateViewControllerWithIdentifier:@"ShareModalViewController"];
    shareModalVC.delegate = self;
    if (self.taskSharedOwners){
        shareModalVC.arrayOfUsers = [self.taskSharedOwners mutableCopy];
    }
    else{
        shareModalVC.arrayOfUsers = [[NSMutableArray alloc]init];
    }
    if (self.taskFromFeed){
        shareModalVC.taskToUpdate = self.taskFromFeed;
    }
    else{
        shareModalVC.taskToUpdate = [TaskObject new];
        shareModalVC.taskToUpdate.owner = PFUser.currentUser;
        shareModalVC.taskToUpdate.readAndWriteUsers = self.taskReadAndWriteUsers;
        shareModalVC.taskToUpdate.readOnlyUsers = self.taskReadOnlyUsers;
        shareModalVC.taskToUpdate.acceptedUsers = self.taskAcceptedUsers;
    }
    [self presentViewController:shareModalVC animated:YES completion:^{}];
}

- (IBAction)changeCategoryAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main" bundle:nil];
    CategoryModalViewController *categoryTaskModalVC = [storyboard instantiateViewControllerWithIdentifier:@"CategoryModalViewController"];
    categoryTaskModalVC.delegate = self;
    categoryTaskModalVC.currentTaskCategory = self.taskCategory;
    [self presentViewController:categoryTaskModalVC animated:YES completion:^{}];
}

- (IBAction)changeDueDateAction:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:
                                @"Main" bundle:nil];
    DueDateModalViewController *dueDateModalVC = [storyboard instantiateViewControllerWithIdentifier:@"DueDateModalViewController"];
    dueDateModalVC.delegate = self;
    dueDateModalVC.previouslySelectedDate = self.taskDueDate;
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

- (void)didUpdateSharing:(PFUser *)user toFeed:(ShareModalViewController *)controller accessStatus:(PrivacyAccessStatus)accessStatus updateType:(PrivacyUpdateMode)updateMode{
    
    NSMutableDictionary* dictOfSharedOwners = [CentralityHelpers userDictionaryFromArray:self.taskSharedOwners];
    NSMutableDictionary* dictOfReadOnlyUsers = [CentralityHelpers userDictionaryFromArray:self.taskReadOnlyUsers];
    NSMutableDictionary* dictOfReadAndWriteUsers = [CentralityHelpers userDictionaryFromArray:self.taskReadAndWriteUsers];
    NSMutableDictionary* dictOfAcceptedUsers = [CentralityHelpers userDictionaryFromArray:self.taskAcceptedUsers];
    
    NSMutableArray<NSString*>* userObjectIds = [CentralityHelpers getArrayOfObjectIds:self.taskSharedOwners];
    
    if(updateMode == MakeUnshared){
        if ([dictOfSharedOwners objectForKey:user.objectId]){
            [dictOfSharedOwners removeObjectForKey:user.objectId];
            self.taskSharedOwners = [[dictOfSharedOwners allValues] mutableCopy];
        }
        if ([dictOfReadOnlyUsers objectForKey:user.objectId]){
            [dictOfReadOnlyUsers removeObjectForKey:user.objectId];
            self.taskReadOnlyUsers = [[dictOfReadOnlyUsers allValues] mutableCopy];
        }
        if ([dictOfReadAndWriteUsers objectForKey:user.objectId]){
            [dictOfReadAndWriteUsers removeObjectForKey:user.objectId];
            self.taskReadAndWriteUsers = [[dictOfReadAndWriteUsers allValues] mutableCopy];
        }
        if ([dictOfAcceptedUsers objectForKey:user.objectId]){
            [dictOfAcceptedUsers removeObjectForKey:user.objectId];
            self.taskAcceptedUsers = [[dictOfAcceptedUsers allValues] mutableCopy];
        }
    }
    else if(updateMode == MakeShared){
        if (self.taskSharedOwners == nil){
            self.taskSharedOwners = [[NSMutableArray alloc] init];
        }
        
        if (![userObjectIds containsObject:user.objectId]){
            dictOfSharedOwners[user.objectId] = user;
            self.taskSharedOwners = [[dictOfSharedOwners allValues] mutableCopy];
            
            if (accessStatus == ReadOnlyAccess){
                dictOfReadOnlyUsers[user.objectId] = user;
                self.taskReadOnlyUsers = [[dictOfReadOnlyUsers allValues] mutableCopy];
            }
            else if(accessStatus == ReadAndWriteAccess){
                dictOfReadAndWriteUsers[user.objectId] = user;
                self.taskReadAndWriteUsers = [[dictOfReadAndWriteUsers allValues] mutableCopy];
                
            }
        }
    }
    else if (updateMode == MakeReadOnly){
        if ([dictOfReadAndWriteUsers objectForKey:user.objectId]){
            dictOfReadOnlyUsers[user.objectId] = user;
            self.taskReadOnlyUsers = [[dictOfReadOnlyUsers allValues] mutableCopy];
            [dictOfReadAndWriteUsers removeObjectForKey:user.objectId];
            self.taskReadAndWriteUsers = [[dictOfReadAndWriteUsers allValues] mutableCopy];
        }
    }
    else if (updateMode == MakeWritable){
        if ([dictOfReadOnlyUsers objectForKey:user.objectId]){
            dictOfReadAndWriteUsers[user.objectId] = user;
            self.taskReadAndWriteUsers = [[dictOfReadAndWriteUsers allValues] mutableCopy];
            [dictOfReadOnlyUsers removeObjectForKey:user.objectId];
            self.taskReadOnlyUsers = [[dictOfReadOnlyUsers allValues] mutableCopy];
        }
    }
    
    [self.shareButton setTitle:[self updateShareDisplayMessage] forState:UIControlStateNormal];
}

- (IBAction)modifyTaskAction:(id)sender {
    if ([self.taskTitleInput.text isEqualToString:@""]){
        [CentralityHelpers showAlert:@"Empty Task Name" alertMessage:@"Please name this task" currentVC:self];
        return;
    }
    if (self.modifyMode == AddTaskMode){
        TaskObject *newTask = [TaskObject new];
        newTask.owner = [PFUser currentUser];
        newTask.taskTitle = self.taskTitleInput.text;
        newTask.taskDesc = self.taskDescInput.text;
        newTask.category = self.taskCategory;
        newTask.category.numberOfTasksInCategory++;
        [newTask.category saveInBackground];
        newTask.dueDate = self.taskDueDate;
        newTask.isCompleted = NO;
        newTask.sharedOwners = self.taskSharedOwners;
        newTask.readOnlyUsers = self.taskReadOnlyUsers;
        newTask.readAndWriteUsers = self.taskReadAndWriteUsers;
        newTask.acceptedUsers = self.taskAcceptedUsers;
        
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
    else if(self.modifyMode == EditTaskMode){
        self.taskFromFeed.taskTitle = self.taskTitleInput.text;
        self.taskFromFeed.taskDesc = self.taskDescInput.text;
        if (self.taskCategory != self.taskFromFeed.category){
            self.taskFromFeed.category.numberOfTasksInCategory--;
            self.taskCategory.numberOfTasksInCategory++;
            [self.taskCategory saveInBackground];
            [self.taskFromFeed.category saveInBackground];
        }
        self.taskFromFeed.category = self.taskCategory;
        self.taskFromFeed.dueDate = self.taskDueDate;
        self.taskFromFeed.sharedOwners = self.taskSharedOwners;
        self.taskFromFeed.readOnlyUsers = self.taskReadOnlyUsers;
        self.taskFromFeed.readAndWriteUsers = self.taskReadAndWriteUsers;
        self.taskFromFeed.acceptedUsers = self.taskAcceptedUsers;
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

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    //Adding space upon field deselect to prevent bug where attributes expand to entire text field after selecting a different field/view
    NSMutableAttributedString *stringWithSpaceAdded = [[NSMutableAttributedString alloc] initWithAttributedString:textField.attributedText];
    [stringWithSpaceAdded appendAttributedString:[[NSMutableAttributedString alloc] initWithString:@" "]];
    
    textField.attributedText = stringWithSpaceAdded;
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
