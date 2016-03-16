//
//  BIComboBox.m
//  BIComboBox
//
//  Created by Renaud Buisine on 14/03/16.
//
//

#import "BIComboBox.h"

@interface BIComboBox(){
    /// Icon of combobox (arrow)
    __weak IBOutlet UIImageView *_arrowImageView;
    /// Label for place holder of view
    __weak IBOutlet UILabel *_placeHolderLabel;
    /// Label for selected value of comboBox
    __weak IBOutlet UILabel *_titleLabel;
    
    /**
     *  Container view for picker view, if null, picker view is not created
     */
    UIView *_pickerContainerView;
    /**
     *  Picker view to select value, if nul, picker view is not created
     */
    UIPickerView *_pickerView;
    /**
     *  Is picker view opening or closing?
     */
    BOOL _isStatusUpdating;
}

@end

#pragma mark PUBLIC CONSTANTS - NOTIFICATIONS
NSString *const BIComboBoxWillShowNotification = @"BIComboBox.notification.willShowNotification";
NSString *const BIComboBoxDidShowNotification = @"BIComboBox.notification.didShowNotification";
NSString *const BIComboBoxWillHideNotification = @"BIComboBox.notification.willHideNotification";
NSString *const BIComboBoxDidHideNotification = @"BIComboBox.notification.didHideNotification";
NSString *const BIComboBoxWillChangeFrameNotification = @"BIComboBox.notification.willChangeFrameNotification";
NSString *const BIComboBoxDidChangeFrameNotification = @"BIComboBox.notification.didChangeFrameNotification";

@implementation BIComboBox
#pragma mark @synthesize
@synthesize placeHolder = _placeHolder;
@synthesize iconImage = _iconImage;

#pragma mark CONSTANTS
CGFloat const BIComboBox_defaultPickerViewHeight = 144;
CGFloat const BIComboBox_defaultPickerViewRowHeight = 40;
CGFloat const BIComboBox_defaultPickerViewTollBarHeight = 44;
CGFloat const BIComboBox_defaultToolBarRightMargin = 15;
NSTimeInterval const BIComboBox_defaultAnimationDuration = 0.2;
#pragma mark CONSTANTS - PICKER ANIMATIONS
NSString *const BIComboBox_pickerViewAnimationShow = @"BIComboBox.animation.show";
NSString *const BIComboBox_pickerViewAnimationHide = @"BIComboBox.animation.hide";
NSTimeInterval const BIComboBox_pickerViewAnimationDuration = 0.35;
UIViewAnimationCurve const BIComboBox_pickerViewAnimationCurve = UIViewAnimationCurveEaseInOut;

#pragma mark INIT

- (void)awakeFromNib{
    [super awakeFromNib];
    
    [self _init];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self _init];
    }
    return self;
}

- (void)_init{
    [self _initWithDefaultValues];
    [self _initStyle];
    [self _initIconImage];
    [self _initPlaceHolder];
    [self _initEvents];
}

#pragma mark VIEW

- (void)layoutSubviews{
    [super layoutSubviews];
    /**
     *  picker view is displayed !
     */
    if(_isOpened){
        _pickerContainerView.frame = [self _pickerContainerFrame];
    }
}

#pragma mark DEFAULT VALUES
/**
 *  Check and set if necessary default values
 */
- (void)_initWithDefaultValues{
    if(_pickerHeight <= 0){
        _pickerHeight = BIComboBox_defaultPickerViewHeight;
    }
    _selectedIndex = -1;
    _isOpened = NO;
}

#pragma mark STYLE

/**
 *  Initialise style of comboBox
 */
- (void)_initStyle{
    self.layer.cornerRadius = 5;
    
}

#pragma mark RESPONDER FUNCTIONS

/**
 *  This control can become a first responder (get focus)
 *
 *  @return Yes it can
 */
- (BOOL)canBecomeFirstResponder{
    return YES;
}

/**
 *  When get focus
 *
 *  @return get focus?
 */
- (BOOL)becomeFirstResponder{
    // if not opened => open picker view
    if(!_isOpened){
        [self _showPickerView];
        return [super becomeFirstResponder];
    }
    return !_isStatusUpdating && [super becomeFirstResponder];
}

- (BOOL)canResignFirstResponder{
    return YES;
}

- (BOOL)resignFirstResponder{
    // if picker view is opened => close it
    if(_isOpened){
        [self _hidePickerView];
        return [super resignFirstResponder];
    }
    return !_isStatusUpdating && [super resignFirstResponder];
}

