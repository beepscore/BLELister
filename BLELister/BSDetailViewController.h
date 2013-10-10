//
//  BSDetailViewController.h
//  BLELister
//
//  Created by Steve Baker on 9/26/13.
//  Copyright (c) 2013 Beepscore LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BSDetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) CBPeripheral *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *uuidText;
@end
