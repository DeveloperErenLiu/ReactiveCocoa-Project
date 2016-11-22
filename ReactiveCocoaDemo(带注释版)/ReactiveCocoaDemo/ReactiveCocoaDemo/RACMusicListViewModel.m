//
//  RACMusicListViewModel.m
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import "RACMusicListViewModel.h"
#import "RACMusicListNetwork.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import <MJExtension/MJExtension.h>

@interface RACMusicListViewModel ()
// 当前获取的数据下标，由服务器字段决定。
@property (nonatomic, strong) NSNumber *currentIndex;
// 简单定义的网络请求类
@property (nonatomic, strong) RACMusicListNetwork *network;
@end

@implementation RACMusicListViewModel

#pragma mark - ----- Life Cycle ------

- (instancetype)init {
    self = [super init];
    if (self) {
        // 初始化时将创建信号和订阅信号一起完成
        [self setupSignal];
        [self setupSubscriber];
    }
    return self;
}

#pragma mark - ----- Private Method ------

// 需要注意的是，RAC中是不会手动帮我们自动管理retain cycle的，因为RAC并不知道你多会释放，这是由业务逻辑和代码逻辑决定的。
// 所以在RAC中通过@weakify()和@strongify()两个宏定义，来实现平时常用的__weak、__strong避免宏定义的方式。在block中还是看到了红色的self，但不要担心，这并不会导致循环引用。
// 如果你把block中使用self的地方都注释，你会发现会提示Unused variable self的警告，具体这两个宏定义内部怎么实现的就比较复杂了。
- (void)setupSignal {
    @weakify(self);
    // 创建获取更多的command，其block的返回值是一个RACSignal，这个signal就是网络请求的signal。
    // 在这个block中有一个参数，这个参数就是控制器调用execute:方法传进来的参数，但在这个Demo中并没有用到。如果是多个参数，可以放在字典中传进来。
    self.fetchMoreDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id inputValue) {
        @strongify(self);
        // 调用Demo中封装的类发起网络请求，传入的index表示从第几个开始获取，这个在平时的业务中经常会用到。
        // 需要注意的是，在获取网络请求的RACSignal对象之后，还调用了takeUntil:方法，这个方法表示在某个信号来到时停止当前signal的执行。
        // 在这里的业务逻辑中就是，在取消的信号来到时，将网络请求信号执行停止。下面的刷新页面command同理。
        return [[self.network fetchMusiclistWithIndex:self.currentIndex]
                                            takeUntil:self.cancelCommand.executionSignals];
    }];
    
    // 刷新页面command，因为是刷新页面，所以要从第一个开始刷新，具体的刷新业务逻辑在下面将会讲解。
    // 当通过调用获取更多和刷新页面这两个command的execute:方法时，会分别调用这两个block。
    self.reloadDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id inputValue) {
        @strongify(self);
        return [[self.network fetchMusiclistWithIndex:@1]
                                            takeUntil:self.cancelCommand.executionSignals];
    }];
    
    // 是否有更多的数据，这里做了个模拟，只要数据>=100将会返回NO，表示没有更多数据。这个信号的返回值是和控制器的item绑定的，决定这item是否可用。
    self.hasMoreSignal = [RACObserve(self, currentIndex) map:^id(NSNumber *value) {
        return value.integerValue >= 100 ? @NO : @YES;
    }];
    
    // 实例化error的信号，这个信号比较特殊，先在这里实例化之后可以创建多次信号和订阅多次。
    self.errorSubject = [RACSubject subject];
    
    // 创建取消的command，并在这里执行取消之后的命令。在Demo中则是网络请求取消，在这里就可以执行取消网络请求的操作，并且可以通过block获取一个参数，参数可以是任意类型的，我们可以改，也可以不改。
    self.cancelCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSString *inputStr) {
        NSLog(@"%@", inputStr);
        return [RACSignal empty];
    }];
}

- (void)setupSubscriber {
    // 获取更多命令的executionSignals数组，存储着当前command的所有信号，但和上面创建的RACSignal对象并不是同一个对象。
    // 在这里通过switchToLatest方法，从executionSignals数组中获得最新创建的信号对象，并将这个信号订阅。虽然这个数组也是一个RACSignal类型的信号，但如果直接订阅这个信号，获取到的block参数将会是一个信号，而不是RACTuple。
    // 这个信号就是上面获取更多和刷新页面的网络请求信号，在这里也可以获取请求回来的结果。
    @weakify(self);
    [[self.fetchMoreDataCommand.executionSignals switchToLatest] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        // 需要注意的是，这里请求回来的结果是通过一个RACTuple(元组)保存的，可以通过这个对象获取到其内部的值。
        [self reloadDataWithTuple:tuple isMore:YES];
    }];
    
    // 刷新页面command的订阅block，具体实现和调用原理和上面类似，这里就不多讲了。
    [[self.reloadDataCommand.executionSignals switchToLatest] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        // 这里是返回数据回来后的处理方法，方法内部大体实现逻辑类似，所以两个信号用了同一个方法，以实现代码重用和封装。并通过isMore参数标明是否获取更多的调用，以便内部做一些不同的处理。
        [self reloadDataWithTuple:tuple isMore:NO];
    }];
    
    // errorSubject同时订阅fetch和reload两个command的error信号，这样在这两个command请求出现任何错误时，都可以回调errorSubject的订阅block。
    // 而这两个command的error信号，就是网络请求失败时传递出来的error信号，具体实现代码在网络请求类中。
    [[RACSignal merge:@[self.fetchMoreDataCommand.errors, self.reloadDataCommand.errors]] subscribe:self.errorSubject];
}

/** 
 为什么不用NSMutableArray：(才疏学浅，如有错误请提出)
 KVO的实现原理中，是通过在运行时动态重写属性的setter方法实现的，并建立了一个子类来承载这个重写的方法，具体原理这里就不多说了。
 如果使用NSMutableArray类型，在获取更多数据时addObject:的方式添加数据，这样KVO是不能获取这个消息的，所以这种方式是不可取的。
 而RAC内部的实现原理恰巧是基于KVO的。
 */

/** 
 数据获取的业务逻辑分析：
 在请求更多数据时，将数据向数组后面添加，这个逻辑是非常常见的。
 但在请求了几十条数据后，在刷新页面时其实并没有必要刷新这几十条的数据，这样费流量而且服务器压力也大。所以在刷新页面时，就按照最开始的逻辑一样，只刷新前十五条，其他数据就都移除了。
 无论是刷新数据，还是请求更多数据，模型数组都是重新赋值的，以便外界能够获取到这次数据变化的消息。
 */
- (void)reloadDataWithTuple:(RACTuple *)tuple isMore:(BOOL)isMore {
    
    NSDictionary *dict      = tuple.first;
    NSDictionary *modelData = dict[@"model"];
    self.currentIndex       = @([modelData[@"cindex"] integerValue] + 15);// 每次更新15条
    NSMutableArray *array   = [RACMusicListModel objectArrayWithKeyValuesArray:modelData[@"list"]];
    
    if (isMore) {
        self.dataList = [self.dataList arrayByAddingObjectsFromArray:array];
    } else {
        self.dataList = array;
    }
}

#pragma mark - ----- Public Method ------

- (RACMusicListModel *)itemModelOfIndexPath:(NSIndexPath *)indexPath {
    return self.dataList[indexPath.row];
}

#pragma mark - ----- Setter && Getter ------

- (RACMusicListNetwork *)network {
    if (!_network) {
        _network = [[RACMusicListNetwork alloc] init];
    }
    return _network;
}

@end