#pragma mark COMBOBOX BASE EVENTS

/**
 *  Initialize events (add targets,...)
 */
- (void)_initEvents{
    [self addTarget:self action:@selector(_didTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
}

/**
 *  Called when combobox is performed
 */
- (void)_didTouchUpInside{
    if(!_isStatusUpdating){
        if(!_isOpened){
            [self becomeFirstResponder];
        }
        else{
            [self resignFirstResponder];
        }
    }
}

#pragma mark ARROW ICON
/**
 *  Initialise
 */
- (void)_initIconImage{
    if(_iconImage){
        _arrowImageView.image = _iconImage;
    }
}

// SETTER/GETTER for image of icon image view
- (void)setIconImage:(UIImage *)iconImage{
    _arrowImageView.image = iconImage;
    _iconImage = iconImage;
}

#pragma mark PLACE HOLDER
/**
 *  Initialise place holder label
 */
- (void)_initPlaceHolder{
    if(_placeHolder){
        _placeHolderLabel.text = _placeHolder;
    }
}

// SETTER/GETTER for placeHolder of comboBox
- (void)setPlaceHolder:(NSString *)placeHolder{
    _placeHolderLabel.text = placeHolder;
    _placeHolder = placeHolder;
}

#pragma mark PICKER VIEW

/**
 *  Private getter to get picker container view, checks if exists and creates it if necessary
 *
 *  @return Picker view container of comboBox
 */
- (UIView *) _pickerContainerView{
    // if does not exists, create view
    if(!_pickerContainerView){
        [self _createPickerView];
    }
    return _pickerContainerView;
}

/**
 *  Private getter to get picker view, checks if exists and creates it if necessary
 *
 *  @return Picker view of comboBox
 */
- (UIPickerView *) _pickerView{
    if(!_pickerView){
        [self _createPickerView];
    }
    return _pickerView;
}

#pragma mark PICKER VIEW - FRAME

/**
 *  Frame for picker container view
 *
 *  @return Frame for picker container view
 */
- (CGRect)_pickerContainerFrame{
    CGRect windowBounds = [[[UIApplication sharedApplication] delegate] window].bounds;
    return CGRectMake(0,windowBounds.size.height - _pickerHeight, windowBounds.size.width, _pickerHeight);
}
/**
 *  Frame for picker container view when hidden (at bottom of the screen)
 *
 *  @return Frame for picker container view
 */
- (CGRect)_pickerContainerHiddenFrame{
    CGRect windowBounds = [[[UIApplication sharedApplication] delegate] window].bounds;
    return CGRectMake(0,windowBounds.size.height, windowBounds.size.width, _pickerHeight);
}

#pragma mark PICKER VIEW - CREATE

/**
 *  Create picker container and its content
 */
- (void) _createPickerView{
    _pickerContainerView = [[UIView alloc] initWithFrame:[self _pickerContainerHiddenFrame]];
    // blurred background
    UIBlurEffect *blurredEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView * viewWithBlurredBackground = [[UIVisualEffectView alloc] initWithEffect:blurredEffect];
    viewWithBlurredBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    viewWithBlurredBackground.frame = _pickerContainerView.bounds;
    [_pickerContainerView insertSubview:viewWithBlurredBackground atIndex:0];
    
    // do we need toolbar ?
    CGRect pickerViewFrame = _pickerContainerView.bounds;
    if(_validateButton){
        // create toolbar
        UIToolbar *toolbal = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, _pickerContainerView.bounds.size.width, BIComboBox_defaultPickerViewTollBarHeight)];
        
        //buttons !
        UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_didTouchUpInside)];
        UIBarButtonItem *fixedItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedItem.width = BIComboBox_defaultToolBarRightMargin;
        [toolbal setItems:[[NSArray alloc] initWithObjects:flexibleItem, buttonItem, fixedItem, nil]];
        
        // add toolbar
        [_pickerContainerView addSubview:toolbal];
        
        // update picker view frame
        pickerViewFrame = CGRectMake(0, BIComboBox_defaultPickerViewTollBarHeight, pickerViewFrame.size.width, pickerViewFrame.size.height - BIComboBox_defaultPickerViewTollBarHeight);
    }
    // create pickerView
    _pickerView = [[UIPickerView alloc] initWithFrame:pickerViewFrame];
    // datasource/delegate
    _pickerView.dataSource = self;
    _pickerView.delegate = self;
    // add to superiew
    [_pickerContainerView addSubview:_pickerView];
    
}

#pragma mark PICKER VIEW - WINDOW

