//
//  MainViewController.m
//  LokaloApp
//
//  Created by Ian MacKinnon on 2013-10-03.
//  Copyright (c) 2013 Ian MacKinnon. All rights reserved.
//

#import "MainViewController.h"
#import <UIImageView+WebCache.h>

@interface MainViewController (){
    CLLocationManager *_locationManager;
    NSUUID *_uuid;
    BOOL _notifyOnDisplay;
}

@end

@implementation MainViewController

@synthesize onSwitch;
@synthesize profileView;
@synthesize nameLabel;

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
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:@"com.lokaloapp.LokaloApp"];
    region = [_locationManager.monitoredRegions member:region];
    if(region)
    {
        _uuid = region.proximityUUID;
        _notifyOnDisplay = region.notifyEntryStateOnDisplay;
        self.onSwitch.on = true;
        [_locationManager startMonitoringForRegion:region];
    }
    else
    {
        // Default settings.
        _uuid =  [[NSUUID alloc] initWithUUIDString:LOKALO_UUID];
        _notifyOnDisplay = NO;
        self.onSwitch.on = false;
    }
    
    [[FBRequest requestForMe] startWithCompletionHandler:
     ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
         [self receiveGraphConnection:connection userDictionary:user token:[FBSession.activeSession.accessTokenData accessToken ] error:error];
     }];
}

-(void) receiveGraphConnection:(FBRequestConnection*)connection
                userDictionary:(NSDictionary<FBGraphUser>*)user
                         token:(NSString *)token
                         error:(NSError*)error{
    self.nameLabel.text = user.name;
}


-(IBAction)toggleSwitch:(id)sender{
    if( self.onSwitch.on )
    {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:_uuid identifier:@"com.lokaloapp.LokaloApp"];
        
        if(region)
        {
            region.notifyOnEntry = true;
            region.notifyOnExit = true;
            region.notifyEntryStateOnDisplay = _notifyOnDisplay;
            
            [_locationManager startMonitoringForRegion:region];
        }
    }
    else
    {
        CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] identifier:@"com.lokaloapp.LokaloApp"];
        [_locationManager stopMonitoringForRegion:region];
    }
}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
