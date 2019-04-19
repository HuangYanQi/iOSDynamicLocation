#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface ECLocationTransform : NSObject

@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;

- (ECLocationTransform*)initWithLatitude:(double)latitude andLongitude:(double)longitude;
- (ECLocationTransform*)initWithCLLocationCoordinate:(CLLocationCoordinate2D)coordinate2D;

/*
 坐标系：
 WGS-84：是国际标准，GPS坐标（Google Earth使用、或者GPS模块）
 GCJ-02：中国坐标偏移标准，Google Map、高德、腾讯使用
 BD-09 ：百度坐标偏移标准，Baidu Map使用
 */

#pragma mark - 从GPS坐标转化到高德坐标
- (ECLocationTransform*)transformFromGPSToGD;

#pragma mark - 从高德坐标转化到百度坐标
- (ECLocationTransform*)transformFromGDToBD;

#pragma mark - 从百度坐标到高德坐标
- (ECLocationTransform*)transformFromBDToGD;

#pragma mark - 从高德坐标到GPS坐标
- (ECLocationTransform*)transformFromGDToGPS;

#pragma mark - 从百度坐标到GPS坐标
- (ECLocationTransform*)transformFromBDToGPS;

@end
