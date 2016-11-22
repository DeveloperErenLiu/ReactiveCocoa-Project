//
//  RACMusicListViewController.m
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import "RACMusicListViewController.h"
#import <MJRefresh/MJRefresh.h>
#import <ReactiveCocoa/RACEXTScope.h>
#import "RACMusicListViewModel.h"
#import "RACMusicListTableViewCell.h"

static NSString *const cellIdentifier = @"musicListCell";

@interface RACMusicListViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, strong) RACMusicListViewModel *viewModel;
@end

@implementation RACMusicListViewController

#pragma mark - ----- Life Cycle ------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    [self setupSubscriber];
}

#pragma mark - ----- Private Method ------

- (void)setupViews {
    [self.tableView registerClass:[RACMusicListTableViewCell class]
           forCellReuseIdentifier:cellIdentifier];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                refreshingAction:@selector(reloadData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self
                                                                    refreshingAction:@selector(loadMoreData)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:nil];
}

- (void)setupSubscriber {
    
    @weakify(self);
    [self.viewModel.fetchMoreDataCommand.executing subscribeNext:^(NSNumber *executing) {
        @strongify(self);
        if (!executing.boolValue) {
            [self.tableView.mj_footer endRefreshing];
        }
    }];
    
    [self.viewModel.reloadDataCommand.executing subscribeNext:^(NSNumber *executing) {
        @strongify(self);
        if (!executing.boolValue) {
            [self.tableView.mj_header endRefreshing];
        }
    }];
    
    [self.viewModel.errorSubject subscribeNext:^(NSError *error) {
        NSLog(@"music list error : %@", error.description);
    }];
    
    self.navigationItem.rightBarButtonItem.rac_command = [[RACCommand alloc] initWithEnabled:self.itemCombineSignal signalBlock:^RACSignal *(id input) {
        
        @strongify(self);
        [self.viewModel.cancelCommand execute:@"网络请求被取消"];
        return [RACSignal empty];
    }];
    
    [RACObserve(self.viewModel, dataList) subscribeNext:^(NSArray *array) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    RAC(self.tableView.mj_footer, hidden) = [self.viewModel.hasMoreSignal not];
}

- (RACSignal *)itemCombineSignal {
    NSArray *executes = @[self.viewModel.fetchMoreDataCommand.executing,
                          self.viewModel.reloadDataCommand.executing];
    return [[RACSignal combineLatest:executes] or];
}

- (void)loadMoreData {
    [self.viewModel.fetchMoreDataCommand execute:nil];
}

- (void)reloadData {
    [self.viewModel.reloadDataCommand execute:nil];
}

#pragma mark - ----- Setter && Getter ------

- (RACMusicListViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[RACMusicListViewModel alloc] init];
    }
    return _viewModel;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds
                                                  style:UITableViewStylePlain];
        _tableView.delegate   = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - ----- UITableView Delegate ------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.dataList.count;
}

- (RACMusicListTableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    RACMusicListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier
                                                                      forIndexPath:indexPath];
    cell.cellModel = [self.viewModel itemModelOfIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end


















