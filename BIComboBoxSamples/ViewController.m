//
//  ViewController.m
//  BIComboBoxSamples
//
//  Created by Renaud Buisine on 14/03/16.
//
//

#import "ViewController.h"
#import <TPKeyboardAvoidingScrollView.h>

@interface ViewController (){
    NSArray *_titles;
    __weak IBOutlet BIComboBox *_titlesComboBox;
    __weak IBOutlet TPKeyboardAvoidingScrollView *_formScrollView;
}

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _titlesComboBox.delegate = self;
    _titlesComboBox.dataSource = self;
    _titles = @[@"Mr",@"Miss",@"Mrs",@"Mr or Miss",@"Bro",@"Pet",@"God",@"..."];
    
    // add observers to scrollview => TPKeyboardAvoiding
    [[NSNotificationCenter defaultCenter] addObserver:_formScrollView selector:@selector(TPKeyboardAvoiding_keyboardWillShow:) name:BIComboBoxWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:_formScrollView selector:@selector(TPKeyboardAvoiding_keyboardWillHide:) name:BIComboBoxWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:_formScrollView selector:@selector(scrollToActiveTextField) name:BIComboBoxWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didChangeValue:(id)sender {
    NSLog(@"DID CHANGE, OH FUCK YEAH !!! EVENT HAS BEEN RAISED !!!");
}

#pragma mark BIComboBoxDatasourse/BIComboBoxDelegate

/**
 *  When a row is selected for combobox
 *
 *  @param comboBox Concerned combobox
 *  @param row      Index of selected row
 */
- (void)comboBox:(BIComboBox *)comboBox didSelectRow:(NSInteger)row{
    NSLog(@"ITEM SELECTED : %ld",(long)row);
}
/**
 *  Request for title for row
 *
 *  @param comboBox Concerned combobox
 *  @param row      Index of row
 *
 *  @return Title for row
 */
- (NSString *)comboBox:(BIComboBox *)comboBox titleForRow:(NSInteger)row{
    return [_titles objectAtIndex:row];
}
/**
 *  Request view for row of comboBox
 *
 *  @param comboBox Concerned comboBox
 *  @param row      Index of row
 *  @param view     View which could be reused
 *
 *  @return View for row
 */
- (UIView *)comboBox:(BIComboBox *)comboBox viewForRow:(NSInteger)row reusingView:(UIView *)view{
    if(!view){
        view = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
        ((UILabel *)view).textAlignment = NSTextAlignmentCenter;
    }
    
    ((UILabel *)view).text = [self comboBox:comboBox titleForRow:row];
    return view;
}
/**
 *  Height for rows
 *
 *  @param comboBox Concerned comboBox
 *
 *  @return Height for rows
 */
- (CGFloat)rowHeightInComboBox:(BIComboBox *)comboBox{
    return 30.0f;
}

/**
 *  Number of row in comboBox
 *
 *  @param comboBox Concerned ComboBox
 *
 *  @return Number of rows
 */
- (NSInteger)numberOfRowsInComboBox:(BIComboBox *)comboBox{
    return [_titles count];
}

@end
