//
//  BSDetailViewController.h
//  BLELister
//
//  Created by Steve Baker on 9/26/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSLeDiscovery.h"
#import "BSBlePeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface BSDetailViewController : UITableViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) BSLeDiscovery *leDiscovery;
@property (strong, nonatomic) BSBlePeripheral *detailItem;

@end
