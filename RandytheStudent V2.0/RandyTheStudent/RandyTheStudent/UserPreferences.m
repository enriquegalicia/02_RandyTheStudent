//
//  UserPreferences.m
//  Magma
//
//  Created by Enrique Galicia on 23/05/13.
//  Copyright (c) 2013 Enrique Galicia. All rights reserved.
//

#import "UserPreferences.h"

@implementation UserPreferences
@synthesize BaseInicial,Password,prefs,acceso,entero,IDUsuario;



-(id)initwithdefaults{
    prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs stringForKey:@"Usuario"]) {
        [prefs setObject:@"" forKey:@"Usuario"];
    }
    if (![prefs stringForKey:@"Password"]) {
        [prefs setObject:@"" forKey:@"Password"];
    }
    if (![prefs stringForKey:@"Entero"]) {
        [prefs setInteger:0 forKey:@"Entero"];
    }
    if (![prefs stringForKey:@"ID"]) {
        [prefs setInteger:0 forKey:@"ID"];
    }
    [prefs synchronize];
    
    BaseInicial = [prefs stringForKey:@"BaseInicial"];
    Password = [prefs stringForKey:@"Password"];
    entero= [[prefs stringForKey:@"Entero"] integerValue];
    IDUsuario=[prefs stringForKey:@"ID"];
    [prefs synchronize];
    //NSLog(@"BAseInicial:%@",BaseInicial);
    //NSLog(@"Password:%@",Password);
    //NSLog(@"Entero:%li",(long)entero);
    //NSLog(@"IDUsuario:%@",IDUsuario);
    
    return self;
}
-(void)setoBaseInicial:(NSString *)BaseInicial1{
    [prefs setObject:BaseInicial1 forKey:@"BaseInicial"];
    [prefs synchronize];
    BaseInicial1 = [prefs stringForKey:@"BaseInicial"];
    //NSLog(@"BaseInicial:%@",BaseInicial1);
}
-(void)setoPassword:(NSString *)Usuario1{
    [prefs setObject:Usuario1 forKey:@"Password"];
    [prefs synchronize];
    Password = [prefs stringForKey:@"Password"];
    //NSLog(@"Password:%@",Password);
}
-(void)setoEntero:(NSInteger)Entero{
    [prefs setInteger:Entero forKey:@"Entero"];
    [prefs synchronize];
    entero= [[prefs stringForKey:@"Entero"] integerValue];
    //NSLog(@"Entero:%li",(long)entero);
}
-(void)setoIDD:(NSString *)Entero{
    [prefs setObject:Entero forKey:@"ID"];
    [prefs synchronize];
    IDUsuario= [prefs stringForKey:@"ID"];
    //NSLog(@"Entero:%@",IDUsuario);
}
-(NSString*)getoBaseInicial{
    return [prefs stringForKey:@"BaseInicial"];
}
-(NSString*)getoPassword{
    return [prefs stringForKey:@"Usuario"];
}
-(int)getoEntero{
    return [[prefs stringForKey:@"Entero"] intValue];
}
-(NSString*)getoID{
    return [prefs stringForKey:@"ID"];
}


@end
