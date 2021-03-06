//
//  SettingsViewController.h
//  PointiOSReferenceFileBrowser
//
//  Created by jb on 6/22/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorThemePickerViewController.h"

@interface SettingsViewController : UITableViewController

<
    ColorThemePickerViewControllerDelegate
>

@property (nonatomic, strong) IBOutlet UILabel *currentColorThemeLabel;
@property (nonatomic, strong) IBOutlet UIButton *jiraButton;
@property (nonatomic, strong) IBOutlet UISwitch *timeStampSwitch;

-(IBAction)showFeedback;
-(IBAction)timeStampSwitchValueChanged;

@end
