//
//  BSDetailViewController.m
//  BLELister
//
//  Created by Steve Baker on 9/26/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import "BSDetailViewController.h"

@interface BSDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation BSDetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.title = [self.detailItem name];
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController
     willHideViewController:(UIViewController *)viewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController
     willShowViewController:(UIViewController *)viewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];

    switch (indexPath.row) {
        case 0:
            // TODO: need to connect to device to get RSSI?
            cell.textLabel.text = @"RSSI";
            cell.detailTextLabel.text = [self.detailItem.RSSI description];
            break;
        case 1:
            cell.textLabel.text = @"State";
            cell.detailTextLabel.text = [self peripheralStateStringForValue:self.detailItem.state];
            break;
        case 2:
            cell.textLabel.text = @"UUID";
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            cell.detailTextLabel.text = [self.detailItem.identifier UUIDString];
            break;
        case 3:
            NSLog(@"description %@", [self.detailItem description]);
            cell.textLabel.text = @"Desc";
            // Use custom cell and autolayout instead?
            cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
            cell.detailTextLabel.text = [self.detailItem description];
            break;
        default:
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            break;
    }
    
    return cell;
}

- (NSString *)peripheralStateStringForValue:(CBPeripheralState)state
{
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
            break;
    }
    return stateString;
}

#pragma mark - UITableViewDelegate

@end