/**
 *  Add picker view into window
 */
- (void)_insertPickerView{
    UIView *picker = [self _pickerContainerView];
    UIWindow *mainWindow = [[[UIApplication sharedApplication] delegate] window];
    [mainWindow addSubview:picker];
    picker.frame = [self _pickerContainerHiddenFrame];
}

/**
 *  Remove picker view from window
 */
- (void)_removePickerView{
    [[self _pickerContainerView] removeFromSuperview];
}

#pragma mark PICKER VIEW - ANIMATE

/**
 *  Animate picker view to reach provided frame
 *
 *  @param animation Animation name
 *  @param frame Final frame (after animation)
 */
- (void)_pickerViewAnimate:(NSString *)animation toFrame:(CGRect)frame{
    _isStatusUpdating = YES;
    
    // begin animating pickerView
    [UIView beginAnimations:animation context:nil];
    [UIView setAnimationCurve:BIComboBox_pickerViewAnimationCurve];
    [UIView setAnimationDuration:BIComboBox_pickerViewAnimationDuration];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationWillStartSelector:@selector(_pickerViewAnimationWillStart:)];
    [UIView setAnimationDidStopSelector:@selector(_pickerViewAnimationDidStop:)];
    
    [self _pickerContainerView].frame = frame;
    
    [UIView commitAnimations];
}

/**
 *  show pickerview
 */
- (void)_showPickerView{
    if(!_isStatusUpdating && !_isOpened){
        [self _insertPickerView];
        [self _pickerViewAnimate:BIComboBox_pickerViewAnimationShow toFrame:[self _pickerContainerFrame]];
    }
}

/**
 *  Hide pickerview
 */
- (void)_hidePickerView{
    if(!_isStatusUpdating && _isOpened){
        // broadcast selection to delegate object and other listener
        [self _didEndSelect];
        
        [self _pickerViewAnimate:BIComboBox_pickerViewAnimationHide toFrame:[self _pickerContainerHiddenFrame]];
    }
}

/**
 *  Called when picker view animation is going to start
 *
 *  @param animation Animation name
 */
- (void)_pickerViewAnimationWillStart:(NSString *)animation{
    // send notifications !!!
    NSString *notificationName;
    CGRect finalFrame;
    if([animation isEqualToString:BIComboBox_pickerViewAnimationShow]){
        notificationName = BIComboBoxWillShowNotification;
        finalFrame = [self _pickerContainerFrame];
    }
    else if([animation isEqualToString:BIComboBox_pickerViewAnimationHide]){
        notificationName = BIComboBoxWillHideNotification;
        finalFrame = [self _pickerContainerHiddenFrame];
    }
    // willshow/hide notification
    [self _postNotificationWithName:notificationName frameEnd:finalFrame];
    //will frame change notification
    [self _postNotificationWithName:BIComboBoxWillChangeFrameNotification frameEnd:finalFrame];
}
/**
 *  Called when picker view animation did end
 *
 *  @param animation Animation name
 */
- (void)_pickerViewAnimationDidStop:(NSString *)animation{
    _isStatusUpdating = NO;
    
    NSString *notificationName;
    CGRect finalFrame;
    if([animation isEqualToString:BIComboBox_pickerViewAnimationShow]){
        _isOpened = YES;
        notificationName = BIComboBoxDidShowNotification;
        finalFrame = [self _pickerContainerFrame];
        // no selected item and at least one item inside => select by default first one
        if(_selectedIndex < 0 && [self pickerView:_pickerView numberOfRowsInComponent:0] > 0){
            [self setSelectedIndex:0];
        }
    }
    else if([animation isEqualToString:BIComboBox_pickerViewAnimationHide]){
        _isOpened = NO;
        [self _removePickerView];
        notificationName = BIComboBoxDidHideNotification;
        finalFrame = [self _pickerContainerHiddenFrame];
    }
    
    // send notifications !!!
    // didshow/hide notification
    [self _postNotificationWithName:notificationName frameEnd:finalFrame];
    //did frame change notification
    [self _postNotificationWithName:BIComboBoxDidChangeFrameNotification frameEnd:finalFrame];
}

#pragma mark NOTIFICATIONS
/**
 *  Post notification for pickerView changes (will/did show,hide...)
 *
 *  @param notificationName Notification name
 *  @param frame            Frame after animation of pickerview
 */
