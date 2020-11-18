//
//  BaseBookContentViewSettingsProvider.h
//  Auri
//
//  Created by Sergei Polshcha on 09/05/16.
//



@import Foundation;
@import WebKit;
@protocol ARGBookReadingSettings;

@interface ARGBookReadingSettingsController : NSObject

@property (nonatomic, weak, readonly) WKWebView *webView;

@property (nonatomic, strong, readonly) id<ARGBookReadingSettings> settings;

@property (nonatomic, assign, readonly) CGFloat  fontSize;
@property (nonatomic, strong, readonly) UIColor  *highlightColor;
@property (nonatomic, assign, readonly) CGFloat  viewPortWidth;
@property (nonatomic, strong, readonly) NSString *fontFamily;
@property (nonatomic, assign, readonly) BOOL     hyphenation;
@property (nonatomic, assign, readonly) int64_t alignment;

@property (nonatomic, strong, readonly) UIColor *textColor;

@property (nonatomic, assign, readonly) CGSize pageSize;

- (instancetype)initWithWebView:(WKWebView *)webView;

- (void)setSettings:(id<ARGBookReadingSettings>)settings pageSize:(CGSize)pageSize completion:(dispatch_block_t)completion;

- (void)setTextColor:(UIColor *)textColor completion:(dispatch_block_t)completion;

@end
