//
//  APHConfirmationView.h
//  Parkinson
//
//  Created by Henry McGilton on 8/20/14.
//  Copyright (c) 2014 Henry McGilton. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APHConfirmationView : UIView

@property  (nonatomic, strong)  UIColor  *enabledTickColor;
@property  (nonatomic, strong)  UIColor  *enabledBackgroundColor;

@property  (nonatomic, strong)  UIColor  *disabledTickColor;
@property  (nonatomic, strong)  UIColor  *disabledBackgroundColor;

@property  (nonatomic, assign, getter = isCompleted)  BOOL  completed;

@end
