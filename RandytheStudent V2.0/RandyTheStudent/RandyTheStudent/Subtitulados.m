//
//  Subtitulados.m
//  RandyTheStudent
//
//  Created by Enrique Galicia on 10/02/14.
//  Copyright (c) 2014 Enrique Galicia. All rights reserved.
//

#import "Subtitulados.h"

@interface Subtitulados ()

@end

@implementation Subtitulados

//Subtitulado para Tablas
-(NSDictionary*)titidc1subc2c3:(NSDictionary*)dic c1:(NSString*)c1 c2:(NSString*)c2 c3:(NSString*)c3{
    NSMutableDictionary *valores=[[NSMutableDictionary alloc]init];
    NSMutableArray *Titulos=[[NSMutableArray alloc]init];
    NSMutableArray *Subtitulos=[[NSMutableArray alloc]init];
    NSArray *ID=[dic objectForKey:@"Id"];
    NSArray *C1=[dic objectForKey:c1];
    NSArray *C2 =[dic objectForKey:c2];
    NSArray *C3=[dic objectForKey:c3];
    NSUInteger conteo=[ID count];
    if (conteo>=1) {
        
        for (int a=0; a<=conteo-1; a++) {
            
            [Titulos addObject:[NSString stringWithFormat:@"%@_%@",[ID objectAtIndex:a],[C1 objectAtIndex:a]]];
            [Subtitulos addObject:[NSString stringWithFormat:@"%@_%@",[C2 objectAtIndex:a],[C3 objectAtIndex:a]]];
        }
        
    }
    else{
        [Titulos addObject:@"Sin Registros"];
        [Subtitulos addObject:@"Nos Falta Seleccion e Informacion"];
    }
    
    NSArray *titulos2=[NSArray arrayWithArray:Titulos];
    NSArray *subtitulos2=[NSArray arrayWithArray:Subtitulos];
    [valores setObject:titulos2 forKey:@"Titulo"];
    [valores setObject:subtitulos2 forKey:@"Subtitulo"];
    NSDictionary *info=[NSDictionary dictionaryWithDictionary:valores];
    return info;
    
}
-(NSDictionary*)titc1subc2c3:(NSDictionary*)dic c1:(NSString*)c1 c2:(NSString*)c2 c3:(NSString*)c3{
    NSMutableDictionary *valores=[[NSMutableDictionary alloc]init];
    NSMutableArray *Titulos=[[NSMutableArray alloc]init];
    NSMutableArray *Subtitulos=[[NSMutableArray alloc]init];
    NSArray *C1=[dic objectForKey:c1];
    NSArray *C2 =[dic objectForKey:c2];
    NSArray *C3=[dic objectForKey:c3];
    NSUInteger conteo=[C1 count];
    if (conteo>=1) {
        
        for (int a=0; a<=conteo-1; a++) {
            
            [Titulos addObject:[NSString stringWithFormat:@"%i_%@",a+1,[C1 objectAtIndex:a]]];
            [Subtitulos addObject:[NSString stringWithFormat:@"%@_%@",[C2 objectAtIndex:a],[C3 objectAtIndex:a]]];
        }
        
    }
    else{
        [Titulos addObject:@"Sin Registros"];
        [Subtitulos addObject:@"Nos Falta Seleccion e Informacion"];
    }
    
    NSArray *titulos2=[NSArray arrayWithArray:Titulos];
    NSArray *subtitulos2=[NSArray arrayWithArray:Subtitulos];
    [valores setObject:titulos2 forKey:@"Titulo"];
    [valores setObject:subtitulos2 forKey:@"Subtitulo"];
    NSDictionary *info=[NSDictionary dictionaryWithDictionary:valores];
    return info;
    
}

