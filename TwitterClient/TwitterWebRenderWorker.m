//
//  TwitterWebRenderWorker.m
//  TwitterClient
//
//  Created by 小野 将司 on 2013/11/29.
//  Copyright (c) 2013年 akisute. All rights reserved.
//

#import "TwitterWebRenderWorker.h"

@interface TwitterWebRenderWorker () <UIWebViewDelegate>
@property (nonatomic) UIWindow *window;     // The window which holds web view
@property (nonatomic) UIWebView *webView;   // The web view to render HTML
@end

@implementation TwitterWebRenderWorker

- (TwitterWebRenderWorkerStatus)status
{
    if (!self.webView) {
        return TwitterWebRenderWorkerStatusUnknown;
    }
    return (self.webView.loading) ? TwitterWebRenderWorkerStatusExecuting : TwitterWebRenderWorkerStatusReady;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Requires application instance (=screen, window) to render HTML using UIWebView
        UIApplication *application = [UIApplication sharedApplication];
        if (!application) {
            return nil;
        }
        
        // Uses default key window of the application as a host of web view
        // Perhaps we can create off-screen window for this, but I'm not confident whether off-screen windows can render web contents
        self.window = application.keyWindow;
        if (!self.window) {
            return nil;
        }
        
        // Create a web view and hide it below any views in the window
        self.webView = [[UIWebView alloc] initWithFrame:self.window.bounds];
        self.webView.userInteractionEnabled = NO;
        self.webView.hidden = NO;
        self.webView.delegate = self;
        UIView *backmostView = self.window.subviews.firstObject;
        [self.window insertSubview:self.webView belowSubview:backmostView];
    }
    return self;
}

- (BOOL)startRenderingWithURL:(NSURL *)url
{
    if (self.status != TwitterWebRenderWorkerStatusReady) {
        return NO;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0f];
    [self.webView loadRequest:request];
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([self.delegate respondsToSelector:@selector(renderWorker:didFinishRenderingSnapshotView:forURL:)]) {
        UIView *view = [webView snapshotViewAfterScreenUpdates:NO];
        [self.delegate renderWorker:self didFinishRenderingSnapshotView:view forURL:webView.request.URL];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(renderWorker:didFinishRenderingSnapshotView:forURL:)]) {
        [self.delegate renderWorker:self didFinishRenderingSnapshotView:nil forURL:webView.request.URL];
    }
}

@end