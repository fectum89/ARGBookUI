//
//  ARGScrollViewDelegateProxy.h
//  ARGView
//
//  Created by Sergei Polshcha on 17.10.2020.
//  Copyright © 2020 Argentum. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface ARGScrollViewDelegateProxy : NSObject <UIScrollViewDelegate>

- (void)addDelegate:(id<UIScrollViewDelegate>)delegate;
- (void)removeDelegate:(id<UIScrollViewDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
