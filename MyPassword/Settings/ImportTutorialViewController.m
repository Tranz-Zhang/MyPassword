//
//  ImportTutorialViewController.m
//  MyPassword
//
//  Created by chance on 1/6/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "ImportTutorialViewController.h"

@interface ImportTutorialViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *tutorialView;

@end

@implementation ImportTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tutorialView.image = [UIImage imageNamed:NSLocalizedString(@"ImportTutorial.Image", nil)];
}

@end
