//
//  Credits.h
//  RandyTheStudent
//
//  Created by Enrique Galicia on 8/24/12.
//  Copyright (c) 2012 Enrique Galicia. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CreditsDelegate;

@interface Credits : UIViewController{
    id<CreditsDelegate> delegatec;
    IBOutlet UILabel *back;
}

@property(assign, nonatomic)id<CreditsDelegate> delegatec;

@end

@protocol CreditsDelegate
-(void)CreditsDidFinish:(Credits*)controller;
@end