-(NSDictionary*)titidc1c2subc3c4:(NSDictionary*)dic c1:(NSString*)c1 c2:(NSString*)c2 c3:(NSString*)c3 c4:(NSString*)c4{
    NSMutableDictionary *valores=[[NSMutableDictionary alloc]init];
    NSMutableArray *Titulos=[[NSMutableArray alloc]init];
    NSMutableArray *Subtitulos=[[NSMutableArray alloc]init];
    NSArray *ID=[dic objectForKey:@"Id"];
    NSArray *C1=[dic objectForKey:c1];
    NSArray *C2 =[dic objectForKey:c2];
    NSArray *C3=[dic objectForKey:c3];
    NSArray *C4=[dic objectForKey:c4];
    NSUInteger conteo=[ID count];
    if (conteo>=1) {
        
        for (int a=0; a<=conteo-1; a++) {
            
            [Titulos addObject:[NSString stringWithFormat:@"%@_%@ %@",[ID objectAtIndex:a],[C1 objectAtIndex:a],[C2 objectAtIndex:a]]];
            [Subtitulos addObject:[NSString stringWithFormat:@"%@_%@",[C3 objectAtIndex:a],[C4 objectAtIndex:a]]];
        }
        
    }
    else{
        [Titulos addObject:@"Sin Registros"];
        [Subtitulos addObject:@"Nos Falta Seleccion e Informacion"];
    }
    
    NSArray *titulos2=[NSArray arrayWithArray:Titulos];
    NSArray *subtitulos2=[NSArray arrayWithArray:Subtitulos];
    [valores setObject:titulos2 forKey:@"Titulo"];
    [valores setObject:subtitulos2 forKey:@"Subtitulo"];
    NSDictionary *info=[NSDictionary dictionaryWithDictionary:valores];
    return info;
    
}
-(NSDictionary*)titidc1c2subc3c4c5:(NSDictionary*)dic c1:(NSString*)c1 c2:(NSString*)c2 c3:(NSString*)c3 c4:(NSString*)c4 c5:(NSString*)c5{
    NSMutableDictionary *valores=[[NSMutableDictionary alloc]init];
    NSMutableArray *Titulos=[[NSMutableArray alloc]init];
    NSMutableArray *Subtitulos=[[NSMutableArray alloc]init];
    NSArray *ID=[dic objectForKey:@"Id"];
    NSArray *C1=[dic objectForKey:c1];
    NSArray *C2 =[dic objectForKey:c2];
    NSArray *C3=[dic objectForKey:c3];
    NSArray *C4=[dic objectForKey:c4];
    NSArray *C5=[dic objectForKey:c5];
    NSUInteger conteo=[ID count];
    if (conteo>=1) {
        
        for (int a=0; a<=conteo-1; a++) {
            
            [Titulos addObject:[NSString stringWithFormat:@"%@_%@ %@",[ID objectAtIndex:a],[C1 objectAtIndex:a],[C2 objectAtIndex:a]]];
            [Subtitulos addObject:[NSString stringWithFormat:@"%@_%@_%@",[C3 objectAtIndex:a],[C4 objectAtIndex:a],[C5 objectAtIndex:a]]];
        }
        
    }
    else{
        [Titulos addObject:@"Sin Registros"];
        [Subtitulos addObject:@"Nos Falta Seleccion e Informacion"];
    }
    
    NSArray *titulos2=[NSArray arrayWithArray:Titulos];
    NSArray *subtitulos2=[NSArray arrayWithArray:Subtitulos];
    [valores setObject:titulos2 forKey:@"Titulo"];
    [valores setObject:subtitulos2 forKey:@"Subtitulo"];
    NSDictionary *info=[NSDictionary dictionaryWithDictionary:valores];
    return info;
    
}
-(NSDictionary*)titc1c2subc3c4:(NSDictionary*)dic c1:(NSString*)c1 c2:(NSString*)c2 c3:(NSString*)c3 c4:(NSString*)c4{
    NSMutableDictionary *valores=[[NSMutableDictionary alloc]init];
    NSMutableArray *Titulos=[[NSMutableArray alloc]init];
    NSMutableArray *Subtitulos=[[NSMutableArray alloc]init];
    NSArray *C1=[dic objectForKey:c1];
    NSArray *C2 =[dic objectForKey:c2];
    NSArray *C3=[dic objectForKey:c3];
    NSArray *C4=[dic objectForKey:c4];
    NSUInteger conteo=[C1 count];
    if (conteo>=1) {
        
        for (int a=0; a<=conteo-1; a++) {
            
            [Titulos addObject:[NSString stringWithFormat:@"%@_%@",[C1 objectAtIndex:a],[C2 objectAtIndex:a]]];
            [Subtitulos addObject:[NSString stringWithFormat:@"%@_%@",[C3 objectAtIndex:a],[C4 objectAtIndex:a]]];
        }
        
    }
    else{
        [Titulos addObject:@"Sin Registros"];
        [Subtitulos addObject:@"Nos Falta Seleccion e Informacion"];
    }
    
    NSArray *titulos2=[NSArray arrayWithArray:Titulos];
    NSArray *subtitulos2=[NSArray arrayWithArray:Subtitulos];
    [valores setObject:titulos2 forKey:@"Titulo"];
    [valores setObject:subtitulos2 forKey:@"Subtitulo"];
    NSDictionary *info=[NSDictionary dictionaryWithDictionary:valores];
    return info;
    
}






