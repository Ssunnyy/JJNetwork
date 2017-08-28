//
//  ViewController.m
//  JJNetwork
//
//  Created by jezz on 30/07/2017.
//  Copyright © 2017 jezz. All rights reserved.
//

#import "DemoViewController.h"
#import "DemoAPIService.h"
#import "PresentViewController.h"

@interface DemoViewController ()<APIServiceProtocol>

@property(nonatomic,readwrite,strong)DemoAPIService* apiService;

@end

@implementation DemoViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self.apiService startRequest];
    
    UIButton* button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"Present View Controller" forState:UIControlStateNormal];
    button.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 30);
    [button addTarget:self action:@selector(presentViewController) forControlEvents:UIControlEventTouchUpInside];
    button.center = self.view.center;
    [self.view addSubview:button];
}

- (void)presentViewController{
    PresentViewController* present = [[PresentViewController alloc] init];
    [self presentViewController:present animated:YES completion:nil];
}


- (DemoAPIService*)apiService{
	if (_apiService != nil) {
		return _apiService;
	}
	_apiService = [[DemoAPIService alloc] init];
	_apiService.serviceProtocol = self;
	return _apiService;
}

#pragma mark - Network response

- (void)responseSuccess:(APIService *)service responseData:(id)data{
	
}

- (void)responseFail:(APIService *)service errorMessage:(NSError *)error{
	
}

#pragma mark - Config request parameter

- (NSDictionary*)requestParameters{
    NSDictionary* para = @{@"key":@"value"};
	return para;
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}


@end
