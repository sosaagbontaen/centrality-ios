//
//  UsageDashboardViewController.m
//  CentralityiOS
//
//  Created by Samuel Osa-Agbontaen on 8/11/22.
//

#import "UsageDashboardViewController.h"
#import "Parse/Parse.h"
#import "SceneDelegate.h"
#import "Charts-Swift.h"
#import "FSCalendar.h"

@interface UsageDashboardViewController ()<ChartViewDelegate>
@property (weak, nonatomic) IBOutlet PieChartView *pieChart;
@property (nonatomic, strong) IBOutlet UISlider *sliderX;
@property (nonatomic, strong) IBOutlet UISlider *sliderY;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextX;
@property (nonatomic, strong) IBOutlet UITextField *sliderTextY;
@property (nonatomic, assign) BOOL shouldHideData;
@end

@implementation UsageDashboardViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.title = @"Pie Chart";

    self.options = @[
                     @{@"key": @"toggleValues", @"label": @"Toggle Y-Values"},
                     @{@"key": @"toggleXValues", @"label": @"Toggle X-Values"},
                     @{@"key": @"togglePercent", @"label": @"Toggle Percent"},
                     @{@"key": @"toggleHole", @"label": @"Toggle Hole"},
                     @{@"key": @"toggleIcons", @"label": @"Toggle Icons"},
                     @{@"key": @"toggleLabelsMinimumAngle", @"label": @"Toggle Labels Minimum Angle"},
                     @{@"key": @"animateX", @"label": @"Animate X"},
                     @{@"key": @"animateY", @"label": @"Animate Y"},
                     @{@"key": @"animateXY", @"label": @"Animate XY"},
                     @{@"key": @"spin", @"label": @"Spin"},
                     @{@"key": @"drawCenter", @"label": @"Draw CenterText"},
                     @{@"key": @"saveToGallery", @"label": @"Save to Camera Roll"},
                     @{@"key": @"toggleData", @"label": @"Toggle Data"},
                     ];

    [self setupPieChartView:self.pieChart];
    self.pieChart.delegate = self;
    ChartLegend *l = self.pieChart.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentRight;
    l.verticalAlignment = ChartLegendVerticalAlignmentTop;
    l.orientation = ChartLegendOrientationVertical;
    l.drawInside = NO;
    l.xEntrySpace = 7.0;
    l.yEntrySpace = 0.0;
    l.yOffset = 0.0;

    // entry label styling
    self.pieChart.entryLabelColor = UIColor.blackColor;
    self.pieChart.entryLabelFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];

    self.sliderX.value = 4.0;
    self.sliderY.value = 100.0;
    [self slidersValueChanged:nil];

    [self.pieChart animateWithXAxisDuration:1.4 easingOption:ChartEasingOptionEaseOutBack];
}

- (void)setupPieChartView:(PieChartView *)chartView
{
    chartView.usePercentValuesEnabled = YES;
    chartView.drawSlicesUnderHoleEnabled = NO;
    chartView.holeRadiusPercent = 0.58;
    chartView.transparentCircleRadiusPercent = 0.61;
    chartView.chartDescription.enabled = NO;
    [chartView setExtraOffsetsWithLeft:5.f top:10.f right:5.f bottom:5.f];

    chartView.drawCenterTextEnabled = YES;

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:@"Tasks Completed"];
    [centerText setAttributes:@{
                                NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:13.f],
                                NSParagraphStyleAttributeName: paragraphStyle
                                } range:NSMakeRange(0, centerText.length)];
    chartView.centerAttributedText = centerText;

    chartView.drawHoleEnabled = YES;
    chartView.rotationAngle = 0.0;
    chartView.rotationEnabled = YES;
    chartView.highlightPerTapEnabled = YES;

    ChartLegend *l = chartView.legend;
    l.horizontalAlignment = ChartLegendHorizontalAlignmentRight;
    l.verticalAlignment = ChartLegendVerticalAlignmentTop;
    l.orientation = ChartLegendOrientationVertical;
    l.drawInside = NO;
    l.xEntrySpace = 7.0;
    l.yEntrySpace = 0.0;
    l.yOffset = 0.0;
}

- (void)updateChartData
{
    if (self.shouldHideData)
    {
        self.pieChart.data = nil;
        return;
    }

    [self setDataCount:self.sliderX.value range:self.sliderY.value];
}

- (IBAction)slidersValueChanged:(id)sender
{
    self.sliderTextX.text = [@((int)_sliderX.value) stringValue];
    self.sliderTextY.text = [@((int)_sliderY.value) stringValue];

    [self updateChartData];
}

- (void)setDataCount:(int)count range:(double)range
{
    double mult = range;

    NSMutableArray *values = [[NSMutableArray alloc] init];

    for (int i = 0; i < count; i++)
    {
        [values addObject:[[PieChartDataEntry alloc] initWithValue:(arc4random_uniform(mult) + mult / 5) label:parties[i % parties.count] icon: [UIImage imageNamed:@"icon"]]];
    }

    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithEntries:values label:@"Completed Tasks"];

    dataSet.drawIconsEnabled = NO;

    dataSet.sliceSpace = 2.0;
    dataSet.iconsOffset = CGPointMake(0, 40);

    // add a lot of colors

    NSMutableArray *colors = [[NSMutableArray alloc] init];
    [colors addObjectsFromArray:ChartColorTemplates.vordiplom];
    [colors addObjectsFromArray:ChartColorTemplates.joyful];
    [colors addObjectsFromArray:ChartColorTemplates.colorful];
    [colors addObjectsFromArray:ChartColorTemplates.liberty];
    [colors addObjectsFromArray:ChartColorTemplates.pastel];
    [colors addObject:[UIColor colorWithRed:51/255.f green:181/255.f blue:229/255.f alpha:1.f]];

    dataSet.colors = colors;

    PieChartData *data = [[PieChartData alloc] initWithDataSet:dataSet];

    NSNumberFormatter *pFormatter = [[NSNumberFormatter alloc] init];
    pFormatter.numberStyle = NSNumberFormatterPercentStyle;
    pFormatter.maximumFractionDigits = 1;
    pFormatter.multiplier = @1.f;
    pFormatter.percentSymbol = @" %";
    [data setValueFormatter:[[ChartDefaultValueFormatter alloc] initWithFormatter:pFormatter]];
    [data setValueFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:11.f]];
    [data setValueTextColor:UIColor.blackColor];

    self.pieChart.data = data;
    [self.pieChart highlightValues:nil];
}

- (void)chartValueSelected:(ChartViewBase * __nonnull)chartView entry:(ChartDataEntry * __nonnull)entry highlight:(ChartHighlight * __nonnull)highlight
{
    NSLog(@"chartValueSelected");
}

- (void)chartValueNothingSelected:(ChartViewBase * __nonnull)chartView
{
    NSLog(@"chartValueNothingSelected");
}

@end
