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
#import "CentralityHelpers.h"
#import "TaskObject.h"

@interface UsageDashboardViewController ()<ChartViewDelegate>
@property (weak, nonatomic) IBOutlet PieChartView *pieChart;
@property NSMutableArray<CategoryObject*>* userCategories;
@property (nonatomic, assign) BOOL shouldHideData;

@end

NSTimer* refreshTimer;

@implementation UsageDashboardViewController

- (void)updateCounters{
    NSMutableSet<NSString*>* setOfCollaborators = [[NSMutableSet alloc] init];
    [[CentralityHelpers queryForUsersCompletedTasks] countObjectsInBackgroundWithBlock:^(int numOfCompletedTasks, NSError * _Nullable error) {
        [self transitionLabel:self.completedTasksCounter newText:[@(numOfCompletedTasks) stringValue]];
        
        [[CentralityHelpers queryForTasksRoughDueByDate] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable tasksDueRoughlyToday, NSError * _Nullable error) {
            int numOftasksDueExactlyToday = 0;
            for (TaskObject* task in tasksDueRoughlyToday){
                if ([task.dueDate isSameDay:NSDate.date]){
                    numOftasksDueExactlyToday++;
                    [setOfCollaborators addObjectsFromArray:[CentralityHelpers getArrayOfObjectIds:task.sharedOwners]];
                    [setOfCollaborators removeObject:PFUser.currentUser.objectId];
                }
            }
            [self transitionLabel:self.dueTasksCounter newText:[@(numOftasksDueExactlyToday) stringValue]];
            [self transitionLabel:self.collaboratorsCounter newText:[@(setOfCollaborators.count) stringValue]];
            NSString* completionRateString = [NSString stringWithFormat:@"%@%%",[@(((float)numOfCompletedTasks/(float)numOftasksDueExactlyToday) * 100) stringValue]];
            [self transitionLabel:self.completionRateCounter newText:completionRateString];
        }];
        
    }];
    
}

- (void)transitionLabel :(UILabel*)label newText:(NSString*)newText{
    [UILabel transitionWithView:label
                       duration:0.25f
                        options:UIViewAnimationOptionTransitionCrossDissolve
                     animations:^{
        label.text = newText;
    } completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCounters) userInfo:nil repeats:YES];
    
    
    self.title = @"Pie Chart";
    
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
    
    [[CentralityHelpers queryForUsersCategories] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable categoriesFromQuery, NSError * _Nullable error) {
        self.userCategories = [categoriesFromQuery mutableCopy];
        [self updateChartData];
    }];
    
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
    
    NSMutableAttributedString *centerText = [[NSMutableAttributedString alloc] initWithString:@"Tasks\nby Category"];
    [centerText setAttributes:@{
        NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f],
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
    
    [self setDataCount:self.userCategories.count range:1];
}

- (void)setDataCount:(NSUInteger)count range:(double)range
{
    double mult = range;
    
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++)
    {
        [values addObject:[[PieChartDataEntry alloc] initWithValue:(arc4random_uniform(mult) + mult / 5) label:self.userCategories[i % self.userCategories.count].categoryName icon: [UIImage imageNamed:@"icon"]]];
    }
    
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithEntries:values label:@"Tasks by Category"];
    
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
