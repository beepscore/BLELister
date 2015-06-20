//
//  BSDetailViewController.m
//  BLELister
//
//  Created by Steve Baker on 9/26/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import "BSDetailViewController.h"
#import "BSDetailViewController_Private.h"
#import "BSBleConstants.h"

@interface BSDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (weak, nonatomic) IBOutlet UITableViewCell *connectCell;

- (void)configureView;
@end

@implementation BSDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView {
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.title = [self.detailItem name];
        [self.detailItem readRSSI];
        [self.tableView reloadData];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
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

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController {
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0: {
            cell.textLabel.text = @"RSSI";
            if (self.RSSI) {
                cell.detailTextLabel.text = [self.RSSI description];
            }
            break;
        }
        case 1: {
            cell.textLabel.text = @"State";
            cell.detailTextLabel.text = [self peripheralStateStringForValue:self.detailItem.state];
            break;
        }
        case 2: {
            cell.textLabel.text = @"UUID";
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            cell.detailTextLabel.text = [self.detailItem.identifier UUIDString];
            break;
        }
        case 3: {
            NSLog(@"description %@", [self.detailItem description]);
            cell.textLabel.text = @"Desc";
            // Use custom cell and autolayout instead?
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            cell.detailTextLabel.text = [self.detailItem description];
            break;
        }
        case 4: {
            self.connectCell = cell;
            cell.textLabel.text = [self connectLabelTextForState:self.detailItem.state];
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.detailTextLabel.text = @"";
            break;
        }
        default: {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            break;
        }
    }
    return cell;
}

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

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.tableView cellForRowAtIndexPath:indexPath] == self.connectCell) {

        if (CBPeripheralStateDisconnected == self.detailItem.state) {
            [self connect:self.leDiscovery peripheral:self.detailItem];
        } else if (CBPeripheralStateConnected == self.detailItem.state) {
            [self disconnect:self.leDiscovery peripheral:self.detailItem];
        }
        // reloadData will get the current detailItem.state and update UI
        [self.tableView reloadData];
    }
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
        [self.tableView reloadData];
    });
}

- (void)discoveryDidConnectPeripheralWithNotification:(NSNotification *)notification {
    NSLog(@"discoveryDidConnectPeripheralWithNotification");
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo[@"peripheral"] == self.detailItem) {
        // Notification is about self's peripheral, not some other peripheral
        // Notification may be from a background queue.
        [self updateUIOnMainQueue];
    }
}

- (void)discoveryDidDisconnectPeripheralWithNotification:(NSNotification *)notification {
    NSLog(@"discoveryDidDisconnectPeripheralWithNotification");
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo[@"peripheral"] == self.detailItem) {
        // Notification is about self's peripheral, not some other peripheral
        // Notification may be from a background queue.
        [self updateUIOnMainQueue];
    }
}

- (void)discoveryDidReadRSSINotification:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    if (userInfo[@"peripheral"] == self.detailItem) {
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
