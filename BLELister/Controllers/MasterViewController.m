//
//  MasterViewController.m
//  BLELister
//
//  Created by Steve Baker on 5/10/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

#import "MasterViewController.h"
#import "MasterViewController_Private.h"
#import "DetailViewController.h"
#import "BSBleConstants.h"
#import "BSBlePeripheral.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    // TODO: copy code from BSMasterViewController into MasterViewController

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
}


- (void)viewWillAppear:(BOOL)animated {
    self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
    [super viewWillAppear:animated];
}


#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    // TODO: explicit removeObserver may not be necessary in iOS >= 9

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

- (void)scanForPeripherals {
    [self.leDiscovery scanForPeripheralsWithServices:nil options:nil];
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = self.objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
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
