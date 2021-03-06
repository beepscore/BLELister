//
//  MasterViewController.h
//  BLELister
//
//  Created by Steve Baker on 5/10/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSLeDiscovery.h"

@class DetailViewController;

@interface MasterViewController : UITableViewController

@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) BSLeDiscovery *leDiscovery;

@end

