//
//  Subtitulados.h
//  RandyTheStudent
//
//  Created by Enrique Galicia on 10/02/14.
//  Copyright (c) 2014 Enrique Galicia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Subtitulados : NSObject;

-(NSDictionary*)titc1subc2c3:(NSDictionary*)dic c1:(NSString*)c1 c2:(NSString*)c2 c3:(NSString*)c3;
-(NSDictionary*)titidc1subc2c3:(NSDictionary*)dic c1:(NSString*)c1 c2:(NSString*)c2 c3:(NSString*)c3;
-(NSDictionary*)titidc1c2subc3c4:(NSDictionary*)dic c1:(NSString*)c1 c2:(NSString*)c2 c3:(NSString*)c3 c4:(NSString*)c4;
-(NSDictionary*)titidc1c2subc3c4c5:(NSDictionary*)dic c1:(NSString*)c1 c2:(NSString*)c2 c3:(NSString*)c3 c4:(NSString*)c4 c5:(NSString*)c5;
-(NSDictionary*)titc1c2subc3c4:(NSDictionary*)dic c1:(NSString*)c1 c2:(NSString*)c2 c3:(NSString*)c3 c4:(NSString*)c4;


-(NSMutableArray*)titidc1:(NSDictionary*)titsub c1:(NSString*)c1;
-(NSString*)tit1idc1:(NSDictionary*)titsub c1:(NSString*)c1;

-(NSArray*)DictoArrayc1c2c3:(NSDictionary*)dic c1:(NSString*)c1 c2:(NSString*)c2 c3:(NSString*)c3;
-(NSString*)titc1:(NSDictionary*)titsub c1:(NSString*)c1;
-(NSMutableArray*)MAtitc1:(NSDictionary*)titsub c1:(NSString*)c1;

-(NSDictionary*)subgraf:(NSDictionary*)roles acumulados:(NSDictionary*)acum campos:(NSDictionary*)camp info:(NSArray*)info info2:(NSArray*)info2 info3:(NSArray*)info3 info4:(NSArray*)info4;
@end
