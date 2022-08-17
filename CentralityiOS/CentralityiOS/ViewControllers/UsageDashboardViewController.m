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

@implementation UsageDashboardViewController

- (void)updateCounters{
    NSMutableSet<NSString*>* setOfCollaborators = [[NSMutableSet alloc] init];
    [[CentralityHelpers queryForUsersCompletedTasks] countObjectsInBackgroundWithBlock:^(int numOfCompletedTasks, NSError * _Nullable error) {
        [CentralityHelpers transitionLabel:self.completedTasksCounter newText:[@(numOfCompletedTasks) stringValue]];
        
        [[CentralityHelpers queryForTasksRoughDueByDate] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable tasksDueRoughlyToday, NSError * _Nullable error) {
            int numOftasksDueExactlyToday = 0;
            for (TaskObject* task in tasksDueRoughlyToday){
                if ([task.dueDate isSameDay:NSDate.date]){
                    numOftasksDueExactlyToday++;
                    [setOfCollaborators addObjectsFromArray:[CentralityHelpers getArrayOfObjectIds:task.sharedOwners]];
                    [setOfCollaborators removeObject:PFUser.currentUser.objectId];
                }
            }
            [CentralityHelpers transitionLabel:self.dueTasksCounter newText:[@(numOftasksDueExactlyToday) stringValue]];
            [CentralityHelpers transitionLabel:self.collaboratorsCounter newText:[@(setOfCollaborators.count) stringValue]];
            NSString* completionRateString = [NSString stringWithFormat:@"%@%%",[@(((float)numOfCompletedTasks/(float)numOftasksDueExactlyToday) * 100) stringValue]];
            [CentralityHelpers transitionLabel:self.completionRateCounter newText:completionRateString];
            [self loadChartWithCategories];
        }];
        
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateCounters) userInfo:nil repeats:YES];
    
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
    
    
    
    [self.pieChart animateWithXAxisDuration:1.4 easingOption:ChartEasingOptionEaseOutBack];
}

- (void)loadChartWithCategories{
    [[CentralityHelpers queryForUsersCategories] findObjectsInBackgroundWithBlock:^(NSArray * _Nullable categoriesFromQuery, NSError * _Nullable error) {
        self.userCategories = [categoriesFromQuery mutableCopy];
        [self updateChartData];
    }];
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
    
    [self setDataCount:self.userCategories.count];
}

- (void)setDataCount:(NSUInteger)count
{
    NSMutableArray *values = [[NSMutableArray alloc] init];
    for (int i = 0; i < count; i++)
    {
        CategoryObject* currentCategory = self.userCategories[i];
        [values addObject:[[PieChartDataEntry alloc] initWithValue:currentCategory.numberOfTasksInCategory label:currentCategory.categoryName icon: [UIImage imageNamed:@"icon"]]];
    }
    
    PieChartDataSet *dataSet = [[PieChartDataSet alloc] initWithEntries:values label:@"Tasks by Category"];
    
    dataSet.drawIconsEnabled = NO;
    
    dataSet.sliceSpace = 2.0;
    dataSet.iconsOffset = CGPointMake(0, 40);
    
    // Category Colors can be customized here
    
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
    [data setValueFont:[UIFont fontWithName:@"Arial" size:11.f]];
    [data setValueTextColor:UIColor.blackColor];
    
    self.pieChart.data = data;
    [self.pieChart highlightValues:nil];
}
@end
