//
//  BSMasterViewController.m
//  BLELister
//
//  Created by Steve Baker on 9/26/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import "BSMasterViewController_Private.h"
#import "BSDetailViewController.h"
#import "BSBleConstants.h"
#import "BSBlePeripheral.h"

@implementation BSMasterViewController

- (void)awakeFromNib {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *scanButton = [[UIBarButtonItem alloc]
                                   initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                   target:self
                                   action:@selector(scanForPeripherals)];
    self.navigationItem.rightBarButtonItem = scanButton;

    self.detailViewController = (BSDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];

    self.leDiscovery = [BSLeDiscovery sharedInstance];

    self.notificationCenter = [NSNotificationCenter defaultCenter];
    [self registerForBleDiscoveryDidRefreshNotification];
    [self registerFoBleDiscoveryStatePoweredOffNotification];
    [self registerForBleDiscoveryDidReadRSSINotification];

    [self scanForPeripherals];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Memory management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [self.notificationCenter removeObserver:self
                                       name:kBleDiscoveryDidRefreshNotification
                                     object:nil];
    [self.notificationCenter removeObserver:self
                                       name:kBleDiscoveryStatePoweredOffNotification
                                     object:nil];
    [self.notificationCenter removeObserver:self
                                       name:kBleDiscoveryDidReadRSSINotification
                                     object:nil];
}

#pragma mark -
/*
- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}
 */

- (void)scanForPeripherals {
    [self.leDiscovery scanForPeripheralsWithServices:nil options:nil];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.leDiscovery.foundPeripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    
    BSBlePeripheral *bsBlePeripheral = self.leDiscovery.foundPeripherals[indexPath.row];
    cell.textLabel.text = [bsBlePeripheral.peripheral name];
    
    if (!bsBlePeripheral.RSSI) {
        cell.detailTextLabel.text = @"unknown";
    } else {
        cell.detailTextLabel.text = [bsBlePeripheral.RSSI description];
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView
canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *mutableFoundPeripherals = [NSMutableArray arrayWithArray:self.leDiscovery.foundPeripherals];
        [mutableFoundPeripherals removeObjectAtIndex:indexPath.row];
        self.leDiscovery.foundPeripherals = [NSArray arrayWithArray:mutableFoundPeripherals];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        BSBlePeripheral *bsBlePeripheral = self.leDiscovery.foundPeripherals[indexPath.row];
        self.detailViewController.detailItem = bsBlePeripheral;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BSBlePeripheral *bsBlePeripheral = self.leDiscovery.foundPeripherals[indexPath.row];
        [[segue destinationViewController] setDetailItem:bsBlePeripheral];
    }
}

#pragma mark - Register for notifications
- (void)registerForBleDiscoveryDidRefreshNotification {
    [self.notificationCenter addObserver:self
                                selector:@selector(discoveryDidRefreshWithNotification:)
                                    name:kBleDiscoveryDidRefreshNotification
                                  object:nil];
}

- (void)registerFoBleDiscoveryStatePoweredOffNotification {
    [self.notificationCenter addObserver:self
                                selector:@selector(discoveryStatePoweredOff)
                                    name:kBleDiscoveryStatePoweredOffNotification
                                  object:nil];
}

- (void)registerForBleDiscoveryDidReadRSSINotification {
    [self.notificationCenter addObserver:self
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

- (void)discoveryDidRefreshWithNotification:(NSNotification *)notification {
    NSLog(@"in BSMasterViewController discoveryDidRefreshWithNotification:");
    NSLog(@"notification.object: %@", notification.object);

    if (notification.userInfo) {
        NSLog(@"notification.userInfo %@", notification.userInfo);
    }
    // Notification may be from a background queue.
    [self updateUIOnMainQueue];
}

- (void)discoveryStatePoweredOff {
    NSLog(@"discoveryStatePoweredOff");
}

- (void)discoveryDidReadRSSINotification:(NSNotification *)notification {
    [self updateUIOnMainQueue];
}

@end
