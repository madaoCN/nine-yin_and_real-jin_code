//
//  ViewController.m
//  sensor
//
//  Created by exchen on 2018/4/30.
//  Copyright © 2018年 exchen. All rights reserved.
//

#import "ViewController.h"
#import "eXCollectorSensor.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    eXCollectorSensor *sensor = [[eXCollectorSensor alloc] init];
    NSDictionary *dic = [sensor getAltimeter];
    NSLog(@"Altimeter: %@",dic);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
