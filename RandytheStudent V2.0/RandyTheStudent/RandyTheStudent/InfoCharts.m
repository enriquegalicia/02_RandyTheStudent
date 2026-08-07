//
//  InfoCharts.m
//  RandyTheStudent
//
//  Created by Enrique Galicia on 04/03/14.
//  Copyright (c) 2014 Enrique Galicia. All rights reserved.
//

#import "InfoCharts.h"

@implementation InfoCharts

@synthesize Rectangulos;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self setMultipleTouchEnabled:NO];
        [self setBackgroundColor:[UIColor clearColor]];

        
    }
    return self;
    
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setMultipleTouchEnabled:NO];
        
    }
    return self;
}



- (void)drawRect:(CGRect)rect
{
    NSArray *Campos=[Rectangulos objectForKey:@"Campos"];
    NSArray *Acumulado=[Rectangulos objectForKey:@"Acumulado"];
    NSArray *Campo=[Rectangulos objectForKey:@"Campo"];
     NSArray *Valor=[Rectangulos objectForKey:@"Valor"];
    
    //NSLog(@"Puntos%@",[NSValue valueWithCGRect:CGRectMake(100, 0, rect.size.width-100,rect.size.height)]);
    
    
    NSArray *viewstoremove=[self subviews];
    for (UILabel *v in viewstoremove) {
        [v removeFromSuperview];
    }
    float altototal=rect.size.height;
    float divisiones=altototal/[Campos count];
    float maximo=0.0;
    if ([Campos count]>0){
        for (int a=0; a<=[Campos count]-1; a++) {
            UILabel *Nombre=[[UILabel alloc]init];
            Nombre.text=[Campos objectAtIndex:a];
            Nombre.frame=CGRectMake(0, 0, 100, divisiones-10);
            Nombre.center=CGPointMake(50, divisiones/2+5+(a*divisiones));
            Nombre.minimumScaleFactor=0.5;
            Nombre.adjustsFontSizeToFitWidth=YES;
            [self addSubview:Nombre];
        }
    }
    if ([Acumulado count]>0){
        for (int a=0; a<=[Acumulado count]-1; a++) {
            if (maximo<[[Acumulado objectAtIndex:a]floatValue]) {
                maximo=[[Acumulado objectAtIndex:a]floatValue];
            }
        }
    }
    float pixval=(rect.size.width-100)/maximo;
    
    
    //Create Background
    if ([Acumulado count]>0){
        for (int a=0; a<=[Acumulado count]-1; a++) {
            
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path setLineWidth:1];
            [self drawrectangles:path posicion:CGRectMake(100, (0+a*divisiones), 100+[[Acumulado objectAtIndex:a] floatValue]*pixval, divisiones+(a*divisiones))];
            //NSLog(@" %iY%f Acum %f",a,(0+a*divisiones),[[Acumulado objectAtIndex:a] floatValue]*pixval);
            
            
            UIColor *fillColor = [UIColor lightGrayColor];
            [fillColor setFill];
            UIColor *strokeColor = [UIColor blackColor];
            [strokeColor setStroke];
            [path closePath];
            [path fill];
            [path stroke];
        }
    }
    if ([Campo count]>0){
        for (int a=0; a<=[Campo count]-1; a++) {
            NSArray *campo=[Campo objectAtIndex:a];
            NSArray *valor=[Valor objectAtIndex:a];
            float base=100;
            float azul=1;
            float rojo=1;
            float verde=1;
            if ([campo count]>0) {
                for (int b=0; b<=[campo count]-1; b++) {
                    
                    UIBezierPath *path;
                    path = [UIBezierPath bezierPath];
                    [path setLineWidth:1];
                    
                    [self drawrectangles:path posicion:CGRectMake(base, (0+a*divisiones),base+[[valor objectAtIndex:b] floatValue]*pixval, divisiones+(a*divisiones))];
                    base=base+[[valor objectAtIndex:b] floatValue]*pixval;
                    
                    azul=azul-0.05;
                    if (azul<0) {
                        azul=azul+1;
                    }
                    verde=verde-0.10;
                    if (verde<0) {
                        verde=verde+1;
                    }
                    rojo=rojo-0.15;
                    if (rojo<0) {
                        rojo=rojo+1;
                    }
                   

                    UIColor *fillColor = [UIColor colorWithRed:rojo green:verde blue:azul alpha:1];

                    [fillColor setFill];
                    UIColor *strokeColor = [UIColor blackColor];
                    [strokeColor setStroke];
                    [path closePath];
                    [path fill];
                    [path stroke];
                    
                   
                    
                }
            }
            
            
        }
    }
   
}


-(void)drawrectangles:(UIBezierPath*)pato posicion:(CGRect)posicion{
    //NSLog(@"Puntos%@",[NSValue valueWithCGRect:posicion]);
    [pato moveToPoint:CGPointMake(posicion.origin.x,posicion.origin.y)];
    [pato addLineToPoint:CGPointMake(posicion.size.width, posicion.origin.y)];
    [pato addLineToPoint:CGPointMake(posicion.size.width,posicion.size.height)];
    [pato addLineToPoint:CGPointMake(posicion.origin.x, posicion.size.height)];
    
    
    
}
-(void)updateview{
    [self setNeedsDisplay];
}








@end
