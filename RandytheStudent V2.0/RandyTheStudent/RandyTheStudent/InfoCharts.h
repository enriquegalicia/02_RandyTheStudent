//
//  InfoCharts.h
//  RandyTheStudent
//
//  Created by Enrique Galicia on 04/03/14.
//  Copyright (c) 2014 Enrique Galicia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoCharts : UIView{
    NSDictionary *Rectangulos;
}
@property(nonatomic,retain)NSDictionary *Rectangulos;
-(void)updateview;
@end
