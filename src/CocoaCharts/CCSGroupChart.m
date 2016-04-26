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

#import "CCSGroupChart.h"

#import "CCSColoredStickChartData.h"
#import "CCSCandleStickChartData.h"
#import "CCSTitledLine.h"
#import "CCSLineData.h"
#import "CCSMACDData.h"

#import "ta_libc.h"
#import "CCSTALibUtils.h"
#import "CCSStringUtils.h"
#import "NSString+UserDefault.h"
#import "NSString+UIColor.h"
#import "UIView+AutoLayout.h"
#import "NSArray+CCSTACompute.h"

#define WR_NONE_DISPLAY @"101"

#define AXIS_CALC_PARM  1000

#define HORIZONTAL_LEFT_RIGHT_SCALE                     6.0f

#define SOURCE_DATE_FORMAT                              @"yyyy-MM-ddHH:mm:ss"

#define DEAFULT_CHART_BACKGROUND_COLOR                  [UIColor clearColor]
#define DEAFULT_NORMAL_TEXT_COLOR                       [@"#323232" str2Color]
#define DEAFULT_SELECTED_TEXT_COLOR                     [UIColor whiteColor]

@implementation CCSGroupChartData

- (id)initWithCCSOHLCVDDatas:(NSArray *)ohlcvdDatas{
    self = [super init];
    
    if (self) {
        self.ohlcvdDatas = ohlcvdDatas;
        self.candleStickData = [ohlcvdDatas convertCandleStickData];
        self.candleStickLinesData = [ohlcvdDatas convertCandleStickLinesData];
        self.candleStickBollingerBandData = [ohlcvdDatas convertCandleStickBollingerBandData];
        self.stickData = [ohlcvdDatas convertStickData];
        self.stickMAData = [ohlcvdDatas convertStickMAData];
        self.macdStickData = [ohlcvdDatas convertMacdStickData];
        self.kdjLinesData = [ohlcvdDatas convertKDJLinesData];
        self.rsiLinesData = [ohlcvdDatas convertRSILinesData];
        self.wrLinesData = [ohlcvdDatas convertWRLinesData];
        self.cciLinesData = [ohlcvdDatas convertCCILinesData];
        self.bollLinesData = [ohlcvdDatas convertBOLLLinesData];
    }
    return self;
}

- (void)updateCandleStickLinesData:(NSInteger)ma1 ma2:(NSInteger)ma2 ma3:(NSInteger)ma3{
    [MA1 setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)ma1]];
    [MA2 setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)ma2]];
    [MA3 setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)ma3]];
    
    NSMutableArray *maLines = [[NSMutableArray alloc] init];
    [maLines addObject: [self.ohlcvdDatas computeMAData:ma1]];
    [maLines addObject: [self.ohlcvdDatas computeMAData:ma2]];
    [maLines addObject: [self.ohlcvdDatas computeMAData:ma3]];
    
    [maLines enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [maLines[idx] setColor:LINE_COLORS[idx]];
    }];
    
    self.candleStickLinesData = maLines;
}

- (void)updateCandleStickBollingerBandData:(NSInteger) bollN{
    [BOLL_N setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)bollN]];
    
    self.candleStickBollingerBandData = [self.ohlcvdDatas computeBOLLData:bollN optInNbDevUp:2 optInNbDevDn:2];
}

- (void)updateStickLinesData:(NSInteger)ma1 ma2:(NSInteger)ma2 ma3:(NSInteger)ma3{
    [VMA1 setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)ma1]];
    [VMA2 setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)ma2]];
    [VMA3 setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)ma3]];
    
    NSMutableArray *maLines = [[NSMutableArray alloc] init];
    [maLines addObject: [self.ohlcvdDatas computeVOLMAData:ma1]];
    [maLines addObject: [self.ohlcvdDatas computeVOLMAData:ma2]];
    [maLines addObject: [self.ohlcvdDatas computeVOLMAData:ma3]];
    
    [maLines enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [maLines[idx] setColor:LINE_COLORS[idx]];
    }];
    
    self.stickMAData = maLines;
}

- (void)updateMACDStickData:(NSInteger)macdS l:(NSInteger)macdL m:(NSInteger)macdM{
    [MACD_L setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)macdL]];
    [MACD_M setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)macdM]];
    [MACD_S setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)macdS]];
    
    self.macdStickData = [self.ohlcvdDatas computeMACDData:macdL optInSlowPeriod:macdM optInSignalPeriod:macdS];
}

- (void)updateKDJData:(NSInteger)kdjN{
    [KDJ_N setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)kdjN]];
    
    self.kdjLinesData = [self.ohlcvdDatas computeKDJData:kdjN optInSlowK_Period:3 optInSlowD_Period:3];
}

- (void)updateRSIData:(NSInteger) n1 n2:(NSInteger) n2{
    [RSI_N1 setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)n1]];
    [RSI_N2 setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)n2]];
    
    NSMutableArray *linesData = [[NSMutableArray alloc] init];
    [linesData addObject:[self.ohlcvdDatas computeRSIData:n1]];
    [linesData addObject:[self.ohlcvdDatas computeRSIData:n2]];
    [linesData addObject:[self.ohlcvdDatas computeRSIData:24]];
    
    self.rsiLinesData = linesData;
}

- (void)updateWRData:(NSInteger) wrN{
    [WR_N setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)wrN]];
    
    self.wrLinesData = [self.ohlcvdDatas computeWRData:wrN];
}

- (void)updateCCIData:(NSInteger) cciN{
    [CCI_N setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)cciN]];
    
    self.cciLinesData = [self.ohlcvdDatas computeCCIData:cciN];
}

- (void)updateBOLLData:(NSInteger) bollN{
    [BOLL_N setUserDefaultWithString:[NSString stringWithFormat:@"%ld", (long)bollN]];
    
    self.bollLinesData = [self.ohlcvdDatas computeBOLLData:bollN optInNbDevUp:2 optInNbDevDn:2];
}

@end

@interface CCSGroupChart (){
    /** 是否初始化 */
    BOOL                     _isInitialize;
    /** 是否需要重新加载 */
    BOOL                     _needsReload;
    /** 是否需要刷新图表 */
    BOOL                     _needsRefresh;
    /** 当前 view 大小 */
    CGSize                   _contentSize;
    UIView                  *_vSelected;
    
    /** 图表背景色 */
    UIColor                 *_chartsBackgroundColor;
    /** 按钮文字颜色 */
    UIColor                 *_buttonNormalTextColor;
    /** 按钮选中文字颜色 */
    UIColor                 *_buttonSelectedTextColor;
    
    UILabel                 *_lblOpen;
    UILabel                 *_lblClose;
    UILabel                 *_lblHigh;
    UILabel                 *_lblLow;
    
    UILabel                 *_lblVOL;
    
    UILabel                 *_lblMACDLabel;
    UILabel                 *_lblMACD;
    UILabel                 *_lblDIF;
    UILabel                 *_lblDEA;
    
    UILabel                 *_lblKDJLabel;
    UILabel                 *_lblK;
    UILabel                 *_lblD;
    UILabel                 *_lblJ;
    
    UILabel                 *_lblR;
    UILabel                 *_lblS;
    UILabel                 *_lblI;
    
    UILabel                 *_lblWRLabel;
    UILabel                 *_lblWR;
    
    UILabel                 *_lblCCILabel;
    UILabel                 *_lblCCI;
    
    UILabel                 *_lblBOLLLabel;
    UILabel                 *_lblB;
    UILabel                 *_lblO;
    UILabel                 *_lblL;
}

@end

@implementation CCSGroupChart

/*******************************************************************************
 * initialize
 *******************************************************************************/

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    // 设置初始化标识
    _isInitialize = YES;
    
    self.orientationType = GroupChartverticalType;
}

/*******************************************************************************
 * Overrides From UIView
 *******************************************************************************/

- (void)layoutSubviews{
    [super layoutSubviews];
    // 初始化
    if (_isInitialize) {
        _isInitialize = NO;
        _contentSize = self.bounds.size;
        
        if (!_chartsBackgroundColor) {
            _chartsBackgroundColor = DEAFULT_CHART_BACKGROUND_COLOR;
        }
        if (!_buttonNormalTextColor) {
            _buttonNormalTextColor = DEAFULT_NORMAL_TEXT_COLOR;
        }
        if (!_buttonSelectedTextColor) {
            _buttonSelectedTextColor = DEAFULT_SELECTED_TEXT_COLOR;
        }
        
        [self initControllers];
        
        [self initCandleStickChart];
        [self initStickChart];
        [self initMACDChart];
        [self initKDJChart];
        [self initRSIChart];
        [self initWRChart];
        [self initCCIChart];
        [self initBOLLChart];
        
        self.scrollViewBottomChart.contentSize = CGSizeMake(self.scrollViewBottomChart.frame.size.width * 7, self.self.scrollViewBottomChart.frame.size.height);
    }
    // 重新加载数据
    if (_needsReload) {
        _needsReload = NO;
        
        [self initCandleStickChartData];
        [self initStickChartData];
        [self initMACDChartData];
        [self initKDJChartData];
        [self initRSIChartData];
        [self initWRChartData];
        [self initCCIChartData];
        [self initBOLLChartData];
        
        CCSOHLCVDData *ohlcData = self.groupChartData.ohlcvdDatas[[self.groupChartData.ohlcvdDatas count] - 1];
        CCSOHLCVDData *lastOhlcData = [self.groupChartData.ohlcvdDatas count] > 1?self.groupChartData.ohlcvdDatas[[self.groupChartData.ohlcvdDatas count] - 2]:ohlcData;
        
        [_lblOpen setText: [[NSString stringWithFormat:@"%f", ohlcData.open/1000] decimal:0]];
        [_lblClose setText: [[NSString stringWithFormat:@"%f", ohlcData.close/1000] decimal:0]];
        [_lblHigh setText: [[NSString stringWithFormat:@"%f", ohlcData.high/1000] decimal:0]];
        [_lblLow setText: [[NSString stringWithFormat:@"%f", ohlcData.low/1000] decimal:0]];
        [_lblVOL setText:[[NSString stringWithFormat:@"%f", ohlcData.vol] decimal:2]];
        
        //设置标签文本颜色
        if (ohlcData.open == 0) {
            _lblOpen.textColor = [UIColor lightGrayColor];
        } else {
            //设置标签文本颜色
            _lblOpen.textColor = ohlcData.open != lastOhlcData.close ? ohlcData.open > lastOhlcData.close ? LINE_COLORS[0] : LINE_COLORS[1] : [UIColor lightGrayColor];
        }
        
        if (ohlcData.high == 0) {
            _lblHigh.textColor = [UIColor lightGrayColor];
        } else {
            //设置标签文本颜色
            _lblHigh.textColor = ohlcData.high != lastOhlcData.close ? ohlcData.high > lastOhlcData.close ? LINE_COLORS[0] : LINE_COLORS[1] : [UIColor lightGrayColor];
        }
        
        if (ohlcData.low == 0) {
            _lblLow.textColor = [UIColor lightGrayColor];
        } else {
            _lblLow.textColor = ohlcData.low != lastOhlcData.close ? ohlcData.low > lastOhlcData.close ? LINE_COLORS[0] : LINE_COLORS[1] : [UIColor lightGrayColor];
        }
        
        if (ohlcData.close == 0) {
            _lblClose.textColor = [UIColor lightGrayColor];
        } else {
            _lblClose.textColor = ohlcData.close != lastOhlcData.close ? ohlcData.close > lastOhlcData.close ? LINE_COLORS[0] : LINE_COLORS[1] : [UIColor lightGrayColor];
        }

        NSString *macdL = [MACD_L getUserDefaultString];
        NSString *macdM = [MACD_M getUserDefaultString];
        NSString *macdS = [MACD_S getUserDefaultString];
        [_lblMACDLabel setText:[NSString stringWithFormat:@"MACD(%@,%@,%@):", macdL,macdM,macdS]];
        CCSMACDData *macdData = nil;
        @try {
            macdData = self.groupChartData.macdStickData[[self.groupChartData.macdStickData count] - 1];
        }
        @catch (NSException *exception) {
        }
        if (macdData) {
            [_lblMACD setText: [[NSString stringWithFormat:@"%f", macdData.macd] decimal:2]];
            [_lblDIF setText: [[[NSString stringWithFormat:@"%f", macdData.diff] decimal:2] concate:@"DIF:"]];
            [_lblDEA setText: [[[NSString stringWithFormat:@"%f", macdData.dea] decimal:2] concate:@"DEA:"]];
        }else{
            [_lblMACD setText:@"-0.00"];
            [_lblDIF setText:@"DIF:-0.00"];
            [_lblDEA setText:@"DEA:-0.00"];
        }
        NSString *KDJN = [KDJ_N getUserDefaultString];
        [_lblKDJLabel setText:[NSString stringWithFormat:@"KDJ(%@,3,3):", KDJN]];
        
        NSMutableArray *kdjData = [[NSMutableArray alloc] init];
        [self.groupChartData.kdjLinesData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CCSTitledLine *line = self.groupChartData.kdjLinesData[idx];
            CCSLineData *lineData = line.data[[[line data] count] - 1];
            NSString *kdj = [[NSString stringWithFormat:@"%f", lineData.value] decimal:2];
            [kdjData addObject:kdj];
        }];
        if (kdjData && [kdjData count] == 3) {
            [_lblK setText: [kdjData[0] concate:@"K:"]];
            [_lblD setText: [kdjData[1] concate:@"D:"]];
            [_lblJ setText: [kdjData[2] concate:@"J:"]];
        }else{
            [_lblK setText: [@"0.00" concate:@"K:"]];
            [_lblD setText: [@"0.00" concate:@"D:"]];
            [_lblJ setText: [@"0.00" concate:@"J:"]];
        }
        
        NSString *rsiN1 = [RSI_N1 getUserDefaultString];
        NSString *rsiN2 = [RSI_N2 getUserDefaultString];
        
        NSMutableArray *rsiData = [[NSMutableArray alloc] init];
        [self.groupChartData.rsiLinesData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CCSTitledLine *line = self.groupChartData.rsiLinesData[idx];
            CCSLineData *lineData = line.data[[[line data] count] - 1];
            NSString *rsi = [[NSString stringWithFormat:@"%f", lineData.value] decimal:2];
            [rsiData addObject:rsi];
        }];
        if (rsiData && [rsiData count] == 3) {
            [_lblR setText: [NSString stringWithFormat:@"RSI%@:%@", rsiN1,rsiData[0]]];
            [_lblS setText: [NSString stringWithFormat:@"RSI%@:%@", rsiN2,rsiData[1]]];
            [_lblI setText: [NSString stringWithFormat:@"RSI%@:%@", @"24",rsiData[2]]];
        }else{
            [_lblR setText: [NSString stringWithFormat:@"RSI%@:%@", rsiN1,@"0.00"]];
            [_lblS setText: [NSString stringWithFormat:@"RSI%@:%@", rsiN2,@"0.00"]];
            [_lblI setText: [NSString stringWithFormat:@"RSI%@:%@", @"24",@"0.00"]];
        }
        
        NSString *wrN = [WR_N getUserDefaultString];
        if (self.groupChartData.wrLinesData && [self.groupChartData.wrLinesData count] > 0) {
            CCSTitledLine *wrLine = self.groupChartData.wrLinesData[0];
            CCSLineData *wrLineData = wrLine.data[[[wrLine data] count] - 1];
            NSString *wr = [[NSString stringWithFormat:@"%f", wrLineData.value] decimal:2];
            
            [_lblWRLabel setText:[NSString stringWithFormat:@"WR(%@):", wrN]];
            [_lblWR setText:wr];
        }else{
            [_lblWRLabel setText:[NSString stringWithFormat:@"WR(%@):", wrN]];
            [_lblWR setText:@"0.00"];
        }
        
        NSString *cciN = [CCI_N getUserDefaultString];
        if (self.groupChartData.cciLinesData && [self.groupChartData.cciLinesData count] > 0) {
            CCSTitledLine *cciLine = self.groupChartData.cciLinesData[0];
            CCSLineData *cciLineData = cciLine.data[[[cciLine data] count] - 1];
            NSString *cci = [[NSString stringWithFormat:@"%f", cciLineData.value] decimal:2];
            
            [_lblCCILabel setText:[NSString stringWithFormat:@"CCI(%@):", cciN]];
            [_lblCCI setText:cci];
        }else{
            [_lblCCILabel setText:[NSString stringWithFormat:@"CCI(%@):", cciN]];
            [_lblCCI setText:@"0.00"];
        }
        
        NSString *bollN = [BOLL_N getUserDefaultString];
        
        [_lblBOLLLabel setText:[NSString stringWithFormat:@"BOLL(%@,2,2):", bollN]];
        
        NSMutableArray *bollData = [[NSMutableArray alloc] init];
        [self.groupChartData.bollLinesData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CCSTitledLine *line = self.groupChartData.bollLinesData[idx];
            CCSLineData *lineData = line.data[[[line data] count] - 1];
            NSString *boll = [[NSString stringWithFormat:@"%f", lineData.value/1000] decimal:2];
            [bollData addObject:boll];
        }];
        if (bollData && [bollData count] == 3) {
            [_lblB setText: bollData[0]];
            [_lblO setText: bollData[1]];
            [_lblL setText: bollData[2]];
        }else{
            [_lblB setText: @"0.00"];
            [_lblO setText: @"0.00"];
            [_lblL setText: @"0.00"];
        }
    }
    if (_needsRefresh) {
        _needsRefresh = NO;
        
        [self.candleStickChart setNeedsDisplay];
        [self.stickChart setNeedsDisplay];
        [self.macdChart setNeedsDisplay];
        [self.kdjChart setNeedsDisplay];
        [self.rsiChart setNeedsDisplay];
        [self.wrChart setNeedsDisplay];
        [self.cciChart setNeedsDisplay];
        [self.bollChart setNeedsDisplay];
    }
}

