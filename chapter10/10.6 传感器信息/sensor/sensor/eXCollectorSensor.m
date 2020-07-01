//
//  eXCollectorSensor.m
//  du
//
//  Created by exchen on 17/7/12.
//  Copyright © 2017年 exchen. All rights reserved.
//

#import "eXCollectorSensor.h"

#include <unistd.h>

@implementation eXCollectorSensor

bool bAccelerometerUpdate = 0;
bool bGyroscopeUpdate = 0;
bool bMagnetometerUpdate = 0;

- (NSDictionary*)getSensorInfo{
    
    NSDictionary *dicAccelerometInfo = [self getAccelerometer];
    
    NSDictionary *dicGryoInfo = [self getGyroscope];
    
    NSDictionary *dicMagnetInfo = [self getMagnetometer];
    
    NSDictionary *dicAltimetInfo = [self getAltimeter];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    [dic addEntriesFromDictionary:dicAccelerometInfo];
    [dic addEntriesFromDictionary:dicGryoInfo];
    [dic addEntriesFromDictionary:dicMagnetInfo];
    [dic addEntriesFromDictionary:dicAltimetInfo];
    
    return dic;
}

- (NSDictionary*)getAccelerometer{

    CMMotionManager *motionAcceler  = [[CMMotionManager alloc] init];
    motionAcceler.accelerometerUpdateInterval = 0.1;
    
    if ([motionAcceler isAccelerometerAvailable]){
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [motionAcceler startAccelerometerUpdatesToQueue:queue withHandler:
         ^(CMAccelerometerData *accelerometerData, NSError *error) {
      
            [motionAcceler stopAccelerometerUpdates];   //进来就停掉。
             
             bAccelerometerUpdate = 1;
         }];
    } else {
        NSLog(@"Accelerometer is not available.");
    }
    
    sleep(2);

    CMAccelerometerData *accelerometerData = motionAcceler.accelerometerData;
    NSNumber *numberAccelerometX= [NSNumber numberWithDouble:accelerometerData.acceleration.x];
    NSNumber *numberAccelerometY = [NSNumber numberWithDouble:accelerometerData.acceleration.y];
    NSNumber *numberAccelerometZ = [NSNumber numberWithDouble:accelerometerData.acceleration.z];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                     numberAccelerometX,@"x",
                     numberAccelerometY,@"y",
                     numberAccelerometZ,@"z",nil];
    
    NSDictionary *dicAccelerometInfo = [NSDictionary dictionaryWithObjectsAndKeys:dic, @"acceleromet",nil];

    return dicAccelerometInfo;
}

- (NSDictionary*) getGyroscope{
    
    CMMotionManager *motionGyro = [[CMMotionManager alloc] init];
    motionGyro.gyroUpdateInterval = 0.1;
    
    if ([motionGyro isGyroAvailable]){
        
         NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [motionGyro startGyroUpdatesToQueue:queue withHandler:^(CMGyroData *gyroData, NSError *error) {
        
            [motionGyro stopGyroUpdates];   //进来就停掉。
            bGyroscopeUpdate = 1;
        }];
        
    } else {
        
        NSLog(@"Gyroscope is not available.");
    }
    
    sleep(2);

    CMRotationRate rotate = motionGyro.gyroData.rotationRate;
    NSNumber *numberGyroX = [NSNumber numberWithDouble:rotate.x];
    NSNumber *numberGyroY = [NSNumber numberWithDouble:rotate.y];
    NSNumber *numberGyroZ = [NSNumber numberWithDouble:rotate.z];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         numberGyroX,@"x",
                         numberGyroY,@"y",
                         numberGyroZ,@"z",nil];
    
    NSDictionary *dicGryoInfo = [NSDictionary dictionaryWithObjectsAndKeys:dic, @"gyroscope",nil];
    
    return dicGryoInfo;
}

-(NSDictionary*) getMagnetometer{
    
    CMMotionManager *motionMagnet = [[CMMotionManager alloc] init];
    
    motionMagnet.magnetometerUpdateInterval = 0.1;
    
    if ([motionMagnet isMagnetometerAvailable]){
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];

        [motionMagnet startMagnetometerUpdatesToQueue:queue
        withHandler:^(CMMagnetometerData *magnetometerData, NSError *error) {
            
            [motionMagnet stopMagnetometerUpdates];
            bMagnetometerUpdate = 1;
        }];
        
    } else {
        NSLog(@"磁力计不可用.");
    }
    
    sleep(2);
    
    CMMagneticField heading= motionMagnet.magnetometerData.magneticField;
    
    NSNumber *numberMagnetX = [NSNumber numberWithDouble:heading.x];
    NSNumber *numberMagnetY = [NSNumber numberWithDouble:heading.y];
    NSNumber *numberMagnetZ = [NSNumber numberWithDouble:heading.z];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                                   numberMagnetX,@"x",
                                   numberMagnetY,@"y",
                                   numberMagnetZ,@"z",nil];
    
    NSDictionary *dicMagnetInfo = [NSDictionary dictionaryWithObjectsAndKeys:dic, @"magnet",nil];
    
    return dicMagnetInfo;
}

// 气压计暂时不启用
- (NSDictionary*)getAltimeter{
    //创建气压计（测高仪）
    CMAltimeter *altimeter = [[CMAltimeter alloc] init];
    
    //检测当前设备是否可用（iphone6机型之后新增）
    if([CMAltimeter isRelativeAltitudeAvailable])
    {
        //开始检测气压
        
         NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [altimeter startRelativeAltitudeUpdatesToQueue:queue withHandler:^(CMAltitudeData * _Nullable altitudeData, NSError * _Nullable error) {
            
            g_alt =[altitudeData.relativeAltitude floatValue];
            g_pressure = [altitudeData.pressure floatValue];
            
            [altimeter stopRelativeAltitudeUpdates];
        }];
    }
    else
    {
        NSLog(@"no altimeter");
    }

    sleep(3);
    
    NSString *strHigh = [NSString stringWithFormat:@"%.8f",g_alt];
    NSString *strPressure = [NSString stringWithFormat:@"%0.8f", g_pressure];
    
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                         strHigh,@"alt",
                         strPressure,@"pressure",
                         nil];
    
    NSDictionary *dicAltimetInfo = [NSDictionary dictionaryWithObjectsAndKeys:dic, @"altimet",nil];
    
    return dicAltimetInfo;
}

@end