- (void)_postNotificationWithName:(NSString *)notificationName frameEnd:(CGRect)frame{
    if(_emulateKeyboardBehavior){
        NSNumber *animationCurve = [NSNumber numberWithInt:BIComboBox_pickerViewAnimationCurve];
        NSNumber *animationDuration = [NSNumber numberWithFloat:BIComboBox_pickerViewAnimationDuration];
        NSValue *animationFrame = [NSValue valueWithCGRect:frame];
        
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:animationCurve,UIKeyboardAnimationCurveUserInfoKey,
                                  animationDuration,UIKeyboardAnimationDurationUserInfoKey,
                                  animationFrame,UIKeyboardFrameEndUserInfoKey, nil];
        // will show or hide notification
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self userInfo:userInfo];
    }
}

#pragma mark UIPickerViewDataSource

/**
 *  Number of columns in picker view
 *
 *  @param pickerView Concerned pickerView
 *
 *  @return Number of columns
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

/**
 *  Number of rows in picker view
 *
 *  @param pickerView Concerned pickerview
 *  @param component  Index of concerned column (single column here)
 *
 *  @return Number of rows
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _dataSource ? [_dataSource numberOfRowsInComboBox:self] : 0;
}

#pragma mark UIPickerViewDelegate
/**
 *  When a row is selected
 *
 *  @param pickerView Concerned picker view
 *  @param row        Index of row
 *  @param component  Index of column (single column here)
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    // show value on comboBox
    [self setSelectedIndex:row];
}

/**
 *  Request title for row
 *
 *  @param pickerView Concerned pickerview
 *  @param row        Index of row
 *  @param component  Index of column
 *
 *  @return Title
 */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _delegate ? [_delegate comboBox:self titleForRow:row] : nil;
}

/**
 *  Request view for row
 *
 *  @param pickerView Concerned pickerView
 *  @param row        Index of row
 *  @param component  Index of column
 *  @param view       View which could be reused
 *
 *  @return View for row
 */
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    return _delegate ? [_delegate comboBox:self viewForRow:row reusingView:view] : nil;
}

/**
 *  Width for column (single column here => width of pickerView
 *
 *  @param pickerView Concerned pickerView
 *  @param component  Index of column
 *
 *  @return Width for column
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return pickerView.bounds.size.width;
}

/**
 *  Height for row of pickerview
 *
 *  @param pickerView Concerned pickerView
 *  @param component  Index of column (single column here)
 *
 *  @return Height for rows
 */
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return _delegate ? [_delegate rowHeightInComboBox:self] : BIComboBox_defaultPickerViewRowHeight;
}

#pragma mark SELECTION

/**
 *  When selected value change in picker view
 */
- (void)_didSelectedValueChange{
    // reset view ?
    if(_selectedIndex >= 0){
        // if place holder is displayed, hide it and show value
        if(!_placeHolderLabel.hidden){
            [self _prepareTextChanges];
            _titleLabel.hidden = NO;
            _placeHolderLabel.hidden = YES;
        }
        else{
            [self _prepareTextChanges];
        }
        // update text
        _titleLabel.text = [self pickerView:_pickerView titleForRow:_selectedIndex forComponent:0];
    }
    // reset displaying
    else{
        [self _prepareTextChanges];
        _titleLabel.hidden = YES;
        _placeHolderLabel.hidden = NO;
    }
}

/**
 *  Prepare value label to animate text changes
 */
- (void)_prepareTextChanges{
    // Add transition (must be called after myLabel has been displayed)
    CATransition *animation = [CATransition animation];
    animation.duration = BIComboBox_defaultAnimationDuration;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_titleLabel.layer addAnimation:animation forKey:@"changeTextTransition"];
}
/**
 *  Prepare labels to be switched with animation
 */
- (void)_prepareLabelsSwitch{
    CATransition *animation = [CATransition animation];
    animation.duration = BIComboBox_defaultAnimationDuration;
    animation.type = kCATransitionFade;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [_titleLabel.layer addAnimation:animation forKey:@"fadeInOuttransition"];
    [_placeHolderLabel.layer addAnimation:animation forKey:@"fadeInOuttransition"];
}

/**
 *  Override setter of selected index
 *
 *  @param selectedIndex New selected index
 */
- (void)setSelectedIndex:(NSInteger)selectedIndex{
    // update displaying
    _selectedIndex = selectedIndex;
    [self _didSelectedValueChange];
}

/**
 *  Raise event and broadcast selection to delegate object
 */
- (void)_didEndSelect{
    
    // tell delegate object user did choose something !
    if(_delegate){
        [_delegate comboBox:self didSelectRow:_selectedIndex];
    }
    // raise event to trigger value did change action
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
