//
//  SettingsViewController.m
//  viewTiff
//
//  Created by Ben Larrison on 11/21/22.
//

#import <Foundation/Foundation.h>
#import "SettingsViewController.h"


@implementation SettingsViewController

-   (void)viewDidLoad{
    
    //NSLog(@"View did load");
    
    NSURL       *settingsURL=       [[DirectoryController        localDocumentsDirectoryURL]URLByAppendingPathComponent:@"Settings"];
    self.settings           =       [[SettingsModel      alloc]initWithFileURL:settingsURL];
    
    [self.settings      openWithCompletionHandler:^(BOOL success) {
        
        if(self.settings.longVideoEnabled                   == NO)
        {
            self.longVideoEnableButtonProperty.tintColor    =   [UIColor    systemGrayColor];
        }
        else
        {
            self.longVideoEnableButtonProperty.tintColor    =   [UIColor    colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
        }
        [self.longVideoEnableButtonProperty     setHidden:NO];
        
        if(self.settings.audioEnabled                       ==  NO)
        {
            self.audioEnableButtonProperty.tintColor        =   [UIColor    systemGrayColor];
        }
        else
        {
            self.audioEnableButtonProperty.tintColor        =   [UIColor    colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
        }
        [self.audioEnableButtonProperty                     setHidden:NO];
        
        if(self.settings.whiteOutPhotoSaveEnabled           ==  NO)
        {
            self.whiteOutSaveEnabledButtonProperty.tintColor=   [UIColor    systemGrayColor];
        }
        else
        {
            self.whiteOutSaveEnabledButtonProperty.tintColor=   [UIColor    colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
        }
        [self.whiteOutSaveEnabledButtonProperty         setHidden:NO];
        
        

        
    }];
    
}

- (IBAction)longVideoEnableButton {
    NSLog(@"Long video enable button");
    
    
    if(self.settings.longVideoEnabled == NO)
    {
        self.settings.longVideoEnabled = YES;
        self.longVideoEnableButtonProperty.tintColor    =   [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    }
    else
    {
        self.settings.longVideoEnabled = NO;
        self.longVideoEnableButtonProperty.tintColor    =   [UIColor systemGrayColor];
    }
    


    
    [self.settings      prepareSettings];
    
    [self.settings      saveToURL:self.settings.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
        [self.configurationDelegate     didUpdateLongVideoEnabled:self.settings];
    }];
    
}

- (IBAction)audioEnableButton {
    NSLog(@"Audio Enabled button");
    
    if(self.settings.audioEnabled == NO)
    {
        self.settings.audioEnabled = YES;
        self.audioEnableButtonProperty.tintColor        =   [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    }
    else
    {
        self.settings.audioEnabled = NO;
        self.audioEnableButtonProperty.tintColor        =   [UIColor systemGrayColor];
    }
    
    [self.settings      prepareSettings];
    [self.settings      saveToURL:self.settings.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        [self.configurationDelegate didUpdateAudioEnabled:self.settings];
    }];
    
}
- (IBAction)whiteOutSaveEnabledButton {
    NSLog(@"White out save enabled");
    if(self.settings.whiteOutPhotoSaveEnabled == NO)
    {
        self.settings.whiteOutPhotoSaveEnabled = YES;
        self.whiteOutSaveEnabledButtonProperty.tintColor=   [UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:1.0];
    }
    else
    {
        self.settings.whiteOutPhotoSaveEnabled = NO;
        self.whiteOutSaveEnabledButtonProperty.tintColor=   [UIColor systemGrayColor];
    }
    
    [self.settings      prepareSettings];
    [self.settings      saveToURL:self.settings.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success){
        [self.configurationDelegate didUpdateWhiteOutSaveEnabled:self.settings];
    }];
    
    
}

- (IBAction)close:(id)sender {
    
    [self           dismissViewControllerAnimated:YES completion:^{
        //
    }];
}
@end
