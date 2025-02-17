//
//  SPClubMembersDeleteAdminViewController.m
//  SportsPage
//
//  Created by Qin on 2017/3/9.
//  Copyright © 2017年 Absolute. All rights reserved.
//

#import "SPClubMembersDeleteAdminViewController.h"

#import "SPContactTableViewCell.h"

#import "SPSportBusinessUnit.h"

#import "MBProgressHUD.h"

@interface SPClubMembersDeleteAdminViewController () <UITableViewDelegate,UITableViewDataSource> {
    NSMutableArray *_adminArray;
    NSString *_clubId;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *deleteAdminButton;

@end

@implementation SPClubMembersDeleteAdminViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - SetUp
- (void)setUp {
    [self setUpUI];
    [self setUpTableView];
}

- (void)setUpUI {
    [_deleteAdminButton setBackgroundColor:[SPGlobalConfig themeColor]];
    [_deleteAdminButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    _deleteAdminButton.layer.cornerRadius = 5;
    _deleteAdminButton.layer.masksToBounds = true;
}

- (void)setUpTableView {
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.tableFooterView = [UIView new];
    _tableView.allowsMultipleSelectionDuringEditing = true;
    _tableView.editing = true;
}

- (void)setUpAdminArray:(NSMutableArray *)adminArray
                 clubId:(NSString *)clubId {
    _adminArray = adminArray;
    [_adminArray removeObjectAtIndex:0];
    _clubId = clubId;
}

#pragma mark - Action
- (IBAction)dismissAction:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)deleteAdminAction:(UIButton *)sender {
    sender.userInteractionEnabled = false;
    NSArray <NSIndexPath *> *indexPathArray = [_tableView indexPathsForSelectedRows];
    if (!indexPathArray) {
        [SPGlobalConfig showTextOfHUD:@"请选择成员" ToView:self.view];
        sender.userInteractionEnabled = true;
        return;
    }
    
    NSMutableArray *strArray = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexPath in indexPathArray) {
        SPUserInfoModel *model = (SPUserInfoModel *)_adminArray[indexPath.row];
        [strArray addObject:[model userId]];
    }
    NSString *targetIdStr = [strArray componentsJoinedByString:@","];
    NSLog(@"targetIdStr:%@",targetIdStr);
    
    [MBProgressHUD showHUDAddedTo:self.view animated:true];
    NSString *userId = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
    [[SPSportBusinessUnit shareInstance] deleteClubAdminBatchWithClubId:_clubId userId:userId adminIds:targetIdStr successful:^(NSString *successsfulString) {
        
        if ([successsfulString isEqualToString:@"successful"]) {
            sender.userInteractionEnabled = true;
            [MBProgressHUD hideHUDForView:self.view animated:true];
            [SPGlobalConfig showTextOfHUD:@"删除成功" ToView:self.view];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                if ([_delegate respondsToSelector:@selector(finishedDeleteAdminAction)]) {
                    [_delegate finishedDeleteAdminAction];
                }
                
                [self dismissViewControllerAnimated:true completion:nil];
            });
        } else {
            [MBProgressHUD hideHUDForView:self.view animated:true];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [SPGlobalConfig showTextOfHUD:successsfulString ToView:self.view];
                sender.userInteractionEnabled = true;
            });
        }
        
    } failure:^(NSString *errorString) {
        [MBProgressHUD hideHUDForView:self.view animated:true];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SPGlobalConfig showTextOfHUD:@"网络请求失败" ToView:self.view];
            sender.userInteractionEnabled = true;
        });
    }];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _adminArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 30, 120)];
    label.text = @"      管理员";
    label.font = [UIFont boldSystemFontOfSize:12];
    label.textColor = [SPGlobalConfig anyColorWithRed:142 green:142 blue:146 alpha:1];
    label.backgroundColor = [SPGlobalConfig anyColorWithRed:240 green:240 blue:246 alpha:1];
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    if (!cell) {
        [tableView registerNib:[UINib nibWithNibName:@"SPContactTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ContactCell"];
        cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(SPContactTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setupWithModel:_adminArray[indexPath.row]];
}


@end
