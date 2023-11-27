//
//  PhotoView.m
//  viewTiff
//
//  Created by Ben Larrison on 11/3/22.
//

#import "PhotoView.h"

@implementation PhotoView

-   (instancetype)init
{
    self                        =               [super                          init];
    
    _tapRecognizer              =               [[UITapGestureRecognizer        alloc]initWithTarget:self action:@selector(tapAction)];
    [self           setUserInteractionEnabled:YES];
    [self           addGestureRecognizer:self.tapRecognizer];
    
    return          self;
}

-   (void)  tapAction
{
    [self.delegate  didTapPhoto:[NSNumber   numberWithInt:self.photoID]];
}

@end
