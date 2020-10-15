//
//  BookContentViewSettings.h
//  Auri
//
//  Created by Fectum on 16/04/16.
//  Copyright © 2016 Argentum. All rights reserved.
//

@import Foundation;
@import WebKit;
@protocol ARGBookReadingSettings;

@interface ARGFlowableLayoutSettingsProvider : NSObject

@property (nonatomic, weak, readonly) WKWebView *webView;

@property (nonatomic, assign, readonly) UIOffset         relativePageMargins;
@property (nonatomic, assign, readonly) UIOffset         absolutePageMargins;
@property (nonatomic, assign, readonly) int64_t alignment;

- (instancetype)initWithWebView:(WKWebView *)webView;

- (void)setSettings:(id<ARGBookReadingSettings>)settings completion:(dispatch_block_t)completion;

@end
