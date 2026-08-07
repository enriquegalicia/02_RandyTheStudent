//
//  RandyMenu.m
//  RandyTheStudent
//
//  Created by Enrique Galicia on 8/21/12.
//  Copyright (c) 2012 Enrique Galicia. All rights reserved.
//

#import "RandyMenu.h"
#import "Classes.h"


@implementation RandyMenu
@synthesize flipsidePopoverController2;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(NSString*)randy:(NSString*)key comment:(NSString*)comment{
    NSBundle *b =[NSBundle mainBundle];
    NSString *str =[b localizedStringForKey:key value:nil table:@"RandyLocal"];
    return str;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    sub=[[Subtitulados alloc]init];
    valores=[[NSMutableDictionary alloc]init];
    
    //Crear Campos de Base Principal
    NSArray *tablaarchivos=[NSArray arrayWithObjects:@"ARCHIVOS",@"NOMBRE TEXT",@"ARCHITEXT TEXT", nil];
    NSArray *concentrado=[NSArray arrayWithObjects:tablaarchivos, nil];
    
    //Crear Base Principal
    BasedeBases=[[DataBase alloc]initDB:@"Principal2.db" Tablas:concentrado];
    
    NSArray *BDPrincipal=[NSArray arrayWithObjects:@"Id",@"Nombre",@"Architext", nil];
    NSArray *BDPrincipalS=[NSArray arrayWithObjects:@"Nombre",@"Architext", nil];
    
    
    NSArray *Valores=[NSArray arrayWithObjects:@"Default",@"Default2.db", nil];
    [valores setObject:BDPrincipal forKey:@"BDPrincipal"];
    [valores setObject:BDPrincipalS forKey:@"BDPrincipalS"];
    
    
    if ([[[BasedeBases getalltablesfromDB:@"archivos" campos:BDPrincipal] objectForKey:@"Id"] count]==0) {
        [BasedeBases revisarBD:BDPrincipalS Valores:Valores Testigo:@"Nombre" Tabla:@"archivos" Campo:@"Nombre" Nombre:@"Default"];
    }
    
    prefs = [NSUserDefaults standardUserDefaults];
    NSString* strCat= [prefs objectForKey:@"Archivo"];
    if (!strCat) {
        [prefs setObject:@"Default2.db" forKey:@"Archivo"];
        [prefs synchronize];
    }
    strCat= [prefs objectForKey:@"Archivo"];
    [valores setObject:strCat forKey:@"NArchivo"];
     NSString *narchivo=[BasedeBases getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT nombre FROM archivos WHERE architext=\"%@\"",[valores objectForKey:@"NArchivo"]]];
    
    
    BasesDatos=[[ComboBox alloc]init];
    BasesDatos.delegadocombo=self;
    [BasesDatos setActivo:1];
    BasesDatos.titulo=@"Archivo";
    BasesDatos.view.frame= IvBase.frame;
    [self.view addSubview:BasesDatos.view];
    [BasesDatos text:narchivo];

    [BasesDatos setComboData:[sub MAtitc1:[BasedeBases getalltablesfromDB:@"archivos" campos:BDPrincipal] c1:@"Nombre" ]];
    
    [BasesDatos text:[sub titc1:[BasedeBases getalldatafromstatement:[NSString stringWithFormat:@"SELECT * FROM archivos WHERE architext=\"%@\"",strCat] campos:BDPrincipal] c1:@"Nombre"]];
    [valores setObject:[sub titc1:[BasedeBases getalldatafromstatement:[NSString stringWithFormat:@"SELECT * FROM archivos WHERE architext=\"%@\"",strCat] campos:BDPrincipal] c1:@"Nombre"] forKey:@"NArchivo"];
    [valores setObject:[BasedeBases getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT architext FROM archivos WHERE nombre=\"%@\"",[valores objectForKey:@"NArchivo"]]] forKey:@"Archivo"];
    
}
//Informacion del Seleccionado ComboBox
-(void)sendselection:(NSString*)sendselection titulo:(NSString*)titulo{
    //NSLog(@"seleccion %@_%@",sendselection,titulo);

    
    if ([titulo isEqualToString:@"Archivo"]) {
        [valores setObject:sendselection forKey:@"NArchivo"];
        NSString *archivo=[BasedeBases getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT architext FROM archivos WHERE nombre=\"%@\"",[valores objectForKey:@"NArchivo"]]];
        [valores setObject:archivo forKey:@"Archivo"];
        [prefs setObject:archivo forKey:@"Archivo"];
        [prefs synchronize];
        NuevaClase.text=sendselection;
    }
}

