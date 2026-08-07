//
//  UserPreferences.h
//  Magma
//
//  Created by Enrique Galicia on 23/05/13.
//  Copyright (c) 2013 Enrique Galicia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserPreferences : NSObject{
    NSString *BaseInicial;
    NSString *Password;
    BOOL acceso;
    NSInteger entero;
    NSString *IDUsuario;
    NSUserDefaults *prefs;
}

@property(nonatomic,retain)NSString *BaseInicial;
@property(nonatomic,retain)NSString *Password;
@property(nonatomic,retain)NSString *IDUsuario;
@property(nonatomic,retain)NSUserDefaults *prefs;
@property(nonatomic,assign)BOOL acceso;
@property(nonatomic,assign)NSInteger entero;

-(id)initwithdefaults;
-(void)setoBaseInicial:(NSString *)BaseInicial1;
-(void)setoPassword:(NSString *)Usuario1;
-(void)setoEntero:(NSInteger)Entero;
-(void)setoIDD:(NSString*)Entero;
-(NSString*)getoBaseInicial;
-(NSString*)getoPassword;
-(int)getoEntero;
-(NSString*)getoID;

@end


