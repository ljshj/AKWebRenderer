//
//  PictureDetailViewController.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/03.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "PictureDetailViewController.h"

@interface PictureDetailViewController ()

@end

@implementation PictureDetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.pictureImageView.image = self.picture;
}

@end
