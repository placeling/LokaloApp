//
//  LoginViewController.m
//  LokaloApp
//
//  Created by Ian MacKinnon on 2013-10-03.
//  Copyright (c) 2013 Ian MacKinnon. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import <SVProgressHUD.h>


@interface LoginViewController ()

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if ( [FBSession.activeSession isOpen] ) {
        // No, display the login page.
        MainViewController *mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainViewController"];
        [self presentViewController:mainViewController animated:true completion:nil];
    }
}



- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            
            [SVProgressHUD showSuccessWithStatus:@"Authenticated!"];
            
            MainViewController *mainViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"mainViewController"];
            [self presentViewController:mainViewController animated:true completion:nil];
            break;
        }
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:{
            // Once the user has logged in, we want them to
            // be looking at the root view.
            [FBSession.activeSession closeAndClearTokenInformation];
            
            break;
        }
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}




-(IBAction) connectFacebook:(id)sender{
    [FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObjects:@"email", @"publish_actions", nil] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:TRUE completionHandler:^(FBSession *session,
                                                                                                                                                                                                                           FBSessionState state, NSError *error) {
        [self sessionStateChanged:session state:state error:error];
    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
