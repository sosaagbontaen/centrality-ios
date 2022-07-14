//
//  AppDelegate.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 7/8/22.
//

#import "AppDelegate.h"
#import "Parse/Parse.h"

static const NSString *applicationIdObj = @"applicationId";
static const NSString *clientKeyObj = @"clientKey";
static NSString *serverURL = @"https://parseapi.back4app.com";
static NSString *keysFileName = @"Keys";
static NSString *keysFileExtension = @"plist";

@implementation AppDelegate
    

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {

        NSString *path = [[NSBundle mainBundle] pathForResource: keysFileName ofType: keysFileExtension];
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: path];

        NSString *applicationId = [dict objectForKey: applicationIdObj];
        NSString *clientKey = [dict objectForKey: clientKeyObj];
        
        configuration.applicationId = [NSString stringWithFormat:@"%@", applicationId];
        configuration.clientKey = [NSString stringWithFormat: @"%@", clientKey];
        configuration.server = serverURL;
    }];

    [Parse initializeWithConfiguration:config];
    return YES;
}


#pragma mark - UISceneSession lifecycle

- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}
@end