//Subtitulado para ComboBox
-(NSMutableArray*)titidc1:(NSDictionary*)titsub c1:(NSString*)c1{
    NSMutableArray *Titulos=[[NSMutableArray alloc]init];
    NSArray *ID=[titsub objectForKey:@"Id"];
    NSArray *Nombre=[titsub objectForKey:c1];
    NSUInteger conteo=[Nombre count];
    if (conteo>=1) {
        
        for (int a=0; a<=conteo-1; a++) {
            [Titulos addObject:[NSString stringWithFormat:@"%@_%@",[ID objectAtIndex:a],[Nombre objectAtIndex:a]]];
            
        }
        
    }
    else{
        [Titulos addObject:@"Sin Archivos"];
    }
    
    return Titulos;
    
}
-(NSMutableArray*)MAtitc1:(NSDictionary*)titsub c1:(NSString*)c1{
    NSMutableArray *Titulos=[[NSMutableArray alloc]init];
    NSArray *Nombre=[titsub objectForKey:c1];
    NSUInteger conteo=[Nombre count];
    if (conteo>=1) {
        
        for (int a=0; a<=conteo-1; a++) {
            [Titulos addObject:[NSString stringWithFormat:@"%@",[Nombre objectAtIndex:a]]];
            
        }
        
    }
    else{
        [Titulos addObject:@"Sin Archivos"];
    }
    
    return Titulos;
    
}
-(NSString*)tit1idc1:(NSDictionary*)titsub c1:(NSString*)c1{
    NSString *Titulos=@"";
    NSArray *ID=[titsub objectForKey:@"Id"];
    NSArray *Nombre=[titsub objectForKey:c1];
    NSUInteger conteo=[Nombre count];
    if (conteo>=1) {
        
        for (int a=0; a<=conteo-1; a++) {
            Titulos=[NSString stringWithFormat:@"%@_%@",[ID objectAtIndex:a],[Nombre objectAtIndex:a]];
            
        }
        
    }
    else{
        Titulos=@"Sin Archivos";
    }
    
    return Titulos;
    
}
-(NSString*)titc1:(NSDictionary*)titsub c1:(NSString*)c1{
    NSString *Titulos=@"";
    NSArray *Nombre=[titsub objectForKey:c1];
    NSUInteger conteo=[Nombre count];
    if (conteo>=1) {
        
        for (int a=0; a<=conteo-1; a++) {
            Titulos=[NSString stringWithFormat:@"%@",[Nombre objectAtIndex:a]];
            
        }
        
    }
    else{
        Titulos=@"Sin Archivos";
    }
    
    return Titulos;
    
}
//NSDictionarytoArray
-(NSArray*)DictoArrayc1c2c3:(NSDictionary*)dic c1:(NSString*)c1 c2:(NSString*)c2 c3:(NSString*)c3{
    NSMutableArray *Informacion=[[NSMutableArray alloc]init];
    NSArray *C1=[dic objectForKey:c1];
    NSArray *C2 =[dic objectForKey:c2];
    NSArray *C3=[dic objectForKey:c3];
    NSUInteger conteo=[C1 count];
    if (conteo>=1) {
        
        for (int a=0; a<=conteo-1; a++) {
            NSString *c1=[C1 objectAtIndex:a];
            NSString *c2=[C2 objectAtIndex:a];
            NSString *c3=[C3 objectAtIndex:a];

            NSArray *campo=[NSArray arrayWithObjects:c1,c2,c3,nil];
            [Informacion addObject:campo];
        }
        
    }
    else{
        NSString *c1=@"Sin Nombre";
        NSString *c2=@"Sin Apellido";
        NSString *c3=@"Sin Matricula";
        
        NSArray *campo=[NSArray arrayWithObjects:c1,c2,c3,nil];
        [Informacion addObject:campo];
    }
    
    NSArray *entrega=[NSArray arrayWithArray:Informacion];
    return entrega;
    
}

