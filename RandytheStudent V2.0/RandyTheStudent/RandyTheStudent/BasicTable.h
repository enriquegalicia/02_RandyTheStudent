//
//  BasicTable.h
//  Magma
//
//  Created by Enrique Galicia on 19/08/13.
//  Copyright (c) 2013 Enrique Galicia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol basictable;

@interface BasicTable : UITableViewController{
    
    id<basictable>delegadobase;
    
    NSArray *titulo;
    NSArray *titulo2;
    NSArray *subtitulo;
    NSArray *subtitulo2;
    NSUInteger cantidaddeelementos;
    NSMutableDictionary *valoresphp;
    int tamtit;
    int tamsubtit;
    int funcion;
}

@property(nonatomic,assign)int tamtit;
@property(nonatomic,assign)int funcion;
@property(nonatomic,assign)int tamsubtit;
@property(nonatomic,retain)id<basictable>delegadobase;

@property(nonatomic,retain)NSDictionary *informacion;

-(void)cargartablas:(NSDictionary*)informacion;

@end

@protocol basictable

-(void)setselected:(NSString*)seleccion fun:(int)fun;

@end



