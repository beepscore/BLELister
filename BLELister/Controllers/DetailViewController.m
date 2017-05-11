//
//  DetailViewController.m
//  BLELister
//
//  Created by Steve Baker on 5/10/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

#import "DetailViewController.h"
#import "DetailViewController_Private.h"
#import "BSBleConstants.h"

@implementation DetailViewController

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
        
        self.title = [self.detailItem.peripheral name];
        self.RSSI = self.detailItem.RSSI;
        //[self.tableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.RSSI = nil;
    // Do any additional setup after loading the view, typically from a nib.
    self.leDiscovery = [BSLeDiscovery sharedInstance];

    self.notificationCenter = [NSNotificationCenter defaultCenter];
    [self registerForBleDiscoveryDidConnectPeripheralNotification];
    [self registerForBleDiscoveryDidDisconnectPeripheralNotification];
    [self registerForBleDiscoveryDidReadRSSINotification];

    [self configureView];
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    // TODO: explicit removeObserver may not be necessary in iOS >= 9

    [self.notificationCenter removeObserver:self
                                       name:kBleDiscoveryDidConnectPeripheralNotification
                                     object:nil];
    [self.notificationCenter removeObserver:self
                                       name:kBleDiscoveryDidDisconnectPeripheralNotification
                                     object:nil];
    [self.notificationCenter removeObserver:self
                                       name:kBleDiscoveryDidReadRSSINotification
                                     object:nil];
}


#pragma mark - Managing the detail item

- (void)setDetailItem:(BSBlePeripheral *)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

#pragma mark -

- (NSString *)peripheralStateStringForValue:(CBPeripheralState)state {
    NSString *stateString = @"";
    switch (state) {

        case CBPeripheralStateDisconnected:
            stateString = @"disconnected";
            break;
        case CBPeripheralStateConnecting:
            stateString = @"connecting";
            break;
        case CBPeripheralStateConnected:
            stateString = @"connected";
            break;
        default:
            stateString = @"";
            break;
    }
    return stateString;
}

- (NSString *)connectLabelTextForState:(CBPeripheralState)state {
    NSString *connectLabelText = @"";
    switch (state) {

        case CBPeripheralStateDisconnected:
            connectLabelText = @"Connect";
            break;
        case CBPeripheralStateConnecting:
            connectLabelText = @"";
            break;
        case CBPeripheralStateConnected:
            connectLabelText = @"Disconnect";
            break;
        default:
            connectLabelText = @"";
            break;
    }
    return connectLabelText;
}

#pragma mark -
- (void)connect:(BSLeDiscovery *)aLeDiscovery
     peripheral:(CBPeripheral *)aPeripheral {
    [aLeDiscovery connectPeripheral:aPeripheral];
}

- (void)disconnect:(BSLeDiscovery *)aLeDiscovery
        peripheral:(CBPeripheral *)aPeripheral {
    [aLeDiscovery disconnectPeripheral:aPeripheral];
}

#pragma mark - Register for notifications
- (void)registerForBleDiscoveryDidConnectPeripheralNotification {
    [self.notificationCenter
     addObserver:self
     selector:@selector(discoveryDidConnectPeripheralWithNotification:)
     name:kBleDiscoveryDidConnectPeripheralNotification
     object:nil];
}

- (void)registerForBleDiscoveryDidDisconnectPeripheralNotification {
    [self.notificationCenter
     addObserver:self
     selector:@selector(discoveryDidDisconnectPeripheralWithNotification:)
     name:kBleDiscoveryDidDisconnectPeripheralNotification
     object:nil];
}

- (void)registerForBleDiscoveryDidReadRSSINotification {
    [self.notificationCenter
     addObserver:self
     selector:@selector(discoveryDidReadRSSINotification:)
     name:kBleDiscoveryDidReadRSSINotification
     object:nil];
}

#pragma mark - Notification response methods
- (void)updateUIOnMainQueue {
    // Get main queue before updating UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        // reloadData will get the current detailItem.state
//FIXME: need to reload?
        // TODO: need to reload?
        //[self.tableView reloadData];
    });
}

- (void)discoveryDidConnectPeripheralWithNotification:(NSNotification *)notification {
    NSLog(@"discoveryDidConnectPeripheralWithNotification");
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo[@"peripheral"] == self.detailItem.peripheral) {
        // Notification is about self's peripheral, not some other peripheral
        // Notification may be from a background queue.
        [self updateUIOnMainQueue];
    }
}

- (void)discoveryDidDisconnectPeripheralWithNotification:(NSNotification *)notification {
    NSLog(@"discoveryDidDisconnectPeripheralWithNotification");
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo[@"peripheral"] == self.detailItem.peripheral) {
        // Notification is about self's peripheral, not some other peripheral
        // Notification may be from a background queue.
        [self updateUIOnMainQueue];
    }
}

- (void)discoveryDidReadRSSINotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo[@"peripheral"] == self.detailItem.peripheral) {
        // Notification is about self's peripheral, not some other peripheral
        if (userInfo[@"RSSI"]) {
            self.RSSI = userInfo[@"RSSI"];
        }
        if (userInfo[@"error"]) {
            NSLog(@"error %@", userInfo[@"error"]);
        }
        // Notification may be from a background queue.
        [self updateUIOnMainQueue];
    }
}

@end