-(NSDictionary*)subgraf:(NSDictionary*)roles acumulados:(NSDictionary*)acum campos:(NSDictionary*)camp info:(NSArray*)info info2:(NSArray*)info2 info3:(NSArray*)info3 info4:(NSArray*)info4{
    //Roles
    NSArray *Campos=[roles objectForKey:[info objectAtIndex:0]];
    //Acumulados
    NSMutableArray *acumulacion=[[NSMutableArray alloc]init];
    NSArray *Posicion=[acum objectForKey:[info2 objectAtIndex:0]];
    NSArray *ccalif=[acum objectForKey:[info2 objectAtIndex:1]];
    NSArray *scalif=[acum objectForKey:[info2 objectAtIndex:2]];
    NSArray *cPosicion=[camp objectForKey:[info3 objectAtIndex:1]];
   // NSArray *cActividad=[acum objectForKey:[info3 objectAtIndex:0]];
    NSArray *cCalif=[camp objectForKey:[info3 objectAtIndex:2]];
    
    if ([Posicion count]>0) {
        for (int a=0; a<=[Posicion count]-1; a++) {
            if (([[ccalif objectAtIndex:a]floatValue]*100)>([[scalif objectAtIndex:a] floatValue])) {
                [acumulacion addObject:[NSString stringWithFormat:@"%f",[[ccalif objectAtIndex:a]floatValue]*100]];
            }
            else{
                [acumulacion addObject:[scalif objectAtIndex:a]];
            }
        }
    }
    NSArray *Acumulado=[NSArray arrayWithArray:acumulacion];
    
    //NSLog(@"INICIAL infernal1 %@, infernal2 %@",roles,acum);

    NSMutableArray *ccampos=[[NSMutableArray alloc]init];
    NSMutableArray *cvalor=[[NSMutableArray alloc]init];
    if ([Posicion count]>0) {
        for (int b=0; b<=[Posicion count]-1; b++) {
            NSMutableArray *campos=[[NSMutableArray alloc]init];
            NSMutableArray *valor=[[NSMutableArray alloc]init];
            int d=1;
            if ([cPosicion count]>0) {
                for (int c=0; c<=[cPosicion count]-1; c++) {
                    if ([[Posicion objectAtIndex:b] isEqualToString:[cPosicion objectAtIndex:c]]) {
                        [campos addObject:[NSString stringWithFormat:@"%i",d]];
                        [valor addObject:[cCalif objectAtIndex:c]];
                        d++;
                    }
                }
            }
            NSArray *acampos=[NSArray arrayWithArray:campos];
            NSArray *avalores=[NSArray arrayWithArray:valor];
            [ccampos addObject:acampos];
            [cvalor addObject:avalores];
        }
    }


NSArray *acampos=[NSArray arrayWithArray:ccampos];
NSArray *avalores=[NSArray arrayWithArray:cvalor];
    //NSLog(@"MEDIO infernal1 %@,Infernal 2%@, infernal3 %@",cPosicion,cActividad,cCalif);

NSMutableDictionary *informacion=[[NSMutableDictionary alloc]init];
[informacion setObject:Campos forKey:[info4 objectAtIndex:0]];
[informacion setObject:Acumulado forKey:[info4 objectAtIndex:1]];
[informacion setObject:acampos forKey:[info4 objectAtIndex:2]];
[informacion setObject:avalores forKey:[info4 objectAtIndex:3]];

NSDictionary *infofinal=[NSDictionary dictionaryWithDictionary:informacion];
    //NSLog(@"FINAL infernal %@",infofinal);
    return infofinal;
    
}



@end
