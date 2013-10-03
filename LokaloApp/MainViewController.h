//
//  MainViewController.h
//  LokaloApp
//
//  Created by Ian MacKinnon on 2013-10-03.
//  Copyright (c) 2013 Ian MacKinnon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController<CLLocationManagerDelegate>

@property(nonatomic, strong) IBOutlet UISwitch *onSwitch;


-(IBAction)toggleSwitch:(id)sender;

@end

