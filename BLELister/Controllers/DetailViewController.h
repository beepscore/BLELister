//
//  DetailViewController.h
//  BLELister
//
//  Created by Steve Baker on 5/10/17.
//  Copyright © 2017 Beepscore LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSLeDiscovery.h"
#import "BSBlePeripheral.h"
#import <CoreBluetooth/CoreBluetooth.h>


@interface DetailViewController : UIViewController

@property (strong, nonatomic) BSLeDiscovery *leDiscovery;
@property (strong, nonatomic) BSBlePeripheral *detailItem;

@property (weak, nonatomic) IBOutlet UIButton *connectButton;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *peripheralStateLabel;
@property (weak, nonatomic) IBOutlet UILabel *rssiLabel;
@property (weak, nonatomic) IBOutlet UILabel *uuidLabel;

@end
