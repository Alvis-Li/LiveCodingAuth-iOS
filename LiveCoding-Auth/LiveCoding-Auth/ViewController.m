//
//  ViewController.m
//  LiveCoding-Auth
//
//  Created by simple on 16/4/21.
//  Copyright © 2016年 levy. All rights reserved.
//

#import "ViewController.h"

#define baseUrl @"https://www.livecoding.tv/o/"
#define authorizeUrl @"authorize/"
#define tokenUrl @"token/"
#define client_id @""
#define redirect_uri @""
#define secret_key @""




@interface ViewController ()<UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation ViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSString *urlStr=[NSString stringWithFormat:@"%@%@?client_id=%@&scope=read&response_type=code&redirect_uri=%@",baseUrl,authorizeUrl,client_id,redirect_uri];
    NSURL *url=[NSURL URLWithString:urlStr];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
}

#pragma mark-UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSString *urlStr=request.URL.absoluteString;
    NSRange range=[urlStr rangeOfString:@"code="];
    if(range.length)
    {
        NSString *code=[urlStr substringFromIndex:range.length+range.location];
        [self accessTokenWithCode:code];
        return NO;
    }
    return YES;
}

- (void)accessTokenWithCode:(NSString *)code{
    
    NSString *userPasswordString = [NSString stringWithFormat:@"%@:%@", client_id, secret_key];
    NSData * userPasswordData = [userPasswordString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedCredential = [userPasswordData base64EncodedStringWithOptions:0];
    NSString *authString = [NSString stringWithFormat:@"Basic %@", base64EncodedCredential];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",baseUrl,tokenUrl]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    [request setValue:authString forHTTPHeaderField:@"Authorization"];
    [request setHTTPMethod:@"POST"];
    NSString *str = [NSString stringWithFormat:@"code=%@&grant_type=authorization_code&redirect_uri=%@",code,redirect_uri];
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    NSError *error;
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@ %@",resultDic,error);
    
}
@end