-(void)ClassesDidFinish:(Classes*)controller{
    [self dismissViewControllerAnimated:YES completion:nil];
}




- (void)viewDidUnload
{
    [super viewDidUnload];

}

-(IBAction)enterclass:(id)sender{
    Classes *clase;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        clase= [[Classes alloc] initWithNibName:@"MainViewController_iPhone" bundle:nil];
    } else {
        clase= [[Classes alloc] initWithNibName:@"MainViewController_iPad" bundle:nil];
    }

    clase.delegatem=self;
    clase.archivo1=[valores objectForKey:@"Archivo"];

    [self presentViewController:clase animated:YES completion:nil];
}
-(IBAction)newclass:(id)sender{
    if (![NuevaClase.text isEqualToString:@""]) {
        NSArray *informacion=[NSArray arrayWithObjects:NuevaClase.text,[NSString stringWithFormat:@"%@.db",NuevaClase.text],nil];
        [BasedeBases revisarBD:[valores objectForKey:@"BDPrincipalS"] Valores:informacion Testigo:@"nombre" Tabla:@"archivos" Campo:@"nombre" Nombre:NuevaClase.text];
        [BasesDatos setComboData:[sub MAtitc1:[BasedeBases getalltablesfromDB:@"archivos" campos:[valores objectForKey:@"BDPrincipal"]] c1:@"Nombre" ]];
    }
}
-(IBAction)renameclass:(id)sender{
    if (![NuevaClase.text isEqualToString:@""]) {
        NSString *idd=[BasedeBases getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT id FROM archivos WHERE nombre=\"%@\"",BasesDatos.selectedText]];
        [BasedeBases update:[NSString stringWithFormat:@"UPDATE archivos SET nombre =\"%@\" WHERE id =\"%@\"",NuevaClase.text,idd]];
        [BasesDatos setComboData:[sub MAtitc1:[BasedeBases getalltablesfromDB:@"archivos" campos:[valores objectForKey:@"BDPrincipal"]] c1:@"Nombre" ]];
        
        [valores setObject:NuevaClase.text forKey:@"NArchivo"];
        NSString *archivo=[BasedeBases getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT architext FROM archivos WHERE nombre=\"%@\"",[valores objectForKey:@"NArchivo"]]];
        [valores setObject:archivo forKey:@"Archivo"];
        [prefs setObject:archivo forKey:@"Archivo"];
        [prefs synchronize];
        NuevaClase.text=NuevaClase.text;
        [BasesDatos text:NuevaClase.text];
        
        
        
    }
    
    
    
}

-(void)CreditsDidFinish:(Credits*)controller{
    NSLog(@"Ejecute Cierre");
    [self.flipsidePopoverController2 dismissPopoverAnimated:YES];
}
-(IBAction)credits:(id)sender{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        Credits *credits = [[Credits alloc] initWithNibName:@"Credits" bundle:nil];
        credits.delegatec = self;
        [self presentViewController:credits animated:YES completion:nil];
    } else {
        if (!self.flipsidePopoverController2) {
            Credits *credits = [[Credits alloc] initWithNibName:@"Credits" bundle:nil];
            credits.delegatec = self;
            self.flipsidePopoverController2 = [[UIPopoverController alloc] initWithContentViewController:credits];
        }
        if ([self.flipsidePopoverController2 isPopoverVisible]) {
            [self.flipsidePopoverController2 dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController2 presentPopoverFromRect:CGRectMake(0,0,320,480) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
        }
    }
}
-(void)MainDidFinish:(Classes*)controller{
    [self dismissViewControllerAnimated:NO completion:nil];
}


@end
