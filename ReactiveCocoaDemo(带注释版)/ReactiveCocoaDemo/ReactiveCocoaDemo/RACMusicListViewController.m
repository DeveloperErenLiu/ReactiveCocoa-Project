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
@property (nonatomic, strong) UITableView *tableView;
// viewModel应该由控制器所拥有
@property (nonatomic, strong) RACMusicListViewModel *viewModel;
@end

@implementation RACMusicListViewController

#pragma mark - ----- Life Cycle ------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
    // 统一订阅信号和初始化Command
    [self setupSubscriber];
}

#pragma mark - ----- Private Method ------

- (void)setupViews {
    [self.tableView registerClass:[RACMusicListTableViewCell class]
           forCellReuseIdentifier:cellIdentifier];
    // 这里需要注意，使用MJRefresh的时候，不要直接用MJRefreshHeader、Footer这两个类，会导致一些其他问题。
    // 应该用这两个类的子类，子类直接就可以拿来使用，并且带文字和图片等功能。
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self
                                                                refreshingAction:@selector(reloadData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self
                                                                    refreshingAction:@selector(loadMoreData)];
    // 这里无需指定Target、Action，在后面会通过创建item的Command的方式，来获取其点击事件。
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:nil action:nil];
}

- (void)setupSubscriber {
    
    // 从这个Demo可以看出，RAC的信号是专注做一类事的，不能让这个信号同时做两类事情，这样很难将信号区分开。
    // 假设将reload和more信号放在一起，只创建一个信号。这样虽然在执行时可以通过调用execute:方法传入参数来区别不同的信号，但是在信号回来之后的回调中，是无法做区分的。
    // 所以一个信号应该专注做一件事，这样代码和执行逻辑也比较清晰，否则很容易出现比较难排查的bug。
    @weakify(self);
    // 监听RACCommand的executing是否执行的信号，block中返回的是一个布尔值，标明当前是否执行中。
    [self.viewModel.fetchMoreDataCommand.executing subscribeNext:^(NSNumber *executing) {
        @strongify(self);
        if (!executing.boolValue) {
            [self.tableView.mj_footer endRefreshing];
        }
    }];
    
    // 上面是获取更多的Command，下面是刷新页面的Command。
    [self.viewModel.reloadDataCommand.executing subscribeNext:^(NSNumber *executing) {
        @strongify(self);
        if (!executing.boolValue) {
            [self.tableView.mj_header endRefreshing];
        }
    }];
    
    // 当fetch和reload两个command出现错误时，也就是调用这两个command的error信号时，也会调用这里的block。
    // 因为errorSubject同时订阅了这两个command的error信号，在传递过程中可以打印参数，这个参数就是fetch和reload传递过来的。
    [self.viewModel.errorSubject subscribeNext:^(NSError *error) {
        NSLog(@"music list error : %@", error.description);
    }];
    
    // 根据指定的条件，由RAC来判断item是否可用。这里的条件就是fetch和reload的信号是否在执行，如果这两个信号中的任意一个信号在执行，则当前item可用。
    // 点击item之后，就会执行信号里面的block代码。block内的代码会执行cancel的代码，也就是触发cancel的信号block。
    // 注意下面通过调用RACSignal的combineLatest:方法，将fetch和reload两个信号的executing信号合并，这样两个信号的任意一个在执行过程中，就会调用这个block的回调。需要注意的是，在这后面还加了or方法的调用。
    self.navigationItem.rightBarButtonItem.rac_command = [[RACCommand alloc] initWithEnabled:[[RACSignal combineLatest:@[self.viewModel.fetchMoreDataCommand.executing, self.viewModel.reloadDataCommand.executing]] or] signalBlock:^RACSignal *(id input) {
        
        @strongify(self);
        // 执行cancel命令，可以在执行command的时候传递一个参数过去，命令的实现在viewModel中。
        [self.viewModel.cancelCommand execute:@"网络请求被取消"];
        return [RACSignal empty];
    }];
    
    // 需要注意的是，不要监听数组的count变量，count的内部实现可能是直接加减的，而不是重新赋值，所以不能通过KVO监听。
    [RACObserve(self.viewModel, dataList) subscribeNext:^(NSArray *array) {
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    // 通过RAC()宏定义，可以将hasMoreSignal信号的返回值，与tableView的mj_footer是否隐藏绑定，并且不需要我们写处理逻辑代码。需要注意的是，hasMoreSignal信号后面，调用了not方法进行了取反操作。
    RAC(self.tableView.mj_footer, hidden) = [self.viewModel.hasMoreSignal not];
}

// 执行加载更多的command和刷新页面的command，实现代码均在viewModel中。
- (void)loadMoreData {
    [self.viewModel.fetchMoreDataCommand execute:nil];
}

- (void)reloadData {
    [self.viewModel.reloadDataCommand execute:nil];
}

#pragma mark - ----- Setter && Getter ------

// 懒加载viewModel对象
- (RACMusicListViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[RACMusicListViewModel alloc] init];
    }
    return _viewModel;
}

// 懒加载tableView对象
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
    // 在自定义的cell中也是用了signal，cell中定义了cellModel属性，并监听这个属性的改变，如果改变则对cell内部的变量进行重新赋值。(根据业务逻辑实现)
    cell.cellModel = [self.viewModel itemModelOfIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end


















