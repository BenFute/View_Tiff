//
//  SettingsViewController.h
//  viewTiff
//
//  Created by Ben Larrison on 11/21/22.
//


#import     <Foundation/Foundation.h>
#import     "../Models/SettingsModel.h"
#import     "SettingsViewController.h"
#import     <UIKit/UIKit.h>



@protocol ConfigurationDelegate

-   (void)didUpdateLongVideoEnabled:(SettingsModel*)settings;
-   (void)didUpdateAudioEnabled:(SettingsModel*)settings;
-   (void)didUpdateWhiteOutSaveEnabled:(SettingsModel*)settings;

@end

@interface SettingsViewController : UIViewController


@property   SettingsModel       *settings;

//Buttons

- (IBAction)longVideoEnableButton;
@property               int         longVideoEnableButtonSelected;
@property (strong, nonatomic) IBOutlet UIButton *longVideoEnableButtonProperty;


- (IBAction)audioEnableButton;
@property               int         audioEnableButtonSelected;
@property (strong, nonatomic) IBOutlet UIButton *audioEnableButtonProperty;


- (IBAction)whiteOutSaveEnabledButton;
@property               int         whiteOutSaveEnabledButtonSelected;
@property (strong, nonatomic) IBOutlet UIButton *whiteOutSaveEnabledButtonProperty;

- (IBAction)close:(id)sender;

@property   IBOutlet    id  <ConfigurationDelegate> configurationDelegate;


-   (void)                          viewDidLoad;

@end
