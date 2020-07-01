//
//  DUCollectorSensor.h
//  du
//
//  Created by exchen on 17/7/12.
//  Copyright © 2017年 exchen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreMotion/CoreMotion.h>
#import <CoreMotion/CMAltimeter.h>

@interface eXCollectorSensor : NSObject
{
    float g_alt;
    float g_pressure;
}

- (NSDictionary*)getAccelerometer;  //获取加速计
- (NSDictionary*)getGyroscope;      //获取陀螺仪
- (NSDictionary*)getMagnetometer;   //获取磁力计
- (NSDictionary*)getAltimeter;      //获取气压传感器

- (NSDictionary*)getSensorInfo;

@end
