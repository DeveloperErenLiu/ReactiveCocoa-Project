//
//  RACMusicListModel.h
//
//  Created by 刘小壮 on 2016/11/21.
//  Copyright © 2016年 刘小壮. All rights reserved.
//

#import <Foundation/Foundation.h>

// 简单写了个模型对象，就取了两个字符串的字段。
@interface RACMusicListModel : NSObject
@property (nonatomic, copy) NSString *worksName;
@property (nonatomic, copy) NSString *worksText;
@end
