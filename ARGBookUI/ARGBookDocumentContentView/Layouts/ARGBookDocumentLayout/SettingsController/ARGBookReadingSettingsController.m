//
//  BaseBookContentViewSettingsProvider.m
//  Auri
//
//  Created by Sergei Polshcha on 09/05/16.
//

#import "ARGBookReadingSettingsController.h"
#import <ARGBookUI/ARGBookUI-Swift.h>

@implementation ARGBookReadingSettingsController

- (instancetype)initWithWebView:(WKWebView *)webView {
    self = [super init];
    if (self) {
        _webView = webView;
        _alignment = -1;
    }
    
    return self;
}

- (void)setSettings:(id<ARGBookReadingSettings>)settings pageSize:(CGSize)pageSize completion:(dispatch_block_t)completion {
    _settings = settings;
    _pageSize = pageSize;
    
    __weak typeof (self) wself = self;
    
    dispatch_group_t settingsGroup = dispatch_group_create();
    
    dispatch_group_notify(settingsGroup, dispatch_get_main_queue(), ^{
        if (completion) {
            completion();
        }
    });
    
    dispatch_group_enter(settingsGroup);
    [self setViewPortWidth:_webView.bounds.size.width completion:^{
        dispatch_group_leave(settingsGroup);
    }];
    
    dispatch_group_enter(settingsGroup);
    [wself setFontSize:settings.fontSize completion:^{
        dispatch_group_leave(settingsGroup);
    }];
    
    dispatch_group_enter(settingsGroup);
    [wself setFontFamily:settings.fontFamily completion:^{
        dispatch_group_leave(settingsGroup);
    }];
 
    dispatch_group_enter(settingsGroup);
    [wself setHighlightColor:settings.highlightColor completion:^{
        dispatch_group_leave(settingsGroup);
    }];
    
    dispatch_group_enter(settingsGroup);
    [wself setAlignment:settings.alignment completion:^{
        dispatch_group_leave(settingsGroup);
    }];
    
    dispatch_group_enter(settingsGroup);
    [wself setHyphenation:settings.hyphenation completion:^{
        dispatch_group_leave(settingsGroup);
    }];
    
}

- (void)setHighlightColor:(UIColor *)highlightColor completion:(dispatch_block_t)completion {
    if ([_highlightColor isEqual:highlightColor]) {
        if (completion) {
            completion();
        }
        
        return;
    }
    
    _highlightColor = highlightColor;
    
    CGFloat redComponent;
    CGFloat blueComponent;
    CGFloat greenComponent;
    CGFloat alphaComponent;
    
    [highlightColor getRed:&redComponent green:&greenComponent blue:&blueComponent alpha:&alphaComponent];
    
    [_webView evaluateJavaScript:[NSString stringWithFormat:@"setHighlightColor('rgba(%.0f, %.0f, %.0f, %.1f)')",
                                  redComponent * 255,
                                  greenComponent * 255,
                                  blueComponent * 255,
                                  alphaComponent]
               completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                    if (completion) {
                        completion();
                    }
    }];
     
}

- (void)setViewPortWidth:(CGFloat)viewPortWidth completion:(dispatch_block_t)completion {
    if (_viewPortWidth == viewPortWidth) {
        if (completion) {
            completion();
        }
        
        return;
    }
    
    _viewPortWidth = viewPortWidth;
    
    NSString *viewPortScript = [NSString stringWithFormat:@"setViewportWidth(%f)", viewPortWidth];
    
    [_webView evaluateJavaScript:viewPortScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (completion) {
            completion();
        }
    }];
}

- (void)setFontSize:(CGFloat)fontSize completion:(dispatch_block_t)completion {
    if (_fontSize == fontSize) {
        if (completion) {
            completion();
        }
        
        return;
    }
    
    _fontSize = fontSize;
    
    [_webView evaluateJavaScript:[NSString stringWithFormat:@"setFontSize(%f)", fontSize] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (completion) {
            completion();
        }
    }];
}

- (void)setFontFamily:(NSString *)fontFamily completion:(dispatch_block_t)completion {
    if ([_fontFamily isEqualToString:fontFamily]) {
        if (completion) {
            completion();
        }
        
        return;
    }
    
    _fontFamily = fontFamily;
    
    [_webView evaluateJavaScript:[NSString stringWithFormat:@"setFontFamily('%@')", fontFamily] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (completion) {
            completion();
        }
    }];
}

- (void)setHyphenation:(BOOL)hyphenation completion:(dispatch_block_t)completion {
    if (_hyphenation == hyphenation) {
        if (completion) {
            completion();
        }
        
        return;
    }
    
    _hyphenation = hyphenation;
    
    [_webView evaluateJavaScript:[NSString stringWithFormat:@"hyphenate(%d, '%@')", hyphenation, _languageCode]
               completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                      if (completion) {
                          completion();
                      }
                  }];
}

- (void)setTextColor:(UIColor *)textColor completion:(dispatch_block_t)completion {
    if ([_textColor isEqual:textColor]) {
        if (completion) {
            completion();
        }
        
        return;
    }
    
    _textColor = textColor;
    
    CGFloat redComponent;
    CGFloat blueComponent;
    CGFloat greenComponent;
    CGFloat alphaComponent;
    
    [textColor getRed:&redComponent green:&greenComponent blue:&blueComponent alpha:&alphaComponent];
    
    [_webView evaluateJavaScript:[NSString stringWithFormat:@"setTextColor('rgba(%.0f, %.0f, %.0f, %f)')",
                                  redComponent * 255,
                                  greenComponent * 255,
                                  blueComponent * 255,
                                  alphaComponent]
               completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                      if (completion) {
                          completion();
                      }
                  }];
}

- (void)setAlignment:(int64_t)alignment completion:(dispatch_block_t)completion {
    if (_alignment == alignment) {
        if (completion) {
            completion();
        }
        
        return;
    }
    
    _alignment = alignment;
    
    NSString *alignmentString = nil;
    
    if (alignment == ARGBookReadingSettingsAlignmentLeft) {
        alignmentString = @"left";
    } else if (alignment == ARGBookReadingSettingsAlignmentJustify) {
        alignmentString = @"justify";
    }
    
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"setTextAlignment('%@')", alignmentString] completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (completion) {
            completion();
        }
    }];
}

@end
