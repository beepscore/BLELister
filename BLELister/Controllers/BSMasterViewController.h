//
//  BSMasterViewController.h
//  BLELister
//
//  Created by Steve Baker on 9/26/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSLeDiscovery.h"

@class BSDetailViewController;

@interface BSMasterViewController : UITableViewController <BSLeDiscoveryDelegate>

@property (strong, nonatomic) BSDetailViewController *detailViewController;
@property (strong, nonatomic) BSLeDiscovery *leDiscovery;

@end