/*******************************************************************************
* Implements Of UIScrollViewDelegate
*******************************************************************************/

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    // 得到每页宽度
    CGFloat pageWidth = sender.frame.size.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    int page = (int) floor((sender.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    //判断是否page发生了变更
    if (self.segBottomChartType.selectedSegmentIndex != page) {
        //设置pageControl
        self.segBottomChartType.selectedSegmentIndex = page;
        [self.segBottomChartType setNeedsDisplay];
    }
}

/*******************************************************************************
 * Implements Of CCSChartDelegate
 *******************************************************************************/

- (void)CCSChartBeTouchedOn:(id)chart point:(CGPoint)point indexAt:(NSUInteger)index {
    
    if ([chart isKindOfClass:[self.candleStickChart class]]) {
        
        if (0 == self.segBottomChartType.selectedSegmentIndex) {
            self.stickChart.singleTouchPoint = point;
            self.stickChart.selectedStickIndex = index;
            [self.stickChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        } else if (1 == self.segBottomChartType.selectedSegmentIndex) {
            self.macdChart.singleTouchPoint = point;
            self.macdChart.selectedStickIndex = index;
            [self.macdChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        } else if (2 == self.segBottomChartType.selectedSegmentIndex) {
            self.kdjChart.singleTouchPoint = point;
            [self.kdjChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        } else if (3 == self.segBottomChartType.selectedSegmentIndex) {
            self.rsiChart.singleTouchPoint = point;
            [self.rsiChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        } else if (4 == self.segBottomChartType.selectedSegmentIndex) {
            self.wrChart.singleTouchPoint = point;
            [self.wrChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        } else if (5 == self.segBottomChartType.selectedSegmentIndex) {
            self.cciChart.singleTouchPoint = point;
            [self.cciChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        } else if (6 == self.segBottomChartType.selectedSegmentIndex) {
            self.bollChart.singleTouchPoint = point;
            [self.bollChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        }
    }else{
        self.stickChart.singleTouchPoint = point;
        self.stickChart.selectedStickIndex = index;
        [self.candleStickChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    }
}

- (void)CCSChartDisplayChangedFrom:(id)chart from:(NSUInteger)from number:(NSUInteger)number{
    
    if ([chart isKindOfClass:[self.candleStickChart class]]) {
        if (0 == self.segBottomChartType.selectedSegmentIndex) {
            self.stickChart.displayFrom = from;
            self.stickChart.displayNumber = number;
            [self.stickChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        } else if (1 == self.segBottomChartType.selectedSegmentIndex) {
            self.macdChart.displayFrom = from;
            self.macdChart.displayNumber = number;
            [self.macdChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        } else if (2 == self.segBottomChartType.selectedSegmentIndex) {
            self.kdjChart.displayFrom = from;
            self.kdjChart.displayNumber = number;
            [self.kdjChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        } else if (3 == self.segBottomChartType.selectedSegmentIndex) {
            self.rsiChart.displayFrom = from;
            self.rsiChart.displayNumber = number;
            [self.rsiChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        } else if (4 == self.segBottomChartType.selectedSegmentIndex) {
            self.wrChart.displayFrom = from;
            self.wrChart.displayNumber = number;
            [self.wrChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        } else if (5 == self.segBottomChartType.selectedSegmentIndex) {
            self.cciChart.displayFrom = from;
            self.cciChart.displayNumber = number;
            [self.cciChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        } else if (6 == self.segBottomChartType.selectedSegmentIndex) {
            self.bollChart.displayFrom = from;
            self.bollChart.displayNumber = number;
            [self.bollChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        }
        
    }else{
        self.candleStickChart.displayFrom = from;
        self.candleStickChart.displayNumber = number;
        [self.candleStickChart performSelector:@selector(setNeedsDisplay) withObject:nil];
    }
}

/*******************************************************************************
* Public Methods
*******************************************************************************/

- (void)setGroupChartData:(CCSGroupChartData *) groupChartData{
    _groupChartData = groupChartData;
    
    _needsReload = YES;
    [self setNeedsLayout];
}

- (void)setChartData:(NSMutableArray *)chartData{
    _chartData = chartData;
    
    _needsReload = YES;
    [self setNeedsLayout];
}

- (void)setChartDelegate:(UIViewController<CCSChartDelegate> *)chartDelegate{
    _chartDelegate = chartDelegate;
}

- (void)setChartsBackgroundColor:(UIColor *)backgroundColor{
    _chartsBackgroundColor = backgroundColor;
}

- (void)setButtonTextColor: (UIColor *)normalColor selectedColor: (UIColor *)selectedColor{
    _buttonNormalTextColor = normalColor;
    _buttonSelectedTextColor = selectedColor;
}

- (void)updateCandleStickChart{
    [self initCandleStickChartData];
}

- (void)updateStickChart{
    [self initStickChartData];
}

- (void)updateMACDChart{
    [self initMACDChartData];
}

- (void)updateKDJChart{
    [self initKDJChartData];
}

- (void)updateRSIChart{
    [self initRSIChartData];
}

- (void)updateWRChart{
    [self initWRChartData];
}

- (void)updateCCIChart{
    [self initCCIChartData];
}

- (void)updateBOLLChart{
    [self initBOLLChartData];
}

- (void)refreshGroupChart{
    _needsRefresh = YES;
    [self setNeedsLayout];
}

/*******************************************************************************
* Private Methods
*******************************************************************************/

- (void)initControllers {
    [self setBackgroundColor:_chartsBackgroundColor];
    
    // 横屏
    if (self.orientationType == GroupChartHorizontalType) {
        UISegmentedControl *segBottomChartType = [[UISegmentedControl alloc] initWithItems:@[@"VOL", @"MACD", @"KDJ", @"RSI", @"WR", @"CCI", @"BOLL", @""]];
        segBottomChartType.frame = CGRectMake(_contentSize.width - _contentSize.width/HORIZONTAL_LEFT_RIGHT_SCALE - (_contentSize.height - _contentSize.width/HORIZONTAL_LEFT_RIGHT_SCALE)/2.0f, (_contentSize.height - _contentSize.width/HORIZONTAL_LEFT_RIGHT_SCALE)/2.0f,  _contentSize.height, _contentSize.width/HORIZONTAL_LEFT_RIGHT_SCALE);
        [segBottomChartType addTarget:self action:@selector(segBottomChartTypeTypeValueChaged:) forControlEvents:UIControlEventValueChanged];
        [segBottomChartType setSelectedSegmentIndex:0];
        // 设置颜色
        segBottomChartType.tintColor = _chartsBackgroundColor;
        [segBottomChartType setBackgroundColor:_chartsBackgroundColor];
        NSDictionary* selectedTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13.0f],
                                                 NSForegroundColorAttributeName: _buttonSelectedTextColor};
        [segBottomChartType setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];//设置文字属性
        NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13.0f],
                                                   NSForegroundColorAttributeName: _buttonNormalTextColor};
        [segBottomChartType setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
        // 旋转90度
        [segBottomChartType setTransform:CGAffineTransformMakeRotation(90 *M_PI / 180.0)];
        // UISegmentedControl每个item 旋转 270 度
        for (UIView *subview in [segBottomChartType subviews]) {
            [subview setTransform:CGAffineTransformMakeRotation(270 *M_PI / 180.0)];
        }
        
        self.segBottomChartType = segBottomChartType;
        
        [self addSubview:segBottomChartType];
        
        UIButton *btnChartHorizontal = [[UIButton alloc] init];
        [btnChartHorizontal setFrame:CGRectMake(_contentSize.width - _contentSize.width/HORIZONTAL_LEFT_RIGHT_SCALE , _contentSize.height - _contentSize.height/8.0f, _contentSize.width/HORIZONTAL_LEFT_RIGHT_SCALE, _contentSize.height/8.0f)];
        [btnChartHorizontal.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [btnChartHorizontal setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [btnChartHorizontal setTitle:@"设置" forState:UIControlStateNormal];
        [btnChartHorizontal addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnChartHorizontal];
    }else{
        NSArray *arraySegItems = @[@"VOL", @"MACD", @"KDJ", @"RSI", @"WR", @"CCI", @"BOLL"];
        
        UISegmentedControl *segBottomChartType = [[UISegmentedControl alloc] initWithItems: arraySegItems];
        segBottomChartType.frame = CGRectMake(0.0f, _contentSize.height - 34.0f,  _contentSize.width - 50.0f, 33.0f);
        [segBottomChartType addTarget:self action:@selector(segBottomChartTypeTypeValueChaged:) forControlEvents:UIControlEventValueChanged];
        [segBottomChartType setSelectedSegmentIndex:0];
        // 设置颜色
        segBottomChartType.tintColor = _chartsBackgroundColor;
        [segBottomChartType setBackgroundColor:_chartsBackgroundColor];
        NSDictionary* selectedTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:11.0f],
                                                 NSForegroundColorAttributeName: _buttonSelectedTextColor};
        [segBottomChartType setTitleTextAttributes:selectedTextAttributes forState:UIControlStateSelected];//设置文字属性
        NSDictionary* unselectedTextAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:11.0f],
                                                   NSForegroundColorAttributeName: _buttonNormalTextColor};
        [segBottomChartType setTitleTextAttributes:unselectedTextAttributes forState:UIControlStateNormal];
        
        self.segBottomChartType = segBottomChartType;
        
        [self addSubview:segBottomChartType];
        
        UIButton *btnSetting = [[UIButton alloc] init];
        [btnSetting setFrame:CGRectMake(segBottomChartType.frame.size.width, segBottomChartType.frame.origin.y, _contentSize.width - segBottomChartType.frame.size.width, segBottomChartType.frame.size.height)];
        [btnSetting.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
        [btnSetting setTitleColor:_buttonNormalTextColor forState:UIControlStateNormal];
        [btnSetting setTitle:@"设置" forState:UIControlStateNormal];
        [btnSetting addTarget:self action:@selector(setting:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btnSetting];
        
        _vSelected = [[UIView alloc] init];
        [_vSelected setFrame:CGRectMake(0.0f, segBottomChartType.frame.origin.y + segBottomChartType.frame.size.height - 3.0f, segBottomChartType.frame.size.width/[arraySegItems count], 1.0f)];
        [_vSelected setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:_vSelected];
    }
    
    UIScrollView *scrollViewBottomChart = [[UIScrollView alloc] init];
    
    if (self.orientationType == GroupChartHorizontalType) {
        scrollViewBottomChart.frame = CGRectMake(0.0f, _contentSize.height/3.0f*2 - 1.0f, _contentSize.width - _contentSize.width/HORIZONTAL_LEFT_RIGHT_SCALE,  _contentSize.height/3.0f);
    }else{
        scrollViewBottomChart.frame = CGRectMake(0.0f, (_contentSize.height - 33.0f)/3.0f*2 - 1.0f, _contentSize.width,  (_contentSize.height - 33.0f)/3.0f);
    }
    
    scrollViewBottomChart.bounces = NO;
    scrollViewBottomChart.contentSize = CGSizeMake(_contentSize.width * 6, (_contentSize.height - 33.0f)/3.0f);
    scrollViewBottomChart.pagingEnabled = YES;
    scrollViewBottomChart.delegate = self;
    [scrollViewBottomChart setScrollEnabled:NO];
    
    // 设置单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [scrollViewBottomChart addGestureRecognizer:tap];

    self.scrollViewBottomChart = scrollViewBottomChart;
    [self addSubview:scrollViewBottomChart];
}

- (void)initCandleStickChart {
    CCSBOLLMASlipCandleStickChart *candleStickChart = nil;
    
    if (self.orientationType == GroupChartHorizontalType) {
        candleStickChart = [[CCSBOLLMASlipCandleStickChart alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _contentSize.width - _contentSize.width/HORIZONTAL_LEFT_RIGHT_SCALE, _contentSize.height/3.0f * 2.0f)];
    }else{
        candleStickChart = [[CCSBOLLMASlipCandleStickChart alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _contentSize.width, (_contentSize.height - 33.0f)/3.0f * 2.0f)];
    }
    
    self.candleStickChart = candleStickChart;
    [self initCandleStickChartData];
    
    //设置stickData
    candleStickChart.maxValue = 340;
    candleStickChart.minValue = 240;
    candleStickChart.axisCalc = 1;
    candleStickChart.displayLongitudeTitle = YES;
    candleStickChart.displayLatitudeTitle  = YES;
    candleStickChart.userInteractionEnabled = YES;
    
//    candleStickChart.positiveStickBorderColor = [@"#ED4D4D" str2Color];
//    candleStickChart.negativeStickFillColor = [@"#52BA27" str2Color];
    candleStickChart.positiveStickBorderColor = LINE_COLORS[0];
    candleStickChart.positiveStickFillColor = LINE_COLORS[0];
    candleStickChart.negativeStickBorderColor = LINE_COLORS[1];
    candleStickChart.negativeStickFillColor = LINE_COLORS[1];
    
//    candleStickChart.candleStickStyle = GroupCandleStickChartTypeBar;
//    candleStickChart.axisYPosition = CCSGridChartYAxisPositionRight;
//    candleStickChart.displayNumber = 50;
//    candleStickChart.displayFrom = 0;
    candleStickChart.bollingerBandStyle = CCSBollingerBandStyleNone;
    candleStickChart.axisCalc = AXIS_CALC_PARM;
    candleStickChart.latitudeNum = 3;
    // 缩小到一定程度变线
    candleStickChart.widthForStickDrawAsLine = 2;
    candleStickChart.colorForStickDrawAsLine = [UIColor lightGrayColor];
    // 边框颜色
    candleStickChart.displayLongitudeTitle = YES;
    candleStickChart.axisMarginBottom = 15.0f;
    
    candleStickChart.chartDelegate = self.chartDelegate;
    
    self.candleStickChart.backgroundColor = _chartsBackgroundColor;
    
    [candleStickChart addTarget:self action:@selector(candleStickChartTouch:) forControlEvents:UIControlEventAllTouchEvents];
    
    [self addSubview:candleStickChart];
    
    UIView *vOhlcContainer = [[UIView alloc] init];
    [vOhlcContainer setFrame:CGRectMake(0.0f, 0.0f, candleStickChart.frame.size.width, 30.0f)];
    [vOhlcContainer setBackgroundColor:[UIColor clearColor]];
    [self addSubview:vOhlcContainer];
    
    UILabel *lblOpenLabel = [[UILabel alloc] init];
    [lblOpenLabel setFrame:CGRectMake(0.0f, 8.0f, 15.0f, vOhlcContainer.frame.size.height)];
    [lblOpenLabel setTextColor:[UIColor lightGrayColor]];
    [lblOpenLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [lblOpenLabel setText:@"开:"];
    [vOhlcContainer addSubview:lblOpenLabel];
    UILabel *lblOpen = [[UILabel alloc] init];
    [lblOpen setFrame:CGRectMake(lblOpenLabel.frame.size.width+3.0f, 8.0f, 35.0f, vOhlcContainer.frame.size.height)];
    [lblOpen setTextColor:[UIColor lightGrayColor]];
    [lblOpen setFont:[UIFont systemFontOfSize:11.0f]];
    [lblOpen setText:@"0.0"];
    [vOhlcContainer addSubview:lblOpen];
    _lblOpen = lblOpen;
    
    UILabel *lblCloseLabel = [[UILabel alloc] init];
    [lblCloseLabel setFrame:CGRectMake(lblOpen.frame.origin.x + lblOpen.frame.size.width, 8.0f, lblOpenLabel.frame.size.width, vOhlcContainer.frame.size.height)];
    [lblCloseLabel setTextColor:[UIColor lightGrayColor]];
    [lblCloseLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [lblCloseLabel setText:@"收:"];
    [vOhlcContainer addSubview:lblCloseLabel];
    UILabel *lblClose = [[UILabel alloc] init];
    [lblClose setFrame:CGRectMake(lblCloseLabel.frame.origin.x + lblCloseLabel.frame.size.width, 8.0f, lblOpen.frame.size.width, vOhlcContainer.frame.size.height)];
    [lblClose setTextColor:[UIColor lightGrayColor]];
    [lblClose setFont:[UIFont systemFontOfSize:11.0f]];
    [lblClose setText:@"0.0"];
    [vOhlcContainer addSubview:lblClose];
    _lblClose = lblClose;
    
    UILabel *lblHighLabel = [[UILabel alloc] init];
    [lblHighLabel setFrame:CGRectMake(lblClose.frame.origin.x + lblClose.frame.size.width, 8.0f, lblOpenLabel.frame.size.width, vOhlcContainer.frame.size.height)];
    [lblHighLabel setTextColor:[UIColor lightGrayColor]];
    [lblHighLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [lblHighLabel setText:@"高:"];
    [vOhlcContainer addSubview:lblHighLabel];
    UILabel *lblHigh = [[UILabel alloc] init];
    [lblHigh setFrame:CGRectMake(lblHighLabel.frame.origin.x + lblHighLabel.frame.size.width, 8.0f, lblOpen.frame.size.width, vOhlcContainer.frame.size.height)];
    [lblHigh setTextColor:[UIColor lightGrayColor]];
    [lblHigh setFont:[UIFont systemFontOfSize:11.0f]];
    [lblHigh setText:@"0.0"];
    [vOhlcContainer addSubview:lblHigh];
    _lblHigh = lblHigh;
    
    UILabel *lblLowLabel = [[UILabel alloc] init];
    [lblLowLabel setFrame:CGRectMake(lblHigh.frame.origin.x + lblHigh.frame.size.width, 8.0f, lblOpenLabel.frame.size.width, vOhlcContainer.frame.size.height)];
    [lblLowLabel setTextColor:[UIColor lightGrayColor]];
    [lblLowLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [lblLowLabel setText:@"低:"];
    [vOhlcContainer addSubview:lblLowLabel];
    UILabel *lblLow = [[UILabel alloc] init];
    [lblLow setFrame:CGRectMake(lblLowLabel.frame.origin.x + lblLowLabel.frame.size.width, 8.0f, lblOpen.frame.size.width, vOhlcContainer.frame.size.height)];
    [lblLow setTextColor:[UIColor lightGrayColor]];
    [lblLow setFont:[UIFont systemFontOfSize:11.0f]];
    [lblLow setText:@"0.0"];
    [vOhlcContainer addSubview:lblLow];
    _lblLow = lblLow;
}

- (void)initCandleStickChartData {
    if (self.groupChartData) {
        self.candleStickChart.stickData = self.groupChartData.candleStickData;
        self.candleStickChart.linesData = self.groupChartData.candleStickLinesData;
        self.candleStickChart.bollingerBandData = self.groupChartData.candleStickBollingerBandData;
        
//        self.candleStickChart.singleTouchPoint = CGPointMake(-1, -1);
        
        [self.candleStickChart setNeedsDisplay];
        
        return;
    }
    
    if (self.chartData != NULL) {
        NSMutableArray *stickDatas = [[NSMutableArray alloc] initWithCapacity:[self.chartData count]];
        
        for (NSInteger i = [self.chartData count] - 1; i >= 0; i--) {
            CCSOHLCVDData *item = [self.chartData objectAtIndex:i];
            CCSCandleStickChartData *stickData = [[CCSCandleStickChartData alloc] init];
//            stickData.open = [item.open doubleValue];
//            stickData.high = [item.high doubleValue];
//            stickData.low = [item.low doubleValue];
//            stickData.close = [item.close doubleValue];
            stickData.open = item.open;
            stickData.high = item.high;
            stickData.low = item.low;
            stickData.close = item.close;
            stickData.change = 0;
            stickData.date = [item.date dateWithFormat:@"yyyy-MM-dd HH:mm:ss" target:@"yy-MM-dd"];
            // 增加数据
            [stickDatas addObject:stickData];
        }
        NSMutableArray *maLines = [[NSMutableArray alloc] init];
        [maLines addObject: [self.chartData computeMAData:5]];
        [maLines addObject: [self.chartData computeMAData:25]];
        
        self.candleStickChart.stickData = stickDatas;
        self.candleStickChart.linesData = maLines;
        self.candleStickChart.bollingerBandData = [self.chartData computeBOLLData:20 optInNbDevUp:2 optInNbDevDn:2];
        
        self.candleStickChart.singleTouchPoint = CGPointMake(-1, -1);
        
        [self.candleStickChart setNeedsDisplay];
    }
}

- (void)initStickChart {
    CCSMAColoredStickChart *stickchart = [[CCSMAColoredStickChart alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.scrollViewBottomChart.frame.size.width, self.scrollViewBottomChart.frame.size.height)];
    stickchart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.stickChart = stickchart;
    
    //初始化数据
    [self initStickChartData];
    
    //设置stickData
    self.stickChart.maxValue = 800000;
    self.stickChart.minValue = 0;
    self.stickChart.stickFillColor = [UIColor colorWithRed:0.7 green:0.7 blue:0 alpha:0.8];
    
//    self.stickChart.displayNumber = 50;
//    self.stickChart.displayFrom = 0;
    self.stickChart.displayLongitudeTitle = NO;
    self.stickChart.axisMarginBottom = 3;
    // 缩小到一定程度变线
    self.stickChart.widthForStickDrawAsLine = 2;
    self.stickChart.colorForStickDrawAsLine = [UIColor lightGrayColor];
    self.stickChart.chartDelegate = self.chartDelegate;
    self.stickChart.backgroundColor = _chartsBackgroundColor;
    
    [self.stickChart addTarget:self action:@selector(candleStickChartTouch:) forControlEvents:UIControlEventAllTouchEvents];
    
    [self.scrollViewBottomChart addSubview:self.stickChart];
    
    UIView *vVOLContainer = [[UIView alloc] init];
    [vVOLContainer setBackgroundColor:[UIColor clearColor]];
    [self.stickChart addSubview:vVOLContainer];
    // 添加约束
    [vVOLContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [vVOLContainer addLeadingConstraint:0.0f];
    [vVOLContainer addTopConstraint:5.0f];
    [vVOLContainer addWidthAndHeightConstraint:self.stickChart.frame.size.width height:30.0f];
    
    UILabel *lblVOLLabel = [[UILabel alloc] init];
    [vVOLContainer addSubview:lblVOLLabel];
    
    [lblVOLLabel setTextColor:[UIColor lightGrayColor]];
    [lblVOLLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [lblVOLLabel setText:@"VOL:"];
    
    // 添加约束
    [lblVOLLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblVOLLabel addLeadingConstraint:0.0f];
    [lblVOLLabel addCenterYConstraint:0.0f];
    
    CGFloat left = 3.0f;
    
    UILabel *lblVOL = [[UILabel alloc] init];
    [vVOLContainer addSubview:lblVOL];
    [lblVOL setTextColor:LINE_COLORS[0]];
    [lblVOL setFont:[UIFont systemFontOfSize:11.0f]];
    [lblVOL setText:@"0.00"];
    
    // 添加约束
    [lblVOL setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblVOL addLeadingOutConstraintWithOtherView:lblVOLLabel leading:left];
    [lblVOL addCenterYConstraint:0.0f];
    
    _lblVOL = lblVOL;
}

- (void)initStickChartData {
    if (self.groupChartData) {
        self.stickChart.stickData = self.groupChartData.stickData;
        self.stickChart.linesData = self.groupChartData.stickMAData;
//        self.stickChart.singleTouchPoint = CGPointMake(-1, -1);
        
        [self.stickChart setNeedsDisplay];
        
        return;
    }
    
    if (self.chartData != NULL) {
        NSMutableArray *stickDatas = [[NSMutableArray alloc] initWithCapacity:[self.chartData count]];
        
        for (NSInteger i = [self.chartData count] - 1; i >= 0; i--) {
            CCSOHLCVDData *item = [self.chartData objectAtIndex:i];
            CCSColoredStickChartData *stickData = [[CCSColoredStickChartData alloc] init];
//            stickData.high = [item.vol doubleValue];
            stickData.high = item.vol;
            stickData.low = 0;
            stickData.date = [item.date dateWithFormat:@"yyyy-MM-dd HH:mm:ss" target:@"yy-MM-dd"];
            
//            if ([item.close doubleValue] > [item.open doubleValue]) {
//                stickData.fillColor = [UIColor clearColor];
//                stickData.borderColor = [UIColor redColor];
//            } else if ([item.close doubleValue] < [item.open doubleValue]) {
//                stickData.fillColor = [UIColor greenColor];
//                stickData.borderColor = [UIColor clearColor];
//            } else {
//                stickData.fillColor = [UIColor lightGrayColor];
//                stickData.borderColor = [UIColor clearColor];
//            }
            if (item.close > item.open) {
                stickData.fillColor = [UIColor clearColor];
                stickData.borderColor = [UIColor redColor];
            } else if (item.close < item.open) {
                stickData.fillColor = [UIColor greenColor];
                stickData.borderColor = [UIColor clearColor];
            } else {
                stickData.fillColor = [UIColor lightGrayColor];
                stickData.borderColor = [UIColor clearColor];
            }
            //增加数据
            [stickDatas addObject:stickData];
        }
        
        self.stickChart.stickData = stickDatas;
        self.stickChart.singleTouchPoint = CGPointMake(-1, -1);
        
        [self.stickChart setNeedsDisplay];
    }
}

- (void)initMACDChart {
    CCSMACDChart *macdchart = [[CCSMACDChart alloc] initWithFrame:CGRectMake(self.scrollViewBottomChart.frame.size.width, 0, self.scrollViewBottomChart.frame.size.width, self.scrollViewBottomChart.frame.size.height)];
    macdchart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.macdChart = macdchart;
    
    //初始化数据
    [self initMACDChartData];
    
    //设置stickData
    self.macdChart.stickFillColor = [UIColor colorWithRed:0.7 green:0.7 blue:0 alpha:0.8];
    self.macdChart.positiveStickStrokeColor = [@"#ED4D4D" str2Color];
    self.macdChart.positiveStickFillColor = [@"#ED4D4D" str2Color];
    self.macdChart.negativeStickStrokeColor = [@"#52BA27" str2Color];
    self.macdChart.negativeStickFillColor = [@"#52BA27" str2Color];
    
//    self.macdChart.maxValue = 300000;
//    self.macdChart.minValue = -300000;
//    self.macdChart.maxSticksNum = 100;
//    self.macdChart.macdDisplayType = CCSMACDChartDisplayTypeStick;
//    self.macdChart.positiveStickColor = [UIColor redColor];
//    self.macdChart.negativeStickColor = [UIColor greenColor];
    self.macdChart.macdLineColor = LINE_COLORS[0];
    self.macdChart.deaLineColor = LINE_COLORS[1];
    self.macdChart.diffLineColor = LINE_COLORS[2];
//    self.macdChart.displayNumber = 50;
//    self.macdChart.displayFrom = 0;
    self.macdChart.axisCalc = AXIS_CALC_PARM;
    self.macdChart.displayLongitudeTitle = NO;
    self.macdChart.axisMarginBottom = 3;
    
    self.macdChart.chartDelegate = self.chartDelegate;
    self.macdChart.backgroundColor = _chartsBackgroundColor;
    
    [self.macdChart addTarget:self action:@selector(candleStickChartTouch:) forControlEvents:UIControlEventAllTouchEvents];
    
    [self.scrollViewBottomChart addSubview:self.macdChart];
    
    UIView *vMACDContainer = [[UIView alloc] init];
    [vMACDContainer setBackgroundColor:[UIColor clearColor]];
    [self.macdChart addSubview:vMACDContainer];
    // 添加约束
    [vMACDContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [vMACDContainer addLeadingConstraint:0.0f];
    [vMACDContainer addTopConstraint:5.0f];
    [vMACDContainer addWidthAndHeightConstraint:self.macdChart.frame.size.width height:30.0f];
    
    UILabel *lblMACDLabel = [[UILabel alloc] init];
    [vMACDContainer addSubview:lblMACDLabel];
    
    [lblMACDLabel setTextColor:[UIColor lightGrayColor]];
    [lblMACDLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [lblMACDLabel setText:@"MACD(9,12,26):"];
    
    // 添加约束
    [lblMACDLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblMACDLabel addLeadingConstraint:0.0f];
    [lblMACDLabel addCenterYConstraint:0.0f];
    
    _lblMACDLabel = lblMACDLabel;
    
    CGFloat left = 3.0f;
    
    UILabel *lblMACD = [[UILabel alloc] init];
    [vMACDContainer addSubview:lblMACD];
    [lblMACD setTextColor:LINE_COLORS[0]];
    [lblMACD setFont:[UIFont systemFontOfSize:11.0f]];
    [lblMACD setText:@"-0.00"];
    
    // 添加约束
    [lblMACD setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblMACD addLeadingOutConstraintWithOtherView:lblMACDLabel leading:left];
    [lblMACD addCenterYConstraint:0.0f];
    
    _lblMACD = lblMACD;
    
    UILabel *lblDIF = [[UILabel alloc] init];
    [vMACDContainer addSubview:lblDIF];
    [lblDIF setTextColor:LINE_COLORS[1]];
    [lblDIF setFont:[UIFont systemFontOfSize:11.0f]];
    [lblDIF setText:@"DIF:-0.00"];
    
    // 添加约束
    [lblDIF setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblDIF addLeadingOutConstraintWithOtherView:lblMACD leading:left];
    [lblDIF addCenterYConstraint:0.0f];

    _lblDIF = lblDIF;
    
    UILabel *lblDEA = [[UILabel alloc] init];
    [vMACDContainer addSubview:lblDEA];
    
    [lblDEA setTextColor:LINE_COLORS[2]];
    [lblDEA setFont:[UIFont systemFontOfSize:11.0f]];
    [lblDEA setText:@"DEA:-0.00"];
    
    // 添加约束
    [lblDEA setTranslatesAutoresizingMaskIntoConstraints:NO];
    [lblDEA addLeadingOutConstraintWithOtherView:lblDIF leading:left];
    [lblDEA addCenterYConstraint:0.0f];

    _lblDEA = lblDEA;
}

- (void)initMACDChartData {
    if (self.groupChartData) {
        self.macdChart.stickData = self.groupChartData.macdStickData;
        
        [self.macdChart setNeedsDisplay];
        
        return;
    }
    
    if (self.chartData != NULL) {
//        NSMutableArray *stickDatas = [[NSMutableArray alloc] initWithCapacity:[self.chartData count]];
//        for (NSInteger i = [self.chartData count] - 1; i >= 0; i--) {
//            OHLCVDGroupData *item = [self.chartData objectAtIndex:i];
//            CCSCandleStickChartData *stickData = [[CCSCandleStickChartData alloc] init];
//            stickData.open = [item.open doubleValue];
//            stickData.high = [item.high doubleValue];
//            stickData.low = [item.low doubleValue];
//            stickData.close = [item.close doubleValue];
//            stickData.change = 0;
//            stickData.date = [item.date dateWithFormat:@"yyyy-MM-ddHH:mm:ss" target:@"yy-MM-dd"];
//            //增加数据
//            [stickDatas addObject:stickData];
//        }
        
        self.macdChart.stickData = [self.chartData computeMACDData:12 optInSlowPeriod:26 optInSignalPeriod:9];
//        self.macdChart.singleTouchPoint = CGPointMake(-1, -1);
        
        [self.macdChart setNeedsDisplay];
    }
}

- (void)initKDJChart {
    CCSSlipLineChart *kdjchart = [[CCSSlipLineChart alloc] initWithFrame:CGRectMake(self.scrollViewBottomChart.frame.size.width * 2, 0, self.scrollViewBottomChart.frame.size.width, self.scrollViewBottomChart.frame.size.height)];
    kdjchart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.kdjChart = kdjchart;
    
    //初始化数据
    [self initKDJChartData];
    
    //设置stickData
//    self.kdjChart.displayNumber = 50;
//    self.kdjChart.displayFrom = 0;
    self.kdjChart.latitudeNum = 2;
    self.kdjChart.displayLongitudeTitle = NO;
    self.kdjChart.axisMarginBottom = 3;
    
    self.kdjChart.autoCalcRange = NO;
    self.kdjChart.maxValue = 120;
    self.kdjChart.minValue = -20;
    
    self.kdjChart.chartDelegate = self.chartDelegate;
    self.kdjChart.backgroundColor = _chartsBackgroundColor;
    
    [self.kdjChart addTarget:self action:@selector(candleStickChartTouch:) forControlEvents:UIControlEventAllTouchEvents];
    
    [self.scrollViewBottomChart addSubview:self.kdjChart];
    
    UIView *vKDJContainer = [[UIView alloc] init];
    [vKDJContainer setBackgroundColor:[UIColor clearColor]];
    [self.kdjChart addSubview:vKDJContainer];
    // 添加约束
    [vKDJContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [vKDJContainer addLeadingConstraint:0.0f];
    [vKDJContainer addTopConstraint:5.0f];
    [vKDJContainer addWidthAndHeightConstraint:self.macdChart.frame.size.width height:30.0f];
    
    UILabel *lblKDJLabel = [[UILabel alloc] init];
    [vKDJContainer addSubview:lblKDJLabel];
    
    [lblKDJLabel setTextColor:[UIColor lightGrayColor]];
    [lblKDJLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [lblKDJLabel setText:@"KDJ(9,3,3):"];
    
    // 添加约束
    [lblKDJLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblKDJLabel addLeadingConstraint:0.0f];
    [lblKDJLabel addCenterYConstraint:0.0f];
    
    _lblKDJLabel = lblKDJLabel;
    
    CGFloat left = 3.0f;
    
    UILabel *lblK = [[UILabel alloc] init];
    [vKDJContainer addSubview:lblK];
    [lblK setTextColor:LINE_COLORS[0]];
    [lblK setFont:[UIFont systemFontOfSize:11.0f]];
    [lblK setText:@"K:0.00"];
    
    // 添加约束
    [lblK setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblK addLeadingOutConstraintWithOtherView:lblKDJLabel leading:left];
    [lblK addCenterYConstraint:0.0f];
    
    _lblK = lblK;
    
    UILabel *lblD = [[UILabel alloc] init];
    [vKDJContainer addSubview:lblD];
    [lblD setTextColor:LINE_COLORS[1]];
    [lblD setFont:[UIFont systemFontOfSize:11.0f]];
    [lblD setText:@"D:0.00"];
    
    // 添加约束
    [lblD setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblD addLeadingOutConstraintWithOtherView:lblK leading:left];
    [lblD addCenterYConstraint:0.0f];
    
    _lblD = lblD;
    
    UILabel *lblJ = [[UILabel alloc] init];
    [vKDJContainer addSubview:lblJ];
    
    [lblJ setTextColor:LINE_COLORS[2]];
    [lblJ setFont:[UIFont systemFontOfSize:11.0f]];
    [lblJ setText:@"J:0.00"];
    
    // 添加约束
    [lblJ setTranslatesAutoresizingMaskIntoConstraints:NO];
    [lblJ addLeadingOutConstraintWithOtherView:lblD leading:left];
    [lblJ addCenterYConstraint:0.0f];
    _lblJ = lblJ;
}

- (void)initKDJChartData {
    if (self.groupChartData) {
        self.kdjChart.linesData = self.groupChartData.kdjLinesData;
//        self.kdjChart.singleTouchPoint = CGPointMake(-1, -1);
        
        self.kdjChart.maxValue = 120;
        self.kdjChart.minValue = -20;
        
        [self.kdjChart setNeedsDisplay];
        
        return;
    }
    
    if (self.chartData != NULL) {
        
        self.kdjChart.linesData = [self.chartData computeKDJData:9 optInSlowK_Period:3 optInSlowD_Period:3];
        self.kdjChart.singleTouchPoint = CGPointMake(-1, -1);
        
        self.kdjChart.maxValue = 120;
        self.kdjChart.minValue = -20;
        
        [self.kdjChart setNeedsDisplay];
    }
}

- (void)initRSIChart {
    CCSSlipLineChart *rsiChart = [[CCSSlipLineChart alloc] initWithFrame:CGRectMake(self.scrollViewBottomChart.frame.size.width * 3, 0, self.scrollViewBottomChart.frame.size.width, self.scrollViewBottomChart.frame.size.height)];
    rsiChart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.rsiChart = rsiChart;
    
    //初始化数据
    [self initRSIChartData];
    
    //设置stickData
//    self.rsiChart.displayNumber = 50;
//    self.rsiChart.displayFrom = 0;
    self.rsiChart.displayLongitudeTitle = NO;
    self.rsiChart.axisMarginBottom = 3;
    
    self.rsiChart.autoCalcRange = NO;
    self.rsiChart.maxValue = 100;
    self.rsiChart.minValue = 0;
    
    self.rsiChart.chartDelegate = self.chartDelegate;
    self.rsiChart.backgroundColor = _chartsBackgroundColor;
    
    [self.rsiChart addTarget:self action:@selector(candleStickChartTouch:) forControlEvents:UIControlEventAllTouchEvents];
    
    [self.scrollViewBottomChart addSubview:self.rsiChart];
    
    UIView *vRSIContainer = [[UIView alloc] init];
    [vRSIContainer setBackgroundColor:[UIColor clearColor]];
    [self.rsiChart addSubview:vRSIContainer];
    // 添加约束
    [vRSIContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [vRSIContainer addLeadingConstraint:0.0f];
    [vRSIContainer addTopConstraint:5.0f];
    [vRSIContainer addWidthAndHeightConstraint:self.macdChart.frame.size.width height:30.0f];
    
    CGFloat left = 3.0f;
    
    UILabel *lblR = [[UILabel alloc] init];
    [vRSIContainer addSubview:lblR];
    [lblR setTextColor:LINE_COLORS[0]];
    [lblR setFont:[UIFont systemFontOfSize:11.0f]];
    [lblR setText:@"RSI6:0.00"];
    
    // 添加约束
    [lblR setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblR addLeadingConstraint:0.0f];
    [lblR addCenterYConstraint:0.0f];
    
    _lblR = lblR;
    
    UILabel *lblS = [[UILabel alloc] init];
    [vRSIContainer addSubview:lblS];
    [lblS setTextColor:LINE_COLORS[1]];
    [lblS setFont:[UIFont systemFontOfSize:11.0f]];
    [lblS setText:@"RSI12:0.00"];
    
    // 添加约束
    [lblS setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblS addLeadingOutConstraintWithOtherView:lblR leading:left];
    [lblS addCenterYConstraint:0.0f];
    
    _lblS = lblS;
    
    UILabel *lblI = [[UILabel alloc] init];
    [vRSIContainer addSubview:lblI];
    
    [lblI setTextColor:LINE_COLORS[2]];
    [lblI setFont:[UIFont systemFontOfSize:11.0f]];
    [lblI setText:@"RSI24:0.00"];
    
    // 添加约束
    [lblI setTranslatesAutoresizingMaskIntoConstraints:NO];
    [lblI addLeadingOutConstraintWithOtherView:lblS leading:left];
    [lblI addCenterYConstraint:0.0f];
    _lblI = lblI;
}

- (void)initRSIChartData {
    if (self.groupChartData) {
        self.rsiChart.linesData = self.groupChartData.rsiLinesData;
//        self.rsiChart.singleTouchPoint = CGPointMake(-1, -1);
        
        self.rsiChart.maxValue = 100;
        self.rsiChart.minValue = 0;
        
        [self.rsiChart setNeedsDisplay];
        
        return;
    }
    
    if (self.chartData != NULL) {
        
        NSMutableArray *linesData = [[NSMutableArray alloc] init];
        [linesData addObject:[self.chartData computeRSIData:6]];
        [linesData addObject:[self.chartData computeRSIData:12]];
        [linesData addObject:[self.chartData computeRSIData:24]];
        
        self.rsiChart.linesData = linesData;
        self.rsiChart.singleTouchPoint = CGPointMake(-1, -1);
        
        self.rsiChart.maxValue = 100;
        self.rsiChart.minValue = 0;
        
        [self.rsiChart setNeedsDisplay];
    }
}

- (void)initWRChart {
    CCSSlipLineChart *wrChart = [[CCSSlipLineChart alloc] initWithFrame:CGRectMake(self.scrollViewBottomChart.frame.size.width * 4, 0, self.scrollViewBottomChart.frame.size.width, self.scrollViewBottomChart.frame.size.height)];
    wrChart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.wrChart = wrChart;
    
    //初始化数据
    [self initWRChartData];
    
    //设置stickData
//    self.wrChart.displayNumber = 50;
//    self.wrChart.displayFrom = 0;
    self.wrChart.noneDisplayValues = [NSMutableArray arrayWithObjects:WR_NONE_DISPLAY,nil];
    self.wrChart.displayLongitudeTitle = NO;
    self.wrChart.axisMarginBottom = 3;
    
    self.wrChart.autoCalcRange = NO;
    self.wrChart.maxValue = 100;
    self.wrChart.minValue = 0;
    
    self.wrChart.chartDelegate = self.chartDelegate;
    self.wrChart.backgroundColor = _chartsBackgroundColor;
    // self.wrChart.noneDisplayValue = 9999;
    
    [self.wrChart addTarget:self action:@selector(candleStickChartTouch:) forControlEvents:UIControlEventAllTouchEvents];
    
    [self.scrollViewBottomChart addSubview:self.wrChart];
    
    UIView *vWRContainer = [[UIView alloc] init];
    [vWRContainer setBackgroundColor:[UIColor clearColor]];
    [self.wrChart addSubview:vWRContainer];
    // 添加约束
    [vWRContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [vWRContainer addLeadingConstraint:0.0f];
    [vWRContainer addTopConstraint:5.0f];
    [vWRContainer addWidthAndHeightConstraint:self.macdChart.frame.size.width height:30.0f];
    
    UILabel *lblWRLabel = [[UILabel alloc] init];
    [vWRContainer addSubview:lblWRLabel];
    
    [lblWRLabel setTextColor:[UIColor lightGrayColor]];
    [lblWRLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [lblWRLabel setText:@"WR(10):"];
    
    // 添加约束
    [lblWRLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblWRLabel addLeadingConstraint:0.0f];
    [lblWRLabel addCenterYConstraint:0.0f];
    
    _lblWRLabel = lblWRLabel;

    CGFloat left = 3.0f;
    
    UILabel *lblWR = [[UILabel alloc] init];
    [vWRContainer addSubview:lblWR];
    [lblWR setTextColor:LINE_COLORS[0]];
    [lblWR setFont:[UIFont systemFontOfSize:11.0f]];
    [lblWR setText:@"0.00"];
    
    // 添加约束
    [lblWR setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblWR addLeadingOutConstraintWithOtherView:lblWRLabel leading:left];
    [lblWR addCenterYConstraint:0.0f];
    
    _lblWR = lblWR;
}

- (void)initWRChartData {
    if (self.groupChartData) {
        self.wrChart.linesData = self.groupChartData.wrLinesData;
//        self.wrChart.singleTouchPoint = CGPointMake(-1, -1);
        
        self.wrChart.maxValue = 0;
        self.wrChart.minValue = -100;
        
        [self.wrChart setNeedsDisplay];
        
        return;
    }
    
    if (self.chartData != NULL) {
        self.wrChart.linesData = [self.chartData computeWRData:6];
        self.wrChart.singleTouchPoint = CGPointMake(-1, -1);
        
        self.wrChart.maxValue = 100;
        self.wrChart.minValue = 0;
        
        [self.wrChart setNeedsDisplay];
    }
}

- (void)initCCIChart {
    CCSSlipLineChart *cciChart = [[CCSSlipLineChart alloc] initWithFrame:CGRectMake(self.scrollViewBottomChart.frame.size.width * 5, 0, self.scrollViewBottomChart.frame.size.width, self.scrollViewBottomChart.frame.size.height)];
    cciChart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.cciChart = cciChart;
    
    //初始化数据
    [self initCCIChartData];
    
    //设置stickData
//    self.cciChart.displayNumber = 50;
//    self.cciChart.displayFrom = 0;
    self.cciChart.displayLongitudeTitle = NO;
    self.cciChart.axisMarginBottom = 3;
    
    self.cciChart.chartDelegate = self.chartDelegate;
    self.cciChart.backgroundColor = _chartsBackgroundColor;
    
    [self.cciChart addTarget:self action:@selector(candleStickChartTouch:) forControlEvents:UIControlEventAllTouchEvents];
    
    [self.scrollViewBottomChart addSubview:self.cciChart];
    
    UIView *vCCIContainer = [[UIView alloc] init];
    [vCCIContainer setBackgroundColor:[UIColor clearColor]];
    [self.cciChart addSubview:vCCIContainer];
    // 添加约束
    [vCCIContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [vCCIContainer addLeadingConstraint:0.0f];
    [vCCIContainer addTopConstraint:5.0f];
    [vCCIContainer addWidthAndHeightConstraint:self.macdChart.frame.size.width height:30.0f];
    
    UILabel *lblCCILabel = [[UILabel alloc] init];
    [vCCIContainer addSubview:lblCCILabel];
    
    [lblCCILabel setTextColor:[UIColor lightGrayColor]];
    [lblCCILabel setFont:[UIFont systemFontOfSize:11.0f]];
    [lblCCILabel setText:@"CCI(14):"];
    
    // 添加约束
    [lblCCILabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblCCILabel addLeadingConstraint:0.0f];
    [lblCCILabel addCenterYConstraint:0.0f];
    
    _lblCCILabel = lblCCILabel;
    
    CGFloat left = 3.0f;
    
    UILabel *lblCCI = [[UILabel alloc] init];
    [vCCIContainer addSubview:lblCCI];
    [lblCCI setTextColor:LINE_COLORS[0]];
    [lblCCI setFont:[UIFont systemFontOfSize:11.0f]];
    [lblCCI setText:@"0.00"];
    
    // 添加约束
    [lblCCI setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblCCI addLeadingOutConstraintWithOtherView:lblCCILabel leading:left];
    [lblCCI addCenterYConstraint:0.0f];
    
    _lblCCI = lblCCI;
}

- (void)initCCIChartData {
    if (self.groupChartData) {
        self.cciChart.linesData = self.groupChartData.cciLinesData;
//        self.cciChart.singleTouchPoint = CGPointMake(-1, -1);
        
        [self.cciChart setNeedsDisplay];
        
        return;
    }
    
    if (self.chartData != NULL) {
        
        self.cciChart.linesData = [self.chartData computeCCIData:14];
        self.cciChart.singleTouchPoint = CGPointMake(-1, -1);
        
        [self.cciChart setNeedsDisplay];
    }
}

- (void)initBOLLChart {
    CCSSlipLineChart *bollChart = [[CCSSlipLineChart alloc] initWithFrame:CGRectMake(self.scrollViewBottomChart.frame.size.width * 6, 0, self.scrollViewBottomChart.frame.size.width, self.scrollViewBottomChart.frame.size.height)];
    bollChart.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.bollChart = bollChart;
    
    //初始化数据
    [self initBOLLChartData];
    
    //设置stickData
//    self.bollChart.displayNumber = 50;
//    self.bollChart.displayFrom = 0;
    self.bollChart.displayLongitudeTitle = NO;
    self.bollChart.axisMarginBottom = 3;
    
    self.bollChart.chartDelegate = self.chartDelegate;
    self.bollChart.backgroundColor = _chartsBackgroundColor;
    self.bollChart.axisCalc = AXIS_CALC_PARM;
    
    [self.bollChart addTarget:self action:@selector(candleStickChartTouch:) forControlEvents:UIControlEventAllTouchEvents];
    
    [self.scrollViewBottomChart addSubview:self.bollChart];
    
    UIView *vBOLLContainer = [[UIView alloc] init];
    [vBOLLContainer setBackgroundColor:[UIColor clearColor]];
    [self.bollChart addSubview:vBOLLContainer];
    // 添加约束
    [vBOLLContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [vBOLLContainer addLeadingConstraint:0.0f];
    [vBOLLContainer addTopConstraint:5.0f];
    [vBOLLContainer addWidthAndHeightConstraint:self.macdChart.frame.size.width height:30.0f];
    
    UILabel *lblBOLLLabel = [[UILabel alloc] init];
    [vBOLLContainer addSubview:lblBOLLLabel];
    
    [lblBOLLLabel setTextColor:[UIColor lightGrayColor]];
    [lblBOLLLabel setFont:[UIFont systemFontOfSize:11.0f]];
    [lblBOLLLabel setText:@"BOLL(20,2,2):"];
    
    // 添加约束
    [lblBOLLLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblBOLLLabel addLeadingConstraint:0.0f];
    [lblBOLLLabel addCenterYConstraint:0.0f];
    
    _lblBOLLLabel = lblBOLLLabel;
    
    CGFloat left = 3.0f;
    
    UILabel *lblB = [[UILabel alloc] init];
    [vBOLLContainer addSubview:lblB];
    [lblB setTextColor:LINE_COLORS[0]];
    [lblB setFont:[UIFont systemFontOfSize:11.0f]];
    [lblB setText:@"0.00"];
    
    // 添加约束
    [lblB setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblB addLeadingOutConstraintWithOtherView:lblBOLLLabel leading:left];
    [lblB addCenterYConstraint:0.0f];
    
    _lblB = lblB;
    
    UILabel *lblO = [[UILabel alloc] init];
    [vBOLLContainer addSubview:lblO];
    [lblO setTextColor:LINE_COLORS[1]];
    [lblO setFont:[UIFont systemFontOfSize:11.0f]];
    [lblO setText:@"0.00"];
    
    // 添加约束
    [lblO setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [lblO addLeadingOutConstraintWithOtherView:lblB leading:left];
    [lblO addCenterYConstraint:0.0f];
    
    _lblO = lblO;
    
    UILabel *lblL = [[UILabel alloc] init];
    [vBOLLContainer addSubview:lblL];
    
    [lblL setTextColor:LINE_COLORS[2]];
    [lblL setFont:[UIFont systemFontOfSize:11.0f]];
    [lblL setText:@"0.00"];
    
    // 添加约束
    [lblL setTranslatesAutoresizingMaskIntoConstraints:NO];
    [lblL addLeadingOutConstraintWithOtherView:lblO leading:left];
    [lblL addCenterYConstraint:0.0f];
    
    _lblL = lblL;
}

- (void)initBOLLChartData {
    if (self.groupChartData) {
        self.bollChart.linesData = self.groupChartData.bollLinesData;
//        self.bollChart.singleTouchPoint = CGPointMake(-1, -1);
        
        [self.bollChart setNeedsDisplay];
        
        return;
    }
    
    if (self.chartData != NULL) {
        self.bollChart.linesData = [self.chartData computeBOLLData:20 optInNbDevUp:2 optInNbDevDn:2];
        self.bollChart.singleTouchPoint = CGPointMake(-1, -1);
        
        [self.bollChart setNeedsDisplay];
    }
}

- (void)candleStickChartTouch:(id)sender {
    NSUInteger i = 0;
    
    if ([sender isKindOfClass:[CCSStickChart class]]) {
        CCSStickChart *stickChart = sender;
        i = stickChart.selectedStickIndex;
    }else{
        CCSSlipLineChart *lineChart = sender;
        i = lineChart.selectedIndex;
    }
    
    if (self.candleStickChart.stickData && [self.candleStickChart.stickData count] > 0) {
        CCSCandleStickChartData *ohlc = [self.candleStickChart.stickData objectAtIndex:i];
        CCSCandleStickChartData *lastohlc;
        //第一根k线时，处理前日比
        if (i == 0) {
            lastohlc = [[CCSCandleStickChartData alloc] initWithOpen:0 high:0 low:0 close:ohlc.close - ohlc.change date:@""];
        } else {
            lastohlc = [self.candleStickChart.stickData objectAtIndex:i - 1];
        }
        
        //设置标签值
        _lblOpen.text = [[[NSString stringWithFormat:@"%f", ohlc.open/1000] decimal:0] zero];
        _lblHigh.text = [[[NSString stringWithFormat:@"%f", ohlc.high/1000] decimal:0] zero];
        _lblLow.text = [[[NSString stringWithFormat:@"%f", ohlc.low/1000] decimal:0] zero];
        _lblClose.text = [[[NSString stringWithFormat:@"%f", ohlc.close/1000] decimal:0] zero];
        
//        self.lblChange.text = [NSString stringWithFormat:@"%@(%@%%)",
//                               [[NSString stringWithFormat:@"%f", ohlc.change] decimalWithSign:2],
//                               [[NSString stringWithFormat:@"%f", ohlc.change * 100 / lastohlc.close] decimalWithSign:2]];
        
//        self.lblPreClose.text = [NSString stringWithFormat:@"前日終値:%@", [[[NSString stringWithFormat:@"%f", lastohlc.close] decimal:2] zero]];
//        
//        self.lblDate.text = ohlc.date;
        
        //设置标签文本颜色
        if (ohlc.open == 0) {
            _lblOpen.textColor = [UIColor lightGrayColor];
        } else {
            //设置标签文本颜色
            _lblOpen.textColor = ohlc.open != lastohlc.close ? ohlc.open > lastohlc.close ? LINE_COLORS[0] : LINE_COLORS[1] : [UIColor lightGrayColor];
        }
        
        if (ohlc.high == 0) {
            _lblHigh.textColor = [UIColor lightGrayColor];
        } else {
            //设置标签文本颜色
            _lblHigh.textColor = ohlc.high != lastohlc.close ? ohlc.high > lastohlc.close ? LINE_COLORS[0] : LINE_COLORS[1] : [UIColor lightGrayColor];
        }
        
        if (ohlc.low == 0) {
            _lblLow.textColor = [UIColor lightGrayColor];
        } else {
            _lblLow.textColor = ohlc.low != lastohlc.close ? ohlc.low > lastohlc.close ? LINE_COLORS[0] : LINE_COLORS[1] : [UIColor lightGrayColor];
        }
        
        if (ohlc.close == 0) {
            _lblClose.textColor = [UIColor lightGrayColor];
        } else {
            _lblClose.textColor = ohlc.close != lastohlc.close ? ohlc.close > lastohlc.close ? LINE_COLORS[0] : LINE_COLORS[1] : [UIColor lightGrayColor];
        }
        
//        if (ohlc.change == 0) {
//            _lblChange.textColor = [UIColor lightGrayColor];
//        } else {
//            self.lblChange.textColor = ohlc.close != lastohlc.close ? ohlc.close > lastohlc.close ? LINE_COLORS[0] : LINE_COLORS[1] : [UIColor lightGrayColor];
//        }
    }
    
    if (self.stickChart.stickData && [self.stickChart.stickData count] > 0) {
        //成交量
        _lblVOL.text = [[[NSString stringWithFormat:@"%f", ((CCSStickChartData *) [self.stickChart.stickData objectAtIndex:i]).high] decimal] zero];
    }
    
    if (self.candleStickChart.linesData && [self.candleStickChart.linesData count] > 0) {
        //均线数据
//        CCSTitledLine *ma5 = [self.candleStickChart.linesData objectAtIndex:0];
//        CCSTitledLine *ma10 = [self.candleStickChart.linesData objectAtIndex:1];
        
        //MA5
//        if (ma5 && ma5.data && [ma5.data count] > 0) {
//            if (((CCSLineData *) [ma5.data objectAtIndex:i]).value != 0) {
//                self.lblSubTitle1.text = [NSString stringWithFormat:@"%@: %@", ma5.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [ma5.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
//            } else {
//                self.lblSubTitle1.text = @"";
//            }
//            self.lblSubTitle1.textColor = ma5.color;
//        }
//        
//        //MA10
//        if (ma10 && ma10.data && [ma10.data count] > 0) {
//            if (((CCSLineData *) [ma10.data objectAtIndex:i]).value != 0) {
//                self.lblSubTitle2.text = [NSString stringWithFormat:@"%@: %@", ma10.title, [[[NSString stringWithFormat:@"%f", ((CCSLineData *) [ma10.data objectAtIndex:i]).value / self.candleStickChart.axisCalc] decimal:2] zeroIsBlank]];
//            } else {
//                self.lblSubTitle2.text = @"";
//            }
//            self.lblSubTitle2.textColor = ma10.color;
//        }
        
        if (GroupChartViewTypeVOL == self.bottomChartType) {
//            if (self.stickChart.stickData && [self.stickChart.stickData count] > 0) {
//                self.lblSubTitle6.text = [NSString stringWithFormat:@"VOL: %@", self.lblVolume.text];
//            }
            
        } else if (GroupChartViewTypeMACD == self.bottomChartType) {
            if (self.macdChart.stickData && [self.macdChart.stickData count] > 0) {
                
                CCSMACDData *macdData = nil;
                @try {
                    macdData = self.groupChartData.macdStickData[i];
                }
                @catch (NSException *exception) {
                }
                if (macdData) {
                    [_lblMACD setText: [[NSString stringWithFormat:@"%f", macdData.macd] decimal:2]];
                    [_lblDIF setText: [[[NSString stringWithFormat:@"%f", macdData.diff] decimal:2] concate:@"DIF:"]];
                    [_lblDEA setText: [[[NSString stringWithFormat:@"%f", macdData.dea] decimal:2] concate:@"DEA:"]];
                }else{
                    [_lblMACD setText:@"-0.00"];
                    [_lblDIF setText:@" DIF:-0.00"];
                    [_lblDEA setText:@" DEA:-0.00"];
                }
            }
        } else if (GroupChartViewTypeKDJ == self.bottomChartType) {
            NSMutableArray *kdjData = [[NSMutableArray alloc] init];
            [self.groupChartData.kdjLinesData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CCSTitledLine *line = self.groupChartData.kdjLinesData[idx];
                CCSLineData *lineData = line.data[i];
                NSString *kdj = [[NSString stringWithFormat:@"%f", lineData.value] decimal:2];
                [kdjData addObject:kdj];
            }];
            if (kdjData && [kdjData count] == 3) {
                [_lblK setText: [kdjData[0] concate:@"K:"]];
                [_lblD setText: [kdjData[1] concate:@"D:"]];
                [_lblJ setText: [kdjData[2] concate:@"J:"]];
            }else{
                [_lblK setText: [@"0.00" concate:@"K:"]];
                [_lblD setText: [@"0.00" concate:@"D:"]];
                [_lblJ setText: [@"0.00" concate:@"J:"]];
            }
        } else if (GroupChartViewTypeRSI == self.bottomChartType) {
            NSString *rsiN1 = [RSI_N1 getUserDefaultString];
            NSString *rsiN2 = [RSI_N2 getUserDefaultString];
            
            NSMutableArray *rsiData = [[NSMutableArray alloc] init];
            [self.groupChartData.rsiLinesData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CCSTitledLine *line = self.groupChartData.rsiLinesData[idx];
                CCSLineData *lineData = line.data[i];
                NSString *rsi = [[NSString stringWithFormat:@"%f", lineData.value] decimal:2];
                [rsiData addObject:rsi];
            }];
            if (rsiData && [rsiData count] == 3) {
                [_lblR setText: [NSString stringWithFormat:@"RSI%@:%@", rsiN1,rsiData[0]]];
                [_lblS setText: [NSString stringWithFormat:@"RSI%@:%@", rsiN2,rsiData[1]]];
                [_lblI setText: [NSString stringWithFormat:@"RSI%@:%@", @"24",rsiData[2]]];
            }else{
                [_lblR setText: [NSString stringWithFormat:@"RSI%@:%@", rsiN1,@"0.00"]];
                [_lblS setText: [NSString stringWithFormat:@"RSI%@:%@", rsiN2,@"0.00"]];
                [_lblI setText: [NSString stringWithFormat:@"RSI%@:%@", @"24",@"0.00"]];
            }
        } else if (GroupChartViewTypeWR == self.bottomChartType) {
            NSString *wrN = [WR_N getUserDefaultString];
            if (self.groupChartData.wrLinesData && [self.groupChartData.wrLinesData count] > 0) {
                CCSTitledLine *wrLine = self.groupChartData.wrLinesData[0];
                CCSLineData *wrLineData = wrLine.data[i];
                NSString *wr = [[NSString stringWithFormat:@"%f", wrLineData.value] decimal:2];
                
                [_lblWRLabel setText:[NSString stringWithFormat:@"WR(%@):", wrN]];
                [_lblWR setText:wr];
            }else{
                [_lblWRLabel setText:[NSString stringWithFormat:@"WR(%@):", wrN]];
                [_lblWR setText:@"0.00"];
            }
        } else if (GroupChartViewTypeCCI == self.bottomChartType) {
            NSString *cciN = [CCI_N getUserDefaultString];
            if (self.groupChartData.cciLinesData && [self.groupChartData.cciLinesData count] > 0) {
                CCSTitledLine *cciLine = self.groupChartData.cciLinesData[0];
                CCSLineData *cciLineData = cciLine.data[i];
                NSString *cci = [[NSString stringWithFormat:@"%f", cciLineData.value] decimal:2];
                
                [_lblCCILabel setText:[NSString stringWithFormat:@"CCI(%@):", cciN]];
                [_lblCCI setText:cci];
            }else{
                [_lblCCILabel setText:[NSString stringWithFormat:@"CCI(%@):", cciN]];
                [_lblCCI setText:@"0.00"];
            }
        } else if (GroupChartViewTypeBOLL == self.bottomChartType) {
            NSString *bollN = [BOLL_N getUserDefaultString];
            
            [_lblBOLLLabel setText:[NSString stringWithFormat:@"BOLL(%@,2,2):", bollN]];
            
            NSMutableArray *bollData = [[NSMutableArray alloc] init];
            [self.groupChartData.bollLinesData enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CCSTitledLine *line = self.groupChartData.bollLinesData[idx];
                CCSLineData *lineData = line.data[i];
                NSString *boll = [[NSString stringWithFormat:@"%f", lineData.value/1000] decimal:2];
                [bollData addObject:boll];
            }];
            if (bollData && [bollData count] == 3) {
                [_lblB setText: bollData[0]];
                [_lblO setText: bollData[1]];
                [_lblL setText: bollData[2]];
            }else{
                [_lblB setText: @"0.00"];
                [_lblO setText: @"0.00"];
                [_lblL setText: @"0.00"];
            }
        }
    }
    
    //成交量图设置线条
    //[self.stickChart setSelectedPointAddReDraw:self.candleStickChart.singleTouchPoint];
    
}

#pragma mark 单击手势
-(void)handleTap:(UITapGestureRecognizer*)sender
{
    if (self.segBottomChartType.selectedSegmentIndex == 6) {
        self.segBottomChartType.selectedSegmentIndex = 0;
    }else{
        self.segBottomChartType.selectedSegmentIndex = self.segBottomChartType.selectedSegmentIndex + 1;
    }
    
    [self segBottomChartTypeTypeValueChaged:self.segBottomChartType];
}

- (void)segBottomChartTypeTypeValueChaged:(UISegmentedControl *)segmentedControl {
    // 得到每页宽度
    CGFloat pageWidth = self.scrollViewBottomChart.frame.size.width;
    // 根据当前的x坐标和页宽度计算出当前页数
    int page = (int) floor((self.scrollViewBottomChart.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (segmentedControl.selectedSegmentIndex != page) {
        //滚动相应的距离
        self.scrollViewBottomChart.contentOffset = CGPointMake(pageWidth * segmentedControl.selectedSegmentIndex, self.scrollViewBottomChart.contentOffset.y);
    }
    
    self.candleStickChart.bollingerBandStyle = CCSBollingerBandStyleNone;
    
    CGFloat selectedViewX = 0.0f;
    
    if (0 == self.segBottomChartType.selectedSegmentIndex) {
        self.stickChart.displayFrom = self.candleStickChart.displayFrom;
        self.stickChart.displayNumber = self.candleStickChart.displayNumber;
        [self.stickChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        self.bottomChartType = GroupChartViewTypeVOL;
        
        selectedViewX = 0.0f;
    } else if (1 == self.segBottomChartType.selectedSegmentIndex) {
        self.macdChart.displayFrom = self.candleStickChart.displayFrom;;
        self.macdChart.displayNumber = self.candleStickChart.displayNumber;
        [self.macdChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        self.bottomChartType = GroupChartViewTypeMACD;
        
        selectedViewX = (_contentSize.width - 50.0f)/7.0f;
    } else if (2 == self.segBottomChartType.selectedSegmentIndex) {
        self.kdjChart.displayFrom = self.candleStickChart.displayFrom;;
        self.kdjChart.displayNumber = self.candleStickChart.displayNumber;
        [self.kdjChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        self.bottomChartType = GroupChartViewTypeKDJ;
        
        selectedViewX = (_contentSize.width - 50.0f)/7.0f*2;
    } else if (3 == self.segBottomChartType.selectedSegmentIndex) {
        self.rsiChart.displayFrom = self.candleStickChart.displayFrom;;
        self.rsiChart.displayNumber = self.candleStickChart.displayNumber;
        [self.rsiChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        self.bottomChartType = GroupChartViewTypeRSI;
        
        selectedViewX = (_contentSize.width - 50.0f)/7.0f*3;
    } else if (4 == self.segBottomChartType.selectedSegmentIndex) {
        self.wrChart.displayFrom = self.candleStickChart.displayFrom;;
        self.wrChart.displayNumber = self.candleStickChart.displayNumber;
        [self.wrChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        self.bottomChartType = GroupChartViewTypeWR;
        
        selectedViewX = (_contentSize.width - 50.0f)/7.0f*4;
    } else if (5 == self.segBottomChartType.selectedSegmentIndex) {
        self.cciChart.displayFrom = self.candleStickChart.displayFrom;;
        self.cciChart.displayNumber = self.candleStickChart.displayNumber;
        [self.cciChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        self.bottomChartType = GroupChartViewTypeCCI;
        
        selectedViewX = (_contentSize.width - 50.0f)/7.0f*5;
    } else if (6 == self.segBottomChartType.selectedSegmentIndex) {
        self.bollChart.displayFrom = self.candleStickChart.displayFrom;;
        self.bollChart.displayNumber = self.candleStickChart.displayNumber;
        [self.bollChart performSelector:@selector(setNeedsDisplay) withObject:nil];
        
        self.candleStickChart.bollingerBandStyle = CCSBollingerBandStyleBand;
        self.bottomChartType = GroupChartViewTypeBOLL;
        
        selectedViewX = (_contentSize.width - 50.0f)/7.0f*6;
    }
    
    [self moveSelectedView:selectedViewX];
    
    [self.candleStickChart performSelector:@selector(setNeedsDisplay) withObject:nil];
}

- (void)setting:(UIButton *) sender{
    if (self.setting) {
        self.setting();
    }
}

- (void)moveSelectedView:(CGFloat)x{
    [UIView animateWithDuration:0.2f animations:^{
        [_vSelected setFrame:CGRectMake(x, _vSelected.frame.origin.y, _vSelected.frame.size.width, _vSelected.frame.size.height)];
    }];
}

/*******************************************************************************
* Unused Codes
*******************************************************************************/

@end
