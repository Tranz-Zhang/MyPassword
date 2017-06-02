//
//  OpenSourceDeclarationViewController.m
//  MyPassword
//
//  Created by chance on 27/5/2017.
//  Copyright © 2017 bychance. All rights reserved.
//

#import "OpenSourceDeclarationViewController.h"

#define kLocalWidth self.view.bounds.size.width
#define kLocalHeight self.view.bounds.size.height

#define kCellIdentifier_Header @"HeaderCell"
#define kCellIdentifier_LibraryInfo @"LibraryInfoCell"


@interface LibraryInfo : NSObject

@property (nonatomic, strong) NSString *libraryName;
@property (nonatomic, strong) NSString *licenceDeclaration;
@property (nonatomic, assign) GLfloat contentHeight;

@end

@implementation LibraryInfo
@end


@interface OpenSourceDeclarationViewController () <UITableViewDelegate, UITableViewDataSource> {
    __weak UIActivityIndicatorView *_loadingView;
    NSArray *_libraryInfoList;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation OpenSourceDeclarationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = [NSString stringWithFormat:@"MiKeys %@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
    
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    loadingView.center = CGPointMake(kLocalWidth / 2, kLocalHeight / 2);
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
    [self.view addSubview:loadingView];
    
    _loadingView = loadingView;
    [_loadingView startAnimating];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Do any additional setup after loading the view.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self loadLibrayInfos];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_loadingView removeFromSuperview];
            _loadingView = nil;
            [self.tableView reloadData];
        });
    });
}


- (void)loadLibrayInfos {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"OpenSourceInfo" ofType:@"plist"];
    NSDictionary *declarationDict = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *dictList = declarationDict[@"OpenSourceLibraries"];
    NSMutableArray *infoList = [NSMutableArray arrayWithCapacity:dictList.count];
    
    UIFont *defaultFont = [UIFont systemFontOfSize:11];
    CGSize defaultSize = CGSizeMake(kLocalWidth - 80, CGFLOAT_MAX);
    for (NSDictionary *infoDict in dictList) {
        LibraryInfo *info = [LibraryInfo new];
        info.libraryName = infoDict[@"LibraryName"];
        NSString *declaration = infoDict[@"LicenceDeclaration"];
        info.licenceDeclaration = declaration;
        // calculate cell height
        CGRect textRect = [declaration boundingRectWithSize:defaultSize
                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:@{NSFontAttributeName : defaultFont}
                                                    context:nil];
        info.contentHeight = textRect.size.height + 100;
        [infoList addObject:info];
    }
    _libraryInfoList = [infoList copy];
}


#pragma mark - Table View
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _libraryInfoList.count ? _libraryInfoList.count + 1 : 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 130;
        
    } else {
        LibraryInfo *info = _libraryInfoList[indexPath.row - 1];
        return info.contentHeight;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_Header];
        
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_LibraryInfo];
        LibraryInfo *info = _libraryInfoList[indexPath.row - 1];
        UILabel *titleLabel = [cell.contentView viewWithTag:111];
        titleLabel.text = info.libraryName;
        UILabel *contentLabel = [cell.contentView viewWithTag:222];
        contentLabel.text = info.licenceDeclaration;
    }
    return cell;
}


@end




