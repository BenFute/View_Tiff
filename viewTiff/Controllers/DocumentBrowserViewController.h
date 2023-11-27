//
//  DocumentBrowserViewController.h
//  viewTiff
//
//  Created by Ben Larrison on 11/1/22.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface DocumentBrowserViewController : UIDocumentBrowserViewController

-   (instancetype)initWithCoder:(NSCoder *)coder;

-   (void)presentDocumentAtURL:(NSURL *)documentURL;

@end
