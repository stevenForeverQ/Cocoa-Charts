//
//  CCSGroupChart.h
//  Cocoa-Charts
//
//  Created by zhourr on 11-10-24.
//  Copyright 2011 limc.cn All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <UIKit/UIKit.h>

#import "CCSColoredStickChart.h"
#import "CCSMACDChart.h"
#import "CCSSlipLineChart.h"
#import "CCSCandleStickChart.h"
#import "CCSBOLLMASlipCandleStickChart.h"
#import "CCSMAColoredStickChart.h"

#import "CCSOHLCVDData.h"

typedef enum {
    GroupChartViewTypeVOL = 101,
    GroupChartViewTypeMACD = 102,
    GroupChartViewTypeKDJ = 103,
    GroupChartViewTypeRSI = 104,
    GroupChartViewTypeWR = 105,
    GroupChartViewTypeCCI = 106,
    GroupChartViewTypeBOLL = 107
} GroupChartViewType;

typedef enum {
    GroupChartHorizontalType,
    GroupChartverticalType
} GroupChartOrientationType;

@interface CCSGroupChartData : NSObject

@property(copy, nonatomic) NSArray   *ohlcvdDatas;

/** CandleStickChartData */
@property(strong, nonatomic) NSArray *candleStickData;
@property(strong, nonatomic) NSArray *candleStickLinesData;
@property(strong, nonatomic) NSArray *candleStickBollingerBandData;

/** StickChart */
@property(strong, nonatomic) NSArray *stickData;
@property(strong, nonatomic) NSArray *stickMAData;

/** MacdChart */
@property(strong, nonatomic) NSArray *macdStickData;

/** KDJChart */
@property(strong, nonatomic) NSArray *kdjLinesData;

/** RSIChart */
@property(strong, nonatomic) NSArray *rsiLinesData;

/** WRChart */
@property(strong, nonatomic) NSArray *wrLinesData;

/** CCIChart */
@property(strong, nonatomic) NSArray *cciLinesData;

/** BOLLChart */
@property(strong, nonatomic) NSArray *bollLinesData;

/**
 * 初始化数据
 */
- (id)initWithCCSOHLCVDDatas:(NSArray *)ohlcvdDatas;

/**
 * 更新某个指标
 */
- (void)updateMACDStickData:(NSInteger)macdS l:(NSInteger)macdL m:(NSInteger)macdM;
- (void)updateCandleStickLinesData:(NSInteger)ma1 ma2:(NSInteger)ma2 ma3:(NSInteger)ma3;
- (void)updateCandleStickBollingerBandData:(NSInteger) bollN;
- (void)updateStickLinesData:(NSInteger)ma1 ma2:(NSInteger)ma2 ma3:(NSInteger)ma3;
- (void)updateKDJData:(NSInteger)macdN;
- (void)updateRSIData:(NSInteger) n1 n2:(NSInteger) n2;
- (void)updateWRData:(NSInteger) wrN;
- (void)updateCCIData:(NSInteger) cciN;
- (void)updateBOLLData:(NSInteger) bollN;

@end

@interface CCSGroupChart : UIView<UIScrollViewDelegate>

/*******************************************************************************
 * initialize
 *******************************************************************************/

- (void)initialize;

/*******************************************************************************
 * Public Properties
 *******************************************************************************/

/** K线图 */
@property(strong, nonatomic) CCSBOLLMASlipCandleStickChart *candleStickChart;
/** VOL 图 */
@property(strong, nonatomic) CCSMAColoredStickChart *stickChart;
/** MACD 图 */
@property(strong, nonatomic) CCSMACDChart *macdChart;
/** KDJ 图 */
@property(strong, nonatomic) CCSSlipLineChart *kdjChart;
/** RSI 图 */
@property(strong, nonatomic) CCSSlipLineChart *rsiChart;
/** WR 图 */
@property(strong, nonatomic) CCSSlipLineChart *wrChart;
/** CCI 图 */
@property(strong, nonatomic) CCSSlipLineChart *cciChart;
/** BOLL 图 */
@property(strong, nonatomic) CCSSlipLineChart *bollChart;
/** 图表类型切换 UISegmentedControl */
@property(strong, nonatomic) UISegmentedControl *segBottomChartType;
/** 底部图表容器 */
@property(strong, nonatomic) UIScrollView *scrollViewBottomChart;

/** 当前显示的图表类型 */
@property(assign, nonatomic) GroupChartViewType bottomChartType;

/** 图表数据源,还未计算 */
@property(strong, nonatomic) NSMutableArray *chartData;
/** 图表数据源,已经计算好 */
@property(strong, nonatomic) CCSGroupChartData *groupChartData;

@property(weak, nonatomic) UIViewController<CCSChartDelegate> *chartDelegate;

/** 图表是否全屏 */
@property(assign, nonatomic) GroupChartOrientationType orientationType;

/** 设置 */
@property (nonatomic, copy) void (^setting)();

/*******************************************************************************
 * Public Methods
 *******************************************************************************/

/**
 * 图表 ontouch 事件
 */
- (void)CCSChartBeTouchedOn:(id)chart point:(CGPoint)point indexAt:(NSUInteger)index;
/**
 *
 */
- (void)CCSChartDisplayChangedFrom:(id)chart from:(NSUInteger)from number:(NSUInteger)number;

/**
 * 设置背景色
 */
- (void)setChartsBackgroundColor:(UIColor *)backgroundColor;

/**
 * 设置按钮颜色
 */
- (void)setButtonTextColor: (UIColor *)normalColor selectedColor: (UIColor *)selectedColor;

/**
 * 更新某个图表,直接对数据源进行重新计算
 */
- (void)updateCandleStickChart;
- (void)updateStickChart;
- (void)updateMACDChart;
- (void)updateKDJChart;
- (void)updateRSIChart;
- (void)updateWRChart;
- (void)updateCCIChart;
- (void)updateBOLLChart;

/**
 * 刷新图表,直接对数据源进行修改
 */
- (void)refreshGroupChart;

@end
