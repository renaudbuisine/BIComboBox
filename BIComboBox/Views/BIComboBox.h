//
//  BIComboBox.h
//  BIComboBox
//
//  Created by Renaud Buisine on 14/03/16.
//
//

#import <UIKit/UIKit.h>

@class BIComboBox;

#pragma mark PUBLIC CONSTANTS - NOTIFICATIONS
extern NSString *const BIComboBoxWillShowNotification;
extern NSString *const BIComboBoxDidShowNotification;
extern NSString *const BIComboBoxWillHideNotification;
extern NSString *const BIComboBoxDidHideNotification;
extern NSString *const BIComboBoxWillChangeFrameNotification;
extern NSString *const BIComboBoxDidChangeFrameNotification;

@protocol BIComboBoxDelegate
/**
 *  When a row is selected for combobox
 *
 *  @param comboBox Concerned combobox
 *  @param row      Index of selected row
 */
- (void)comboBox:(BIComboBox *)comboBox didSelectRow:(NSInteger)row;
/**
 *  Request for title for row
 *
 *  @param comboBox Concerned combobox
 *  @param row      Index of row
 *
 *  @return Title for row
 */
- (NSString *)comboBox:(BIComboBox *)comboBox titleForRow:(NSInteger)row;
/**
 *  Request view for row of comboBox
 *
 *  @param comboBox Concerned comboBox
 *  @param row      Index of row
 *  @param view     View which could be reused
 *
 *  @return View for row
 */
- (UIView *)comboBox:(BIComboBox *)comboBox viewForRow:(NSInteger)row reusingView:(UIView *)view;
/**
 *  Height for rows
 *
 *  @param comboBox Concerned comboBox
 *
 *  @return Height for rows
 */
- (CGFloat)rowHeightInComboBox:(BIComboBox *)comboBox;
@end

@protocol BIComboBoxDatasourse
/**
 *  Number of row in comboBox
 *
 *  @param comboBox Concerned ComboBox
 *
 *  @return Number of rows
 */
- (NSInteger)numberOfRowsInComboBox:(BIComboBox *)comboBox;
@end

@interface BIComboBox : UIControl<UIPickerViewDataSource,UIPickerViewDelegate>

/**
 *  Property to set image of comboBox
 */
@property (strong,nonatomic) IBInspectable UIImage *iconImage;
/**
 *  Place holder of comboBox
 */
@property (strong,nonatomic) IBInspectable NSString *placeHolder;

/**
 *  Buttons to display on tool bar of pickerview
 */
@property (nonatomic) IBInspectable BOOL validateButton;

/**
 *  Max height for picker view (and its toolbar)
 */
@property (nonatomic) IBInspectable CGFloat pickerHeight;
/**
 *  Does combobox should emulate keyboard behavior
 */
@property (nonatomic) IBInspectable BOOL emulateKeyboardBehavior;

/**
 *  Is comboBox (picker view) opened?
 */
@property (nonatomic,readonly) BOOL isOpened;
/**
 *  Selected index (default at -1)
 */
@property (nonatomic) NSInteger selectedIndex;
/**
 *  Datasource object
 */
@property (nonatomic,weak) id<BIComboBoxDatasourse> dataSource;
/**
 *  Delegate object
 */
@property (nonatomic,weak) id<BIComboBoxDelegate> delegate;


@end
