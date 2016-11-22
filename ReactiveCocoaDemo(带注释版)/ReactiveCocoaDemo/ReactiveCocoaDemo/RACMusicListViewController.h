//
//  RACMusicListViewController.h
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import <UIKit/UIKit.h>

/** 
 从这个Demo可以看出，无论是Signal还是Command，其创建和订阅都是成对出现的。(这里说的成对指的是创建和使用的概念，然而订阅信号是可以订阅多次的，命令也是可以设置多次的)
 RAC和Masonry很相似，都是采取的链式语法的调用方式，并且大量使用了block的方式进行消息回调，看起来非常整洁。
 */

/** 
 对于RACSubject的解释：
 RACSubject本质上和RACSignal差不多，但可以通过一个subject创建多个信号，并让订阅者订阅多个信号。RACSubject只对新加入的订阅者分发信号，已经错过的信号就不再重新分发了。
 从源码来看，RACSubject通过一个数组管理者多个信号，并且自己管理自己的dispose。
 */

/** 
 对于RACCommand的解释：
 RACCommand主要用来响应一些action的事件，例如button、item的点击事件，RAC为一些可以响应事件的控件以及UIControl都创建了Category，在Category中声明了一些响应事件的方法。这些代码都在/ReactiveCocoa/UI/的文件夹下。
 当然也可以手动创建RACCommand，并通过调用command的execute:方法来执行这个command，在调用时也可以传递参数进去。其他地方可以通过订阅RACCommand的executing信号，来获取执行过程中的改变。(block参数是一个BOOL值，用来表示是否正在执行)
 */

@interface RACMusicListViewController : UIViewController

@end






























