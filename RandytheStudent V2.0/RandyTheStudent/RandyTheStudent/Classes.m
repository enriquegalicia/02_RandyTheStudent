//
//  MainViewController.m
//  RandyTheStudent
//
//  Created by Enrique Galicia on 8/8/12.
//  Copyright (c) 2012 Enrique Galicia. All rights reserved.
//

#import "Classes.h"

@interface Classes ()

@end

@implementation Classes
@synthesize delegatem=_delegatem;
@synthesize archivo1;

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 265;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

-(NSString*)randy:(NSString*)key comment:(NSString*)comment{
    NSBundle *b =[NSBundle mainBundle];
    NSString *str =[b localizedStringForKey:key value:nil table:@"RandyLocal"];
    return str;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
       
    
    //Crear Base Datos default
    valores=[[NSMutableDictionary alloc]init];
    sub=[[Subtitulados alloc]init];
    
    
    
    NSArray *tablasbd=[NSArray arrayWithObjects:@"ESTUDIANTES",@"STUDENTID TEXT",@"NOMBRE TEXT",@"APELLIDO TEXT",@"EMAIL TEXT",@"PARTICIPACIONES FLOAT", nil];
    NSArray *tablasAR=[NSArray arrayWithObjects:@"GRUPOS",@"GRUPONO TEXT",@"ALUMNOSID TEXT",@"ACTIVIDAD TEXT",@"POSICION TEXT",@"CALIFICACION FLOAT", nil];
    NSArray *concentracion =[NSArray arrayWithObjects:tablasbd,tablasAR,nil];
    //NSLog(@"%@",concentracion);
    
    prefs = [NSUserDefaults standardUserDefaults];
    
    Baselocal=[[DataBase alloc]initDB:archivo1 Tablas:concentracion];

    
    NSArray *BDLocalES=[NSArray arrayWithObjects:@"Id",@"Studentid",@"Nombre",@"Apellido",@"Email",@"Participaciones", nil];
    NSArray *BDLocalSES=[NSArray arrayWithObjects:@"StudentId",@"Nombre",@"Apellido",@"Email",@"Participaciones", nil];
    
    [valores setObject:BDLocalES forKey:@"BDLocalES"];
    [valores setObject:BDLocalSES forKey:@"BDLocalSES"];
    
    NSArray *BDLocalGR=[NSArray arrayWithObjects:@"Id",@"Grupono",@"Alumnosid",@"Actividad",@"Posicion",@"Calificacion",nil];
    NSArray *BDLocalSGR=[NSArray arrayWithObjects:@"Grupono",@"Alumnosid",@"Actividad",@"Posicion",@"Calificacion", nil];
    NSArray *BDLocalSTAGR=[NSArray arrayWithObjects:@"Grupono",@"Actividad",@"Calificacion", nil];
    
    [valores setObject:BDLocalGR forKey:@"BDLocalGR"];
    [valores setObject:BDLocalSGR forKey:@"BDLocalSGR"];
    [valores setObject:BDLocalSTAGR forKey:@"BDLocalSTAGR"];

    
    TAlumnos=[[BasicTable alloc]init];
    TAlumnos.view.frame=IvAlumnos.frame;
    TAlumnos.delegadobase=self;
    TAlumnos.funcion=1;
    [TAlumnos setTamsubtit:15];
    [TAlumnos setTamtit:20];
    [self.view addSubview:TAlumnos.view];
    [TAlumnos cargartablas:[sub titidc1c2subc3c4c5:[Baselocal getalltablesfromDB:@"estudiantes" campos:[valores objectForKey:@"BDLocalES"]] c1:@"Nombre" c2:@"Apellido" c3:@"Studentid" c4:@"Email" c5:@"Participaciones"]];
    
    TGrupos=[[BasicTable alloc]init];
    TGrupos.view.frame=IvGrupos.frame;
    TGrupos.delegadobase=self;
    TGrupos.funcion=2;
    [TGrupos setTamsubtit:15];
    [TGrupos setTamtit:20];
    [self.view addSubview:TGrupos.view];
    [TGrupos cargartablas:[sub titidc1c2subc3c4:[self Randear:1] c1:@"Grupo" c2:@"Nombre" c3:@"Posicion" c4:@"Studentid"]];
    
    
    TActividades=[[BasicTable alloc]init];
    TActividades.view.frame=IvActividades.frame;
    TActividades.delegadobase=self;
    TActividades.funcion=3;
    [TActividades setTamsubtit:15];
    [TActividades setTamtit:20];
    [self.view addSubview:TActividades.view];
    [TActividades cargartablas:[sub titc1subc2c3:[Baselocal getalldatafromstatement:[NSString stringWithFormat:@"SELECT Grupono,Actividad,Calificacion FROM grupos GROUP BY Grupono,Actividad,Calificacion ORDER BY Actividad,Grupono ASC"] campos:[valores objectForKey:@"BDLocalSTAGR"]] c1:@"Grupono" c2:@"Actividad" c3:@"Calificacion"]];
    
    [valores setObject:@"0" forKey:@"IDRandeo"];
    [valores setObject:@"0" forKey:@"GrupoNoEvaluar"];
    [valores setObject:@"0" forKey:@"ActividadEvaluar"];
    
    LaStudentPerformance.hidden=TRUE;
    
    
    
    
    [self Graficdata];
    [self changerandy:nil];
   
    
    
    
    
    
    

   


}



//Informacion del Seleccionado Tabla
-(void)setselected:(NSString*)seleccion fun:(int)fun{
    int idseleccionado=[seleccion intValue];
    if (fun==1) {
        TfStudent.text=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT Studentid FROM estudiantes WHERE id=%i",idseleccionado]];
        TfFirstName.text=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT Nombre FROM estudiantes WHERE id=%i",idseleccionado]];
        TfLastName.text=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT Apellido FROM estudiantes WHERE id=%i",idseleccionado]];
        TfEmailName.text=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT Email FROM estudiantes WHERE id=%i",idseleccionado]];
        
    }
    if (fun==2) {
        [valores setObject:seleccion forKey:@"IDRandeo"];
        //NSLog(@"idseleccion%@",seleccion);
    }
    if (fun==3) {
        NSLog(@"idseleccion%@",seleccion);
        NSDictionary *grupos=[Baselocal getalldatafromstatement:[NSString stringWithFormat:@"SELECT Grupono,Actividad,Calificacion FROM grupos GROUP BY Grupono,Actividad,Calificacion ORDER BY Actividad,Grupono"] campos:[valores objectForKey:@"BDLocalSTAGR"]];
        //NSLog(@"%@",[grupos objectForKey:@"Grupono"]);
        //NSLog(@"%@",[grupos objectForKey:@"Actividad"]);
        [valores setObject:[[grupos objectForKey:@"Grupono"] objectAtIndex:[seleccion intValue]-1] forKey:@"GrupoNoEvaluar"];
        [valores setObject:[[grupos objectForKey:@"Actividad"] objectAtIndex:[seleccion intValue]-1] forKey:@"ActividadEvaluar"];
        [TGrupos cargartablas:[sub titidc1c2subc3c4:[self Consultar:[valores objectForKey:@"ActividadEvaluar"]] c1:@"Grupo" c2:@"Nombre" c3:@"Posicion" c4:@"Studentid"]];
        //NSLog(@"%@",[valores objectForKey:@"ActividadEvaluar"]);
    }
    
}


//Informacion del Seleccionado ComboBox
-(void)sendselection:(NSString*)sendselection titulo:(NSString*)titulo{
    if ([titulo isEqualToString:@"Archivo"]) {
        //NSLog(@"el Archivo es%@",sendselection);
        
    }
}

-(NSDictionary*)Consultar:(NSString*)actividad{
    NSArray *randybase=[NSArray arrayWithObjects:@"grupono",@"alumnosid",@"posicion", nil];
    NSDictionary *dRandyPosicion=[Baselocal getalldatafromstatement:[NSString stringWithFormat:@"SELECT grupono,alumnosid,posicion FROM grupos WHERE actividad=\"%@\" ORDER BY grupono,posicion ASC",actividad] campos:randybase];
    NSLog(@"info%@",dRandyPosicion);
     NSMutableDictionary *listafinal=[[NSMutableDictionary alloc]init];

    NSArray *alumnosids=[dRandyPosicion objectForKey:@"alumnosid"];
     NSArray *grupo=[dRandyPosicion objectForKey:@"grupono"];
     NSArray *posicion=[dRandyPosicion objectForKey:@"posicion"];
    
    if ([alumnosids count]>0) {
        NSMutableArray *ArID=[[NSMutableArray alloc]init];
        NSMutableArray *ArGrupo=[[NSMutableArray alloc]init];
        NSMutableArray *ArPosicion=[[NSMutableArray alloc]init];
        NSMutableArray *ArNombre=[[NSMutableArray alloc]init];
        NSMutableArray *ArStudentid=[[NSMutableArray alloc]init];

        for (int a =0; a<=[alumnosids count]-1; a++) {
            [ArID addObject:[NSString stringWithFormat:@"%i",a+1]];
            [ArGrupo addObject:[grupo objectAtIndex:a]];
            NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"%@\" GROUP BY alumnosid",[alumnosids objectAtIndex:a],[posicion objectAtIndex:a]]];
            [ArPosicion addObject:[NSString stringWithFormat:@"%@(%@)",[posicion objectAtIndex:a],veces]];
            NSString *Nombre=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT nombre FROM estudiantes WHERE studentid=\"%@\"",[alumnosids objectAtIndex:a]]];
            NSString *Apellido=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT apellido FROM estudiantes WHERE studentid=\"%@\"",[alumnosids objectAtIndex:a]]];
            [ArNombre addObject:[NSString stringWithFormat:@"%@ %@",Nombre,Apellido]];
            [ArStudentid addObject:[NSString stringWithFormat:@"%@",[alumnosids objectAtIndex:a]]];
            
        }
        NSArray *ArArID=[NSArray arrayWithArray:ArID];
        NSArray *ArArGrupo=[NSArray arrayWithArray:ArGrupo];
        NSArray *ArArPosicion=[NSArray arrayWithArray:ArPosicion];
        NSArray *ArArNombre=[NSArray arrayWithArray:ArNombre];
        NSArray *ArArStudentId=[NSArray arrayWithArray:ArStudentid];
        [listafinal setObject:ArArID forKey:@"Id"];
        [listafinal setObject:ArArGrupo forKey:@"Grupo"];
        [listafinal setObject:ArArPosicion forKey:@"Posicion"];
        [listafinal setObject:ArArNombre forKey:@"Nombre"];
        [listafinal setObject:ArArStudentId forKey:@"Studentid"];
    }
    
    NSDictionary *entregable=[NSDictionary dictionaryWithDictionary:listafinal];
    [valores setObject:entregable forKey:@"Randeo"];
    return entregable;
    
}


-(IBAction)save:(id)sender{
    //NSLog(@"Ejecute Save");
    if (![TfStudent.text isEqualToString:@""]) {
        //NSLog(@"Pase 1");
        if (![TfFirstName.text isEqualToString:@""]) {
            //NSLog(@"Pase 2");
            if (![TfLastName.text isEqualToString:@""]) {
                //NSLog(@"Pase 3");
                if (![TfEmailName.text isEqualToString:@""]) {
                    //NSLog(@"Pase 4");
                    NSArray *estudiante=[NSArray arrayWithObjects:TfStudent.text,TfFirstName.text,TfLastName.text,TfEmailName.text,@"0",nil];
                    //NSLog(@"revision %@_%@",[valores objectForKey:@"BDLocalSES"],estudiante);
                    [Baselocal revisarBD:[valores objectForKey:@"BDLocalSES"] Valores:estudiante Testigo:@"studentid" Tabla:@"estudiantes" Campo:@"studentid" Nombre:TfStudent.text];
                    [TAlumnos cargartablas:[sub titidc1c2subc3c4c5:[Baselocal getalltablesfromDB:@"estudiantes" campos:[valores objectForKey:@"BDLocalES"]] c1:@"Nombre" c2:@"Apellido" c3:@"Studentid" c4:@"Email" c5:@"Participaciones"]];

                    TfFirstName.text=@"";
                    TfLastName.text=@"";
                    TfEmailName.text=@"";
                    TfStudent.text=@"";
                    
                }
            }
        }
    }
    
    
    
}
-(IBAction)modify:(id)sender{
    //NSLog(@"Ejecute Save");
    if (![TfStudent.text isEqualToString:@""]) {
        //NSLog(@"Pase 1");
        if (![TfFirstName.text isEqualToString:@""]) {
            //NSLog(@"Pase 2");
            if (![TfLastName.text isEqualToString:@""]) {
                //NSLog(@"Pase 3");
                if (![TfEmailName.text isEqualToString:@""]) {
                    //NSLog(@"Pase 4");
                    //NSArray *estudiante=[NSArray arrayWithObjects:TfStudent.text,TfFirstName.text,TfLastName.text,TfEmailName.text,@"0",nil];
                    //NSLog(@"revision %@_%@",[valores objectForKey:@"BDLocalSES"],estudiante);
                    [Baselocal update:[NSString stringWithFormat:@"UPDATE estudiantes SET nombre =\"%@\",apellido =\"%@\",email =\"%@\" WHERE studentid =\"%@\"",TfFirstName.text,TfLastName.text,TfEmailName.text,TfStudent.text]];
                    
                    [TAlumnos cargartablas:[sub titidc1c2subc3c4c5:[Baselocal getalltablesfromDB:@"estudiantes" campos:[valores objectForKey:@"BDLocalES"]] c1:@"Nombre" c2:@"Apellido" c3:@"Studentid" c4:@"Email" c5:@"Participaciones"]];

                    
                }
            }
        }
    }
}
-(IBAction)deleteid:(id)sender{
    [Baselocal update:[NSString stringWithFormat:@"DELETE FROM estudiantes WHERE studentid =\"%@\"",TfStudent.text]];
    TfFirstName.text=@"";
    TfLastName.text=@"";
    TfEmailName.text=@"";
    TfStudent.text=@"";
    [TAlumnos cargartablas:[sub titidc1c2subc3c4c5:[Baselocal getalltablesfromDB:@"estudiantes" campos:[valores objectForKey:@"BDLocalES"]] c1:@"Nombre" c2:@"Apellido" c3:@"Studentid" c4:@"Email" c5:@"Participaciones"]];

}

- (NSArray *) shuffled:(NSArray*)array
{
	// create temporary autoreleased mutable array
    NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[array count]];
    for (id anObject in array)
	{
		NSUInteger randomPos = arc4random()%([tmpArray count]+1);
		[tmpArray insertObject:anObject atIndex:randomPos];
	}
	return [NSArray arrayWithArray:tmpArray];  // non-mutable autoreleased copy
}


-(IBAction)group2:(id)sender{
    [TGrupos cargartablas:[sub titidc1c2subc3c4:[self Randear:2] c1:@"Grupo" c2:@"Nombre" c3:@"Posicion" c4:@"Studentid"]];
}
-(IBAction)group3:(id)sender{
    [TGrupos cargartablas:[sub titidc1c2subc3c4:[self Randear:3] c1:@"Grupo" c2:@"Nombre" c3:@"Posicion" c4:@"Studentid"]];
}
-(IBAction)group4:(id)sender{
    [TGrupos cargartablas:[sub titidc1c2subc3c4:[self Randear:4] c1:@"Grupo" c2:@"Nombre" c3:@"Posicion" c4:@"Studentid"]];
}
-(IBAction)group5:(id)sender{
    [TGrupos cargartablas:[sub titidc1c2subc3c4:[self Randear:5] c1:@"Grupo" c2:@"Nombre" c3:@"Posicion" c4:@"Studentid"]];
}
-(IBAction)group6:(id)sender{
    [TGrupos cargartablas:[sub titidc1c2subc3c4:[self Randear:6] c1:@"Grupo" c2:@"Nombre" c3:@"Posicion" c4:@"Studentid"]];
}





/*-(NSDictionary*)Randear:(int)entero{
    
    NSArray *randybase=[NSArray arrayWithObjects:@"alumnosid",@"calificacion", nil];
    NSDictionary *dRandyBase=[Baselocal getalldatafromstatement:@"SELECT alumnosid,SUM(calificacion) FROM grupos GROUP BY alumnosid ORDER BY SUM(calificacion) DESC" campos:randybase];
    NSLog(@"Randeo1%@",dRandyBase);

    
    NSDictionary *tdalumnos=[Baselocal getalltablesfromDB:@"estudiantes" campos:[valores objectForKey:@"BDLocalES"]];
     //Si existen antecedentes
    NSMutableDictionary *listafinal=[[NSMutableDictionary alloc]init];
    NSMutableArray *ArID=[[NSMutableArray alloc]init];
    NSMutableArray *ArGrupo=[[NSMutableArray alloc]init];
    NSMutableArray *ArPosicion=[[NSMutableArray alloc]init];
    NSMutableArray *ArNombre=[[NSMutableArray alloc]init];
    NSMutableArray *ArStudentid=[[NSMutableArray alloc]init];
    
    NSUInteger countal=[[tdalumnos objectForKey:@"Nombre"] count];
    //NSLog(@"Existen %i alumnos",countal);
    //Si no existen antecedentes
    
    if (countal>0) {
        NSArray *alumnado=[sub DictoArrayc1c2c3:tdalumnos c1:@"Nombre" c2:@"Apellido" c3:@"Studentid"];
        //NSLog(@"la informacion es %@",alumnado);
        NSArray *shuf1=[self shuffled:alumnado];
        NSArray *shuf2=[self shuffled:shuf1];
        //NSLog(@"la informacion2 es %@",shuf2);
        float conteo=countal;
        float entero1=entero;
        float division=conteo/entero1;
        //NSLog(@"ladivision es %f",division);
        int e=0;
        for (int a=0; a<=entero-1; a++) {
            int c=division*a;
            int d=0;
            for (int b=c; b<=((division)*(a+1))-1; b++) {
                [ArID addObject:[NSString stringWithFormat:@"%i",e+1]];
                [ArGrupo addObject:[NSString stringWithFormat:@"G%i",a+1]];
                NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"Rol %i\" GROUP BY alumnosid",[[shuf2 objectAtIndex:b] objectAtIndex:2],d+1]];
                [ArPosicion addObject:[NSString stringWithFormat:@"Rol %i(%@)",d+1,veces]];
                [ArNombre addObject:[NSString stringWithFormat:@"%@ %@",[[shuf2 objectAtIndex:b] objectAtIndex:0],[[shuf2 objectAtIndex:b] objectAtIndex:1]]];
                [ArStudentid addObject:[NSString stringWithFormat:@"%@",[[shuf2 objectAtIndex:b] objectAtIndex:2]]];
                d++;
                e++;
            }

        }
        NSArray *ArArID=[NSArray arrayWithArray:ArID];
        NSArray *ArArGrupo=[NSArray arrayWithArray:ArGrupo];
        NSArray *ArArPosicion=[NSArray arrayWithArray:ArPosicion];
        NSArray *ArArNombre=[NSArray arrayWithArray:ArNombre];
        NSArray *ArArStudentId=[NSArray arrayWithArray:ArStudentid];
        [listafinal setObject:ArArID forKey:@"Id"];
        [listafinal setObject:ArArGrupo forKey:@"Grupo"];
        [listafinal setObject:ArArPosicion forKey:@"Posicion"];
        [listafinal setObject:ArArNombre forKey:@"Nombre"];
        [listafinal setObject:ArArStudentId forKey:@"Studentid"];
        
    }
    NSDictionary *entregable=[NSDictionary dictionaryWithDictionary:listafinal];
    [valores setObject:entregable forKey:@"Randeo"];
    return entregable;
    
}*/
-(NSDictionary*)createalumnos:(NSArray*)arreglo{
    NSMutableDictionary *funcionamiento=[[NSMutableDictionary alloc]init];
    NSMutableArray *Nombre=[[NSMutableArray alloc]init];
    NSMutableArray *Apellido=[[NSMutableArray alloc]init];
    NSMutableArray *StudentId=[[NSMutableArray alloc]init];
    if ([arreglo count]>0) {
        for (int a=0; a<=[arreglo count]-1; a++) {
            [Nombre addObject:[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT nombre FROM estudiantes WHERE studentid=\"%@\"",[arreglo objectAtIndex:a]]]];
            [Apellido addObject:[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT apellido FROM estudiantes WHERE studentid=\"%@\"",[arreglo objectAtIndex:a]]]];
            [StudentId addObject:[arreglo objectAtIndex:a]];
        }
    }
    NSArray *ArNombre=[NSArray arrayWithArray:Nombre];
    NSArray *ArApellido=[NSArray arrayWithArray:Apellido];
    NSArray *ArStudentId=[NSArray arrayWithArray:StudentId];
    [funcionamiento setObject:ArNombre forKey:@"Nombre"];
    [funcionamiento setObject:ArApellido forKey:@"Apellido"];
    [funcionamiento setObject:ArStudentId forKey:@"Studentid"];

    NSDictionary *final=[NSDictionary dictionaryWithDictionary:funcionamiento];
    return final;
}
-(NSDictionary*)Randear:(int)entero{
    
    NSArray *randybase=[NSArray arrayWithObjects:@"alumnosid",@"calificacion", nil];
    NSDictionary *dRandyBase=[Baselocal getalldatafromstatement:@"SELECT alumnosid,SUM(calificacion) FROM grupos GROUP BY alumnosid ORDER BY SUM(calificacion) DESC" campos:randybase];
    
    
    NSDictionary *dCalificaciones=[Baselocal getalldatafromstatement:@"SELECT calificacion FROM grupos GROUP BY calificacion ORDER BY calificacion DESC" campos:[NSArray arrayWithObjects:@"calificacion", nil]];
    NSLog(@"CANTIDAD %lu",(unsigned long)[dCalificaciones count]);
    
    NSLog(@"Randeo1%@",dRandyBase);
    NSDictionary *tdalumnos=[[NSDictionary alloc]init];
    NSUInteger countal=0;
    NSArray *nnalumnos=[dRandyBase objectForKey:@"alumnosid"];

    
    BOOL antecedentes=FALSE;
    if ([nnalumnos count]>0) {
    //Si existen antecedentes
        if ([dCalificaciones count]>1) {
            tdalumnos=[self createalumnos:nnalumnos];
            countal=[[tdalumnos objectForKey:@"Nombre"] count];
            antecedentes=TRUE;
        }
        else{
            tdalumnos=[Baselocal getalltablesfromDB:@"estudiantes" campos:[valores objectForKey:@"BDLocalES"]];
            countal=[[tdalumnos objectForKey:@"Nombre"] count];
            antecedentes=FALSE;
        }
    
    }
    else{
 
    //Si no existen antecedentes
    tdalumnos=[Baselocal getalltablesfromDB:@"estudiantes" campos:[valores objectForKey:@"BDLocalES"]];
    countal=[[tdalumnos objectForKey:@"Nombre"] count];
        antecedentes=FALSE;
    }

    
    NSMutableDictionary *listafinal=[[NSMutableDictionary alloc]init];
    NSMutableArray *ArID=[[NSMutableArray alloc]init];
    NSMutableArray *ArGrupo=[[NSMutableArray alloc]init];
    NSMutableArray *ArPosicion=[[NSMutableArray alloc]init];
    NSMutableArray *ArNombre=[[NSMutableArray alloc]init];
    NSMutableArray *ArStudentid=[[NSMutableArray alloc]init];
    
    if (antecedentes) {
        float conteo=countal;
        float entero1=entero;
        float division=conteo/entero1;
        NSLog(@"conteo,entero1,division %f,%f,%f",conteo,entero1,division);
        NSMutableArray *grupos=[[NSMutableArray alloc] init];
        NSArray *tal=[tdalumnos objectForKey:@"Studentid"];
        NSMutableArray *remanentes=[[NSMutableArray alloc]init];
        NSMutableArray *nuevos=[[NSMutableArray alloc]init];
        
        for (int a=0; a<=entero-1; a++) {
            NSMutableArray *participantes=[[NSMutableArray alloc]init];
            [grupos addObject:participantes];
        }
        if (entero1>1) {
            for (int c=0; c<=[tal count]-1; c++) {
                [remanentes addObject:[tal objectAtIndex:c]];
            }
            nuevos=[remanentes copy];
            if (division>=2) {
            //Place Tops
                for (int a=0; a<=entero1-1; a++) {
                    NSString *info=[nuevos objectAtIndex:0];
                    [[grupos objectAtIndex:a] addObject:info];
                    if ([nuevos count]>0){
                        [remanentes removeAllObjects];
                        for (int b=1; b<=[nuevos count]-1; b++) {
                            [remanentes addObject:[nuevos objectAtIndex:b]];
                        }
                        nuevos=[remanentes copy];
                    }
                }
            NSLog(@"Nuevo Nuevos %@",nuevos);
            //Place Downs
                for (int a=0; a<=entero1-1; a++) {
                    NSString *info=[nuevos objectAtIndex:[nuevos count]-1];
                    [[grupos objectAtIndex:a] addObject:info];
                    if ([nuevos count]>0) {
                        [remanentes removeAllObjects];
                        for (int b=0; b<=[nuevos count]-2; b++) {
                            
                            [remanentes addObject:[nuevos objectAtIndex:b]];
                        }
                        nuevos=[remanentes copy];
                    }
                }
                int repeticiones=(conteo-(entero1*2))/(entero1*2);
                NSLog(@"numerorep %i",repeticiones);
                if (repeticiones>0) {
                    for (int f=0; f<=repeticiones-1; f++) {
                    //Place Tops
                    for (int a=0; a<=entero1-1; a++) {
                        NSString *info=[nuevos objectAtIndex:0];
                        [[grupos objectAtIndex:a] addObject:info];
                        if ([nuevos count]>0){
                            [remanentes removeAllObjects];
                            for (int b=1; b<=[nuevos count]-1; b++) {
                                [remanentes addObject:[nuevos objectAtIndex:b]];
                            }
                            nuevos=[remanentes copy];
                        }
                    }
                    //Place Downs
                    for (int a=0; a<=entero1-1; a++) {
                        NSString *info=[nuevos objectAtIndex:[nuevos count]-1];
                        [[grupos objectAtIndex:a] addObject:info];
                        if ([nuevos count]>0) {
                            [remanentes removeAllObjects];
                            for (int b=0; b<=[nuevos count]-2; b++) {
                                [remanentes addObject:[nuevos objectAtIndex:b]];
                            }
                            nuevos=[remanentes copy];
                        }
                    }
                    }
                }
                else{
                    
                }
                
            }
            else{
            }
           
        }
        
        if ([remanentes count]>=  entero1) {
            for (int a=0; a<=entero1-1; a++) {
                NSString *info=[nuevos objectAtIndex:0];
                [[grupos objectAtIndex:a] addObject:info];
                if ([nuevos count]>0){
                    [remanentes removeAllObjects];
                    for (int b=1; b<=[nuevos count]-1; b++) {
                        [remanentes addObject:[nuevos objectAtIndex:b]];
                    }
                    nuevos=[remanentes copy];
                }
            }

        }
        NSMutableArray *gruposadicionales=[[NSMutableArray alloc]init];
        int testigo=0;
        for (int g=0; g<=entero1-1; g++) {
            int idivi=division;
            int objetos=((division*(g+1))-(idivi*(g+1)));
            int real=objetos-testigo;
            NSLog(@"AA%i,AA%i,AA%i",idivi,objetos,real);
            if (real>=1) {
                [gruposadicionales addObject:[NSString stringWithFormat:@"%i",g+1]];
                testigo++;
            }
            
        }
        if ([gruposadicionales count]>0) {
            for (int h=0; h<=[gruposadicionales count]-1; h++) {
                    NSString *info=[nuevos objectAtIndex:0];
                    int tt=[[gruposadicionales objectAtIndex:h] intValue]-1;
                    [[grupos objectAtIndex:tt] addObject:info];
                    if ([nuevos count]>0){
                        [remanentes removeAllObjects];
                        for (int b=1; b<=[nuevos count]-1; b++) {
                            [remanentes addObject:[nuevos objectAtIndex:b]];
                        }
                        nuevos=[remanentes copy];
                }
            }
        }
        NSLog(@"Grupos adic%@",gruposadicionales);
        NSLog(@"RemanentesC%@",nuevos);
        NSLog(@"GRUPOS%@",grupos);
        
        //GET RANDY GROUPS VALUE
        if (entero1>1) {
        NSMutableArray *ordengrupos=[[NSMutableArray alloc]init];
        NSMutableArray *gruposr=[[NSMutableArray alloc]init];
        NSMutableArray *gruposn=[grupos copy];
        
        for (int i=0; i<=entero1-1; i++) {
            int maximo=0;
            int nngrupo=0;
            if ([gruposn count]>0) {
                for (int j=0; j<=[gruposn count]-1; j++) {
                    int sumatoria=0;
                    NSMutableArray* temporal=[gruposn objectAtIndex:j];
                    if ([temporal count]>0) {
                        for (int k=0; k<=[temporal count]-1; k++) {
                           NSString *NumGroup=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT count(grupono) FROM grupos WHERE grupono =\"G%i\" AND alumnosid=\"%@\"",i+1,[temporal objectAtIndex:k]]];
                            NSLog(@"%i,Sumatoria (%@),%@",i,NumGroup,[temporal objectAtIndex:k]);
                            sumatoria=[NumGroup intValue]+sumatoria;
                            
                        }
                        NSLog(@"Sumatoria (%i)",sumatoria);
                    }
                    if (maximo==0) {
                        maximo=sumatoria;
                        nngrupo=j;
                    }
                    else if (maximo>sumatoria){
                        maximo=sumatoria;
                        nngrupo=j;
                    }
                }
            }
            NSLog(@"SELECCIONADO (%i)",nngrupo);
            [ordengrupos addObject:[gruposn objectAtIndex:nngrupo]];
            if ([gruposn count]>0) {
                for (int b=0; b<=[gruposn count]-1; b++) {
                    if (b!=nngrupo) {
                        [gruposr addObject:[gruposn objectAtIndex:b]];
                    }
                }
                gruposn=[gruposr copy];
                [gruposr removeAllObjects];
            }
        }
         NSLog(@"ORDGRUPOS%@",ordengrupos);

        //GET RANDY ROLES VALUE
        if (countal>0) {
            if ([ordengrupos count]>0) {
                NSMutableArray *finalinfo=[[NSMutableArray alloc]init];
                for (int l=0; l<=[ordengrupos count]-1; l++) {

                    NSArray* temporalA=[ordengrupos objectAtIndex:l];
                    NSMutableArray *posicionfinal=[[NSMutableArray alloc]init];
                    NSMutableArray *remanentesusu=[[NSMutableArray alloc]init];
                    NSMutableArray *ttnuevos=[temporalA copy];
                    if ([temporalA count]>0) {
                        for (int m=0; m<=[temporalA count]-1; m++) {
                            int maximo=0;
                            int nnpart=0;
                            NSLog(@"ttnuevos,%lu",(unsigned long)[ttnuevos count]);
                            if ([ttnuevos count]>0) {
                                for (int n=0; n<=[ttnuevos count]-1; n++) {
                                    NSString *NumGroup=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT count(posicion) FROM grupos WHERE posicion =\"Rol %i\" AND alumnosid=\"%@\"",m+1,[ttnuevos objectAtIndex:n]]];
                                    NSLog(@"Grupos,%@ USuario %@",NumGroup,[ttnuevos objectAtIndex:n]);
                                    if (maximo==0) {
                                        maximo=[NumGroup intValue];
                                        nnpart=n;
                                    }
                                    else if (maximo>[NumGroup intValue]){
                                        maximo=[NumGroup intValue];
                                        nnpart=n;
                                    }
                                    
                                }
                            }
                            NSLog(@"SELECTO%i",nnpart);
                            [posicionfinal addObject:[ttnuevos objectAtIndex:nnpart]];
                            if ([ttnuevos count]>0) {
                                for (int o=0; o<=[ttnuevos count]-1; o++) {
                                    if (o!=nnpart) {
                                        [remanentesusu addObject:[ttnuevos objectAtIndex:o]];
                                    }
                                }
                                ttnuevos=[remanentesusu copy];
                                [remanentesusu removeAllObjects];
                            }
                            
                            
                        }
                    }
                    NSLog(@"posicionfinal%@",posicionfinal);
                    [finalinfo addObject:posicionfinal];
                    
                    
                   
                    
                }
                NSLog(@"FINAL FINAL%@",finalinfo);
                int base=1;
                if ([finalinfo count]>0) {
                    for (int z=0;z<=[finalinfo count]-1; z++) {
                        NSArray *tfin=[finalinfo objectAtIndex:z];
                        if ([tfin count]>0) {
                            for (int y=0; y<=[tfin count]-1; y++) {
                                [ArID addObject:[NSString stringWithFormat:@"%i",base]];
                                [ArGrupo addObject:[NSString stringWithFormat:@"G%i",z+1]];
                                NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"Rol %i\" GROUP BY alumnosid",[tfin objectAtIndex:y],y+1]];
                                [ArPosicion addObject:[NSString stringWithFormat:@"Rol %i(%@)",y+1,veces]];
                                
                                NSString *Nombre=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT nombre FROM estudiantes WHERE studentid=\"%@\"",[tfin objectAtIndex:y]]];
                                NSString *Apellido=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT apellido FROM estudiantes WHERE studentid=\"%@\"",[tfin objectAtIndex:y]]];
                                [ArNombre addObject:[NSString stringWithFormat:@"%@ %@",Nombre,Apellido]];
                                [ArStudentid addObject:[NSString stringWithFormat:@"%@",[tfin objectAtIndex:y]]];

                            }
                        }
                    }
                }
            }
            
            
            NSArray *ArArID=[NSArray arrayWithArray:ArID];
            NSArray *ArArGrupo=[NSArray arrayWithArray:ArGrupo];
            NSArray *ArArPosicion=[NSArray arrayWithArray:ArPosicion];
            NSArray *ArArNombre=[NSArray arrayWithArray:ArNombre];
            NSArray *ArArStudentId=[NSArray arrayWithArray:ArStudentid];
            [listafinal setObject:ArArID forKey:@"Id"];
            [listafinal setObject:ArArGrupo forKey:@"Grupo"];
            [listafinal setObject:ArArPosicion forKey:@"Posicion"];
            [listafinal setObject:ArArNombre forKey:@"Nombre"];
            [listafinal setObject:ArArStudentId forKey:@"Studentid"];
        }
        }
        else if (entero==1) {
            NSLog(@"Ejecuto");
            NSArray* alumnid=[tdalumnos objectForKey:@"Studentid"];;
            NSLog(@"%@",alumnid);
            for (int tt=0; tt<=[alumnid count]-1; tt++) {
                NSLog(@"%i",tt);
                    [ArID addObject:[NSString stringWithFormat:@"%i",tt+1]];
                    [ArGrupo addObject:[NSString stringWithFormat:@"G1"]];
                    NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"Rol %i\" GROUP BY alumnosid",[alumnid objectAtIndex:tt],tt+1]];
                NSLog(@"veces %@",veces);
                    [ArPosicion addObject:[NSString stringWithFormat:@"Rol %i(%@)",tt+1,veces]];
                    NSString *Nombre=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT nombre FROM estudiantes WHERE studentid=\"%@\"",[alumnid objectAtIndex:tt]]];
                    NSString *Apellido=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT apellido FROM estudiantes WHERE studentid=\"%@\"",[alumnid objectAtIndex:tt]]];
                    [ArNombre addObject:[NSString stringWithFormat:@"%@ %@",Nombre,Apellido]];
                    [ArStudentid addObject:[NSString stringWithFormat:@"%@",[alumnid objectAtIndex:tt]]];
                    
            }
        NSArray *ArArID=[NSArray arrayWithArray:ArID];
        NSArray *ArArGrupo=[NSArray arrayWithArray:ArGrupo];
        NSArray *ArArPosicion=[NSArray arrayWithArray:ArPosicion];
        NSArray *ArArNombre=[NSArray arrayWithArray:ArNombre];
        NSArray *ArArStudentId=[NSArray arrayWithArray:ArStudentid];
        [listafinal setObject:ArArID forKey:@"Id"];
        [listafinal setObject:ArArGrupo forKey:@"Grupo"];
        [listafinal setObject:ArArPosicion forKey:@"Posicion"];
        [listafinal setObject:ArArNombre forKey:@"Nombre"];
        [listafinal setObject:ArArStudentId forKey:@"Studentid"];
         
        }
        
        
    }
    else{
    //Si no existen antecedentes
        if (countal>0) {
            NSArray *alumnado=[sub DictoArrayc1c2c3:tdalumnos c1:@"Nombre" c2:@"Apellido" c3:@"Studentid"];
            //NSLog(@"la informacion es %@",alumnado);
            NSArray *shuf1=[self shuffled:alumnado];
            NSArray *shuf2=[self shuffled:shuf1];
            //NSLog(@"la informacion2 es %@",shuf2);
            float conteo=countal;
            float entero1=entero;
            float division=conteo/entero1;
            //NSLog(@"ladivision es %f",division);
            int e=0;
            for (int a=0; a<=entero-1; a++) {
                int c=division*a;
                int d=0;
                    for (int b=c; b<=((division)*(a+1))-1; b++) {
                        [ArID addObject:[NSString stringWithFormat:@"%i",e+1]];
                        [ArGrupo addObject:[NSString stringWithFormat:@"G%i",a+1]];
                        NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"Rol %i\" GROUP BY alumnosid",[[shuf2 objectAtIndex:b] objectAtIndex:2],d+1]];
                        [ArPosicion addObject:[NSString stringWithFormat:@"Rol %i(%@)",d+1,veces]];
                        [ArNombre addObject:[NSString stringWithFormat:@"%@ %@",[[shuf2 objectAtIndex:b] objectAtIndex:0],[[shuf2 objectAtIndex:b] objectAtIndex:1]]];
                        [ArStudentid addObject:[NSString stringWithFormat:@"%@",[[shuf2 objectAtIndex:b] objectAtIndex:2]]];
                        d++;
                        e++;
                    }
            
            }
            NSArray *ArArID=[NSArray arrayWithArray:ArID];
            NSArray *ArArGrupo=[NSArray arrayWithArray:ArGrupo];
            NSArray *ArArPosicion=[NSArray arrayWithArray:ArPosicion];
            NSArray *ArArNombre=[NSArray arrayWithArray:ArNombre];
            NSArray *ArArStudentId=[NSArray arrayWithArray:ArStudentid];
            [listafinal setObject:ArArID forKey:@"Id"];
            [listafinal setObject:ArArGrupo forKey:@"Grupo"];
            [listafinal setObject:ArArPosicion forKey:@"Posicion"];
            [listafinal setObject:ArArNombre forKey:@"Nombre"];
            [listafinal setObject:ArArStudentId forKey:@"Studentid"];
        }
    }
    NSDictionary *entregable=[NSDictionary dictionaryWithDictionary:listafinal];
    [valores setObject:entregable forKey:@"Randeo"];
    return entregable;
    
}


-(NSDictionary*)goup{
    NSMutableDictionary *upo=[[NSMutableDictionary alloc]init];
    
    NSMutableArray *ArID=[[NSMutableArray alloc]init];
    NSMutableArray *ArGrupo=[[NSMutableArray alloc]init];
    NSMutableArray *ArPosicion=[[NSMutableArray alloc]init];
    NSMutableArray *ArNombre=[[NSMutableArray alloc]init];
    NSMutableArray *ArStudentid=[[NSMutableArray alloc]init];
    
    NSDictionary *randeo=[valores objectForKey:@"Randeo"];
    NSArray *AID=[randeo objectForKey:@"Id"];
    NSArray *AGrupo=[randeo objectForKey:@"Grupo"];
    NSArray *APosicion=[randeo objectForKey:@"Posicion"];
    NSArray *ANombre=[randeo objectForKey:@"Nombre"];
    NSArray *AStudentId=[randeo objectForKey:@"Studentid"];
    
    NSUInteger conteovalores=[[randeo objectForKey:@"Id"] count];
    if (conteovalores>0) {
        if ([[valores objectForKey:@"IDRandeo"]intValue]>1) {
            for (int b=0;b<=conteovalores-1;b++) {

                if([[AID objectAtIndex:b]intValue]==([[valores objectForKey:@"IDRandeo"]intValue]-1)) {
                    
                    [ArID addObject:[NSString stringWithFormat:@"%@",[AID objectAtIndex:b]]];
                    [ArGrupo addObject:[NSString stringWithFormat:@"%@",[AGrupo objectAtIndex:b]]];
                    NSRange Alto = [[APosicion objectAtIndex:b] rangeOfString:@"("];
                    NSString *ID=[[APosicion objectAtIndex:b] substringWithRange:NSMakeRange(0, Alto.location)];
                    NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"%@\" GROUP BY alumnosid ",[AStudentId objectAtIndex:b+1],ID]];
                    //NSLog(@"VVVVVVVVVVVVVVVVECES%@",veces);
                    
                    [ArPosicion addObject:[NSString stringWithFormat:@"%@(%@)",ID,veces]];
                    [ArNombre addObject:[NSString stringWithFormat:@"%@",[ANombre objectAtIndex:b+1]]];
                    [ArStudentid addObject:[NSString stringWithFormat:@"%@",[AStudentId objectAtIndex:b+1]]];
                }
                else if ([[AID objectAtIndex:b]intValue]==[[valores objectForKey:@"IDRandeo"]intValue]) {
                    [ArID addObject:[NSString stringWithFormat:@"%@",[AID objectAtIndex:b]]];
                    [ArGrupo addObject:[NSString stringWithFormat:@"%@",[AGrupo objectAtIndex:b]]];
                    NSRange Alto = [[APosicion objectAtIndex:b] rangeOfString:@"("];
                    NSString *ID=[[APosicion objectAtIndex:b] substringWithRange:NSMakeRange(0, Alto.location)];
                    NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"%@\"  GROUP BY alumnosid ",[AStudentId objectAtIndex:b-1],ID]];
                    //NSLog(@"VVVVVVVVVVVVVVVVECES%@",veces);
                    
                    
                    [ArPosicion addObject:[NSString stringWithFormat:@"%@(%@)",ID,veces]];
                    [ArNombre addObject:[NSString stringWithFormat:@"%@",[ANombre objectAtIndex:b-1]]];
                    [ArStudentid addObject:[NSString stringWithFormat:@"%@",[AStudentId objectAtIndex:b-1]]];
                    
                }
                else{
                    [ArID addObject:[NSString stringWithFormat:@"%@",[AID objectAtIndex:b]]];
                    [ArGrupo addObject:[NSString stringWithFormat:@"%@",[AGrupo objectAtIndex:b]]];
                    NSRange Alto = [[APosicion objectAtIndex:b] rangeOfString:@"("];
                    NSString *ID=[[APosicion objectAtIndex:b] substringWithRange:NSMakeRange(0, Alto.location)];
                    NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"%@\" GROUP BY alumnosid",[AStudentId objectAtIndex:b],ID]];
                    //NSLog(@"VVVVVVVVVVVVVVVVECES%@",veces);
 
                    [ArPosicion addObject:[NSString stringWithFormat:@"%@(%@)",ID,veces]];
                    [ArNombre addObject:[NSString stringWithFormat:@"%@",[ANombre objectAtIndex:b]]];
                    [ArStudentid addObject:[NSString stringWithFormat:@"%@",[AStudentId objectAtIndex:b]]];
                }
            }
            
         [valores setObject:[NSString stringWithFormat:@"%i",[[valores objectForKey:@"IDRandeo"]intValue]-1] forKey:@"IDRandeo"];
        }
        else{
            for (int b=0;b<=conteovalores-1;b++) {
                [ArID addObject:[NSString stringWithFormat:@"%@",[AID objectAtIndex:b]]];
                [ArGrupo addObject:[NSString stringWithFormat:@"%@",[AGrupo objectAtIndex:b]]];
                NSRange Alto = [[APosicion objectAtIndex:b] rangeOfString:@"("];
                NSString *ID=[[APosicion objectAtIndex:b] substringWithRange:NSMakeRange(0, Alto.location)];
                 NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"%@\" GROUP BY alumnosid",[AStudentId objectAtIndex:b],ID ]];
                //NSLog(@"VVVVVVVVVVVVVVVVECES%@",veces);
                
                [ArPosicion addObject:[NSString stringWithFormat:@"%@(%@)",ID,veces]];
                [ArNombre addObject:[NSString stringWithFormat:@"%@",[ANombre objectAtIndex:b]]];
                [ArStudentid addObject:[NSString stringWithFormat:@"%@",[AStudentId objectAtIndex:b]]];
            }
            
            
            
        [valores setObject:[NSString stringWithFormat:@"%i",[[valores objectForKey:@"IDRandeo"]intValue]] forKey:@"IDRandeo"];
        }
        NSArray *ArArID=[NSArray arrayWithArray:ArID];
        NSArray *ArArGrupo=[NSArray arrayWithArray:ArGrupo];
        NSArray *ArArPosicion=[NSArray arrayWithArray:ArPosicion];
        NSArray *ArArNombre=[NSArray arrayWithArray:ArNombre];
        NSArray *ArArStudentId=[NSArray arrayWithArray:ArStudentid];
        [upo setObject:ArArID forKey:@"Id"];
        [upo setObject:ArArGrupo forKey:@"Grupo"];
        [upo setObject:ArArPosicion forKey:@"Posicion"];
        [upo setObject:ArArNombre forKey:@"Nombre"];
        [upo setObject:ArArStudentId forKey:@"Studentid"];
        
        
        
        
    }
    
    NSDictionary *entregable=[NSDictionary dictionaryWithDictionary:upo];
    [valores setObject:entregable forKey:@"Randeo"];
    return entregable;

}
-(NSDictionary*)godown{
    NSMutableDictionary *upo=[[NSMutableDictionary alloc]init];
    
    NSMutableArray *ArID=[[NSMutableArray alloc]init];
    NSMutableArray *ArGrupo=[[NSMutableArray alloc]init];
    NSMutableArray *ArPosicion=[[NSMutableArray alloc]init];
    NSMutableArray *ArNombre=[[NSMutableArray alloc]init];
    NSMutableArray *ArStudentid=[[NSMutableArray alloc]init];
    
    NSDictionary *randeo=[valores objectForKey:@"Randeo"];
    NSArray *AID=[randeo objectForKey:@"Id"];
    NSArray *AGrupo=[randeo objectForKey:@"Grupo"];
    NSArray *APosicion=[randeo objectForKey:@"Posicion"];
    NSArray *ANombre=[randeo objectForKey:@"Nombre"];
    NSArray *AStudentId=[randeo objectForKey:@"Studentid"];
    
    NSUInteger conteovalores=[[randeo objectForKey:@"Id"] count];
    //NSLog(@"%lu",(unsigned long)conteovalores);
    if (conteovalores>0) {
        if ([[valores objectForKey:@"IDRandeo"]intValue]<=conteovalores-1) {
            for (int b=0;b<=conteovalores-1;b++) {
                
                if([[AID objectAtIndex:b]intValue]==([[valores objectForKey:@"IDRandeo"]intValue]+1)) {
                    
                    [ArID addObject:[NSString stringWithFormat:@"%@",[AID objectAtIndex:b]]];
                    [ArGrupo addObject:[NSString stringWithFormat:@"%@",[AGrupo objectAtIndex:b]]];
                    NSRange Alto = [[APosicion objectAtIndex:b] rangeOfString:@"("];
                    NSString *ID=[[APosicion objectAtIndex:b] substringWithRange:NSMakeRange(0, Alto.location)];
                    NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"%@\" GROUP BY alumnosid",[AStudentId objectAtIndex:b-1],ID ]];
                    //NSLog(@"VVVVVVVVVVVVVVVVECES%@",veces);
                    
                    [ArPosicion addObject:[NSString stringWithFormat:@"%@(%@)",ID,veces]];

                    [ArNombre addObject:[NSString stringWithFormat:@"%@",[ANombre objectAtIndex:b-1]]];
                    [ArStudentid addObject:[NSString stringWithFormat:@"%@",[AStudentId objectAtIndex:b-1]]];
                }
                else if ([[AID objectAtIndex:b]intValue]==[[valores objectForKey:@"IDRandeo"]intValue]) {
                    [ArID addObject:[NSString stringWithFormat:@"%@",[AID objectAtIndex:b]]];
                    [ArGrupo addObject:[NSString stringWithFormat:@"%@",[AGrupo objectAtIndex:b]]];
                    NSRange Alto = [[APosicion objectAtIndex:b] rangeOfString:@"("];
                    NSString *ID=[[APosicion objectAtIndex:b] substringWithRange:NSMakeRange(0, Alto.location)];
                    NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"%@\" GROUP BY alumnosid",[AStudentId objectAtIndex:b+1],ID ]];
                    //NSLog(@"VVVVVVVVVVVVVVVVECES%@",veces);
                    
                    [ArPosicion addObject:[NSString stringWithFormat:@"%@(%@)",ID,veces]];

                    [ArNombre addObject:[NSString stringWithFormat:@"%@",[ANombre objectAtIndex:b+1]]];
                    [ArStudentid addObject:[NSString stringWithFormat:@"%@",[AStudentId objectAtIndex:b+1]]];
                    
                }
                else{
                    [ArID addObject:[NSString stringWithFormat:@"%@",[AID objectAtIndex:b]]];
                    [ArGrupo addObject:[NSString stringWithFormat:@"%@",[AGrupo objectAtIndex:b]]];
                    NSRange Alto = [[APosicion objectAtIndex:b] rangeOfString:@"("];
                    NSString *ID=[[APosicion objectAtIndex:b] substringWithRange:NSMakeRange(0, Alto.location)];
                    NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"%@\" GROUP BY alumnosid",[AStudentId objectAtIndex:b],ID ]];
                    //NSLog(@"VVVVVVVVVVVVVVVVECES%@",veces);
                    
                    [ArPosicion addObject:[NSString stringWithFormat:@"%@(%@)",ID,veces]];

                    [ArNombre addObject:[NSString stringWithFormat:@"%@",[ANombre objectAtIndex:b]]];
                    [ArStudentid addObject:[NSString stringWithFormat:@"%@",[AStudentId objectAtIndex:b]]];
                }
            }
            [valores setObject:[NSString stringWithFormat:@"%i",[[valores objectForKey:@"IDRandeo"]intValue]+1] forKey:@"IDRandeo"];
            
        }
        else{
            for (int b=0;b<=conteovalores-1;b++) {
                [ArID addObject:[NSString stringWithFormat:@"%@",[AID objectAtIndex:b]]];
                [ArGrupo addObject:[NSString stringWithFormat:@"%@",[AGrupo objectAtIndex:b]]];
                NSRange Alto = [[APosicion objectAtIndex:b] rangeOfString:@"("];
                NSString *ID=[[APosicion objectAtIndex:b] substringWithRange:NSMakeRange(0, Alto.location)];
                NSString *veces=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT COUNT(posicion) FROM grupos WHERE alumnosid=\"%@\" AND posicion=\"%@\" GROUP BY alumnosid",[AStudentId objectAtIndex:b],ID ]];
                //NSLog(@"VVVVVVVVVVVVVVVVECES%@",veces);
                
                [ArPosicion addObject:[NSString stringWithFormat:@"%@(%@)",ID,veces]];
                [ArNombre addObject:[NSString stringWithFormat:@"%@",[ANombre objectAtIndex:b]]];
                [ArStudentid addObject:[NSString stringWithFormat:@"%@",[AStudentId objectAtIndex:b]]];
            }

            [valores setObject:[NSString stringWithFormat:@"%i",[[valores objectForKey:@"IDRandeo"]intValue]] forKey:@"IDRandeo"];
        }
        NSArray *ArArID=[NSArray arrayWithArray:ArID];
        NSArray *ArArGrupo=[NSArray arrayWithArray:ArGrupo];
        NSArray *ArArPosicion=[NSArray arrayWithArray:ArPosicion];
        NSArray *ArArNombre=[NSArray arrayWithArray:ArNombre];
        NSArray *ArArStudentId=[NSArray arrayWithArray:ArStudentid];
        [upo setObject:ArArID forKey:@"Id"];
        [upo setObject:ArArGrupo forKey:@"Grupo"];
        [upo setObject:ArArPosicion forKey:@"Posicion"];
        [upo setObject:ArArNombre forKey:@"Nombre"];
        [upo setObject:ArArStudentId forKey:@"Studentid"];
        

    }
    
    NSDictionary *entregable=[NSDictionary dictionaryWithDictionary:upo];
    [valores setObject:entregable forKey:@"Randeo"];
    return entregable;
    
}





-(IBAction)group1:(id)sender{
    //NSLog(@"Ejecute 1   %@",[valores objectForKey:@"ParticipantID"]);
    
    NSString *participaciones=[Baselocal getselecteddatafromstatement:[NSString stringWithFormat:@"SELECT participaciones FROM estudiantes WHERE id=\"%@\"",[valores objectForKey:@"ParticipantID"]]];
    //NSLog(@"Participaciones 1   %@",participaciones);
    float total=[participaciones intValue]+1;
    [Baselocal update:[NSString stringWithFormat:@"UPDATE estudiantes SET participaciones =\"%f\" WHERE id =\"%@\"",total,[valores objectForKey:@"ParticipantID"]]];
    [TAlumnos cargartablas:[sub titidc1c2subc3c4c5:[Baselocal getalltablesfromDB:@"estudiantes" campos:[valores objectForKey:@"BDLocalES"]] c1:@"Nombre" c2:@"Apellido" c3:@"Studentid" c4:@"Email" c5:@"Participaciones"]];
    
}


//Funciones
-(IBAction)newclass:(id)sender{
    
}
-(IBAction)newrandy:(id)sender{
    NSDictionary *tdalumnos=[[NSDictionary alloc]init];
    float participaciones=[[Baselocal getselecteddatafromstatement:@"SELECT MAX(participaciones) FROM estudiantes"] floatValue];
    if (participaciones==0) {
        tdalumnos=[Baselocal getalldatafromstatement:[NSString stringWithFormat:@"SELECT * FROM estudiantes"] campos:[valores objectForKey:@"BDLocalES"]];
    }
    else{
        tdalumnos=[Baselocal getalldatafromstatement:[NSString stringWithFormat:@"SELECT * FROM estudiantes WHERE participaciones<\"%f\"",participaciones] campos:[valores objectForKey:@"BDLocalES"]];
        
    }
    NSUInteger countal=[[tdalumnos objectForKey:@"Nombre"] count];
    if (countal>0) {
        NSArray *alumnado=[sub DictoArrayc1c2c3:tdalumnos c1:@"Id" c2:@"Nombre" c3:@"Apellido"];
        NSArray *shuf1=[self shuffled:alumnado];
        NSArray *shuf2=[self shuffled:shuf1];
         NSArray *shuf3=[self shuffled:shuf2];
        NSArray *shuf4=[shuf3 objectAtIndex:0];
        
        LaTitle.text=[NSString stringWithFormat:@"%@_%@ %@",[shuf4 objectAtIndex:0],[shuf4 objectAtIndex:1],[shuf4 objectAtIndex:2]];
        [valores setObject:[shuf4 objectAtIndex:0] forKey:@"ParticipantID"];
        //NSLog(@"%@",[valores objectForKey:@"ParticipantID"]);
    }
    else {
        tdalumnos=[Baselocal getalldatafromstatement:[NSString stringWithFormat:@"SELECT * FROM estudiantes WHERE participaciones=\"%f\"",participaciones] campos:[valores objectForKey:@"BDLocalES"]];
        NSArray *alumnado=[sub DictoArrayc1c2c3:tdalumnos c1:@"Id" c2:@"Nombre" c3:@"Apellido"];
        NSArray *shuf1=[self shuffled:alumnado];
        NSArray *shuf2=[self shuffled:shuf1];
        NSArray *shuf3=[self shuffled:shuf2];
        NSArray *shuf4=[shuf3 objectAtIndex:0];
        
        LaTitle.text=[NSString stringWithFormat:@"%@_%@ %@",[shuf4 objectAtIndex:0],[shuf4 objectAtIndex:1],[shuf4 objectAtIndex:2]];
        [valores setObject:[shuf4 objectAtIndex:0] forKey:@"ParticipantID"];
        //NSLog(@"%@",[valores objectForKey:@"ParticipantID"]);
    }

    
    
    
}
-(IBAction)edition:(id)sender{
    //GRUPO EDICION
    BuSave.hidden=FALSE;
    BuModify.hidden=FALSE;
    BuDelete.hidden=FALSE;
    LaStudentId.hidden=FALSE;
    LaFirstName.hidden=FALSE;
    LaLastName.hidden=FALSE;
    LaEmail.hidden=FALSE;
    TfStudent.hidden=FALSE;
    TfFirstName.hidden=FALSE;
    TfLastName.hidden=FALSE;
    TfEmailName.hidden=FALSE;
    IvAlumnos.hidden=FALSE;
    TAlumnos.view.hidden=FALSE;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //GRUPO RANDY
        IvGrupos.hidden=TRUE;
        TGrupos.view.hidden=TRUE;
        TfSaveActivity.hidden=TRUE;
        BuSaveAct.hidden=TRUE;
        BuUp.hidden=TRUE;
        BuDown.hidden=TRUE;
        
        //GRUPO GRUPO
        LaGroup.hidden=TRUE;
        BuDeleteActivity.hidden=TRUE;
        TfGradeGroup.hidden=TRUE;
        BuGrade.hidden=TRUE;
        IvActividades.hidden=TRUE;
        TActividades.view.hidden=TRUE;
        
    }
    else{
        
        //GRUPO RANDY
        IvGrupos.hidden=FALSE;
        TGrupos.view.hidden=FALSE;
        TfSaveActivity.hidden=FALSE;
        BuSaveAct.hidden=FALSE;
        BuUp.hidden=FALSE;
        BuDown.hidden=FALSE;
        
        //GRUPO GRUPO
        LaGroup.hidden=FALSE;
        TfGradeGroup.hidden=FALSE;
        BuGrade.hidden=FALSE;
        BuDeleteActivity.hidden=FALSE;
        IvActividades.hidden=FALSE;
        TActividades.view.hidden=FALSE;
        
 
    }
    
    //GRAFICAS
    LaStudentPerformance.hidden=TRUE;
    grafica1.hidden=TRUE;
    grafica2.hidden=TRUE;
}
-(IBAction)graphs:(id)sender{
    

    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        //GRUPO EDICION
        BuSave.hidden=TRUE;
        BuModify.hidden=TRUE;
        BuDelete.hidden=TRUE;
        LaStudentId.hidden=TRUE;
        LaFirstName.hidden=TRUE;
        LaLastName.hidden=TRUE;
        LaEmail.hidden=TRUE;
        TfStudent.hidden=TRUE;
        TfFirstName.hidden=TRUE;
        TfLastName.hidden=TRUE;
        TfEmailName.hidden=TRUE;
        IvAlumnos.hidden=TRUE;
        TAlumnos.view.hidden=TRUE;
        
        //GRUPO RANDY
        IvGrupos.hidden=TRUE;
        TGrupos.view.hidden=TRUE;
        TfSaveActivity.hidden=TRUE;
        BuSaveAct.hidden=TRUE;
        BuUp.hidden=TRUE;
        BuDown.hidden=TRUE;
        
        //GRUPO GRUPO
        LaGroup.hidden=TRUE;
        BuDeleteActivity.hidden=TRUE;
        IvActividades.hidden=TRUE;
        TActividades.view.hidden=TRUE;
        TfGradeGroup.hidden=TRUE;
        BuGrade.hidden=TRUE;
        
        //GRAFICAS
        LaStudentPerformance.hidden=TRUE;
        grafica1.hidden=FALSE;
        grafica2.hidden=TRUE;
        
    }
    else{
        //GRUPO EDICION
        BuSave.hidden=TRUE;
        BuModify.hidden=TRUE;
        BuDelete.hidden=TRUE;
        LaStudentId.hidden=TRUE;
        LaFirstName.hidden=TRUE;
        LaLastName.hidden=TRUE;
        LaEmail.hidden=TRUE;
        TfStudent.hidden=TRUE;
        TfFirstName.hidden=TRUE;
        TfLastName.hidden=TRUE;
        TfEmailName.hidden=TRUE;
        IvAlumnos.hidden=TRUE;
        TAlumnos.view.hidden=TRUE;
        
        //GRUPO GRUPO
        LaGroup.hidden=TRUE;
        BuDeleteActivity.hidden=TRUE;
        IvActividades.hidden=TRUE;
        TActividades.view.hidden=TRUE;
        TfGradeGroup.hidden=TRUE;
        BuGrade.hidden=TRUE;
        
        //GRAFICAS
        LaStudentPerformance.hidden=FALSE;
        grafica1.hidden=FALSE;
        grafica2.hidden=FALSE;
        
    }
    
    

    
    
    
}

-(IBAction)changegroups:(id)sender{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        //GRUPO EDICION
        BuSave.hidden=TRUE;
        BuModify.hidden=TRUE;
        BuDelete.hidden=TRUE;
        LaStudentId.hidden=TRUE;
        LaFirstName.hidden=TRUE;
        LaLastName.hidden=TRUE;
        LaEmail.hidden=TRUE;
        TfStudent.hidden=TRUE;
        TfFirstName.hidden=TRUE;
        TfLastName.hidden=TRUE;
        TfEmailName.hidden=TRUE;
        IvAlumnos.hidden=TRUE;
         TAlumnos.view.hidden=TRUE;
        
        //GRUPO RANDY
        IvGrupos.hidden=TRUE;
        TGrupos.view.hidden=TRUE;
        TfSaveActivity.hidden=TRUE;
        BuSaveAct.hidden=TRUE;
        BuUp.hidden=TRUE;
        BuDown.hidden=TRUE;
        
        //GRUPO GRUPO
        LaGroup.hidden=FALSE;
        BuDeleteActivity.hidden=FALSE;
        IvActividades.hidden=FALSE;
        TActividades.view.hidden=FALSE;
        TfGradeGroup.hidden=FALSE;
        BuGrade.hidden=FALSE;
        
        //GRAFICAS
        LaStudentPerformance.hidden=TRUE;
        grafica1.hidden=TRUE;
        grafica2.hidden=TRUE;
        
    }
    else{
        //NON APPLING RESOURCE
        
    }
    
}
-(IBAction)graphs2:(id)sender{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        //GRUPO EDICION -
        BuSave.hidden=TRUE;
        BuModify.hidden=TRUE;
        BuDelete.hidden=TRUE;
        LaStudentId.hidden=TRUE;
        LaFirstName.hidden=TRUE;
        LaLastName.hidden=TRUE;
        LaEmail.hidden=TRUE;
        TfStudent.hidden=TRUE;
        TfFirstName.hidden=TRUE;
        TfLastName.hidden=TRUE;
        TfEmailName.hidden=TRUE;
        IvAlumnos.hidden=TRUE;
         TAlumnos.view.hidden=TRUE;
        
        //GRUPO RANDY -
        IvGrupos.hidden=TRUE;
        TGrupos.view.hidden=TRUE;
        TfSaveActivity.hidden=TRUE;
        BuSaveAct.hidden=TRUE;
        BuUp.hidden=TRUE;
        BuDown.hidden=TRUE;
        
        //GRUPO GRUPO -
        LaGroup.hidden=TRUE;
        BuDeleteActivity.hidden=TRUE;
        IvActividades.hidden=TRUE;
        TActividades.view.hidden=TRUE;
         TfGradeGroup.hidden=TRUE;
        BuGrade.hidden=TRUE;
        
        //GRAFICAS
        LaStudentPerformance.hidden=TRUE;
        grafica1.hidden=TRUE;
        grafica2.hidden=FALSE;
        
    }
    else{
        //GRUPO GRUPO -
        LaGroup.hidden=TRUE;
        BuDeleteActivity.hidden=TRUE;
        IvActividades.hidden=TRUE;
        TActividades.view.hidden=TRUE;
        TfGradeGroup.hidden=TRUE;
        BuGrade.hidden=TRUE;
        
        //GRAFICAS
        LaStudentPerformance.hidden=FALSE;
        grafica1.hidden=FALSE;
        grafica2.hidden=FALSE;
        
    }

    
}
-(IBAction)changerandy:(id)sender{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        
        //GRUPO EDICION -
        BuSave.hidden=TRUE;
        BuModify.hidden=TRUE;
        BuDelete.hidden=TRUE;
        LaStudentId.hidden=TRUE;
        LaFirstName.hidden=TRUE;
        LaLastName.hidden=TRUE;
        LaEmail.hidden=TRUE;
        TfStudent.hidden=TRUE;
        TfFirstName.hidden=TRUE;
        TfLastName.hidden=TRUE;
        TfEmailName.hidden=TRUE;
        IvAlumnos.hidden=TRUE;
         TAlumnos.view.hidden=TRUE;
        
        //GRUPO RANDY +
        IvGrupos.hidden=FALSE;
        TGrupos.view.hidden=FALSE;
        TfSaveActivity.hidden=FALSE;
        BuSaveAct.hidden=FALSE;
        BuUp.hidden=FALSE;
        BuDown.hidden=FALSE;
        
        //GRUPO GRUPO -
        LaGroup.hidden=TRUE;
        BuDeleteActivity.hidden=TRUE;
        IvActividades.hidden=TRUE;
        TActividades.view.hidden=TRUE;
        TfGradeGroup.hidden=TRUE;
        BuGrade.hidden=TRUE;
        
        //GRAFICAS -
        LaStudentPerformance.hidden=TRUE;
        grafica1.hidden=TRUE;
        grafica2.hidden=TRUE;
        
    }
    else{
        //GRUPO EDICION +
        BuSave.hidden=FALSE;
        BuModify.hidden=FALSE;
        BuDelete.hidden=FALSE;
        LaStudentId.hidden=FALSE;
        LaFirstName.hidden=FALSE;
        LaLastName.hidden=FALSE;
        LaEmail.hidden=FALSE;
        TfStudent.hidden=FALSE;
        TfFirstName.hidden=FALSE;
        TfLastName.hidden=FALSE;
        TfEmailName.hidden=FALSE;
        IvAlumnos.hidden=FALSE;
         TAlumnos.view.hidden=FALSE;
        
        //GRUPO RANDY +
        IvGrupos.hidden=FALSE;
        TGrupos.view.hidden=FALSE;
        TfSaveActivity.hidden=FALSE;
        BuSaveAct.hidden=FALSE;
        BuUp.hidden=FALSE;
        BuDown.hidden=FALSE;
        
        //GRUPO GRUPO +
        LaGroup.hidden=FALSE;
        BuDeleteActivity.hidden=FALSE;
        IvActividades.hidden=FALSE;
        TActividades.view.hidden=FALSE;
        TfGradeGroup.hidden=FALSE;
        BuGrade.hidden=FALSE;
        
        //GRAFICAS -
        LaStudentPerformance.hidden=TRUE;
        grafica1.hidden=TRUE;
        grafica2.hidden=TRUE;
        
    }
}

-(IBAction)deleteactivity:(id)sender{

    [Baselocal update:[NSString stringWithFormat:@"DELETE FROM grupos WHERE actividad =\"%@\"",[valores objectForKey:@"ActividadEvaluar"]]];
    [TActividades cargartablas:[sub titc1subc2c3:[Baselocal getalldatafromstatement:[NSString stringWithFormat:@"SELECT Grupono,Actividad,Calificacion FROM grupos GROUP BY Grupono,Actividad,Calificacion ORDER BY Actividad"] campos:[valores objectForKey:@"BDLocalSTAGR"]] c1:@"Grupono" c2:@"Actividad" c3:@"Calificacion"]];
    [self Graficdata];

}

-(IBAction)upup:(id)sender{
    
    [TGrupos cargartablas:[sub titidc1c2subc3c4:[self goup] c1:@"Grupo" c2:@"Nombre" c3:@"Posicion" c4:@"Studentid"]];
    
}
-(IBAction)down:(id)sender{
    [TGrupos cargartablas:[sub titidc1c2subc3c4:[self godown] c1:@"Grupo" c2:@"Nombre" c3:@"Posicion" c4:@"Studentid"]];

    
}
-(IBAction)exportdata:(id)sender{
    
}
-(IBAction)gradegroup:(id)sender{
    if (![TfGradeGroup.text isEqualToString:@""]) {

    NSString *ssgrupono=[valores objectForKey:@"GrupoNoEvaluar"];
    NSString *ssactividad=[valores objectForKey:@"ActividadEvaluar"];
    
    [Baselocal update:[NSString stringWithFormat:@"UPDATE grupos SET calificacion =\"%f\" WHERE grupono =\"%@\" AND actividad =\"%@\" ",[TfGradeGroup.text floatValue],ssgrupono,ssactividad]];
        [self Graficdata];
}
    [TActividades cargartablas:[sub titc1subc2c3:[Baselocal getalldatafromstatement:[NSString stringWithFormat:@"SELECT Grupono,Actividad,Calificacion FROM grupos GROUP BY Grupono,Actividad,Calificacion ORDER BY Actividad"] campos:[valores objectForKey:@"BDLocalSTAGR"]] c1:@"Grupono" c2:@"Actividad" c3:@"Calificacion"]];
    [self Graficdata];
   


}
-(void)Graficdata{
    NSArray *rpg1=[NSArray arrayWithObjects:@"actividad", nil];
    NSDictionary *drpg1=[Baselocal getalldatafromstatement:@"SELECT actividad FROM grupos GROUP BY actividad ORDER BY actividad ASC" campos:rpg1];
    //Acumulados
    NSArray *rpg1a=[NSArray arrayWithObjects:@"actividad",@"ccalificacion",@"scalificacion", nil];
    NSDictionary *drpg1a=[Baselocal getalldatafromstatement:@"SELECT actividad,COUNT(actividad),SUM(calificacion) FROM grupos GROUP BY actividad ORDER BY actividad ASC" campos:rpg1a];
    //Campos
    NSArray *rpg1c=[NSArray arrayWithObjects:@"alumnosid",@"actividad",@"calificacion", nil];
    NSDictionary *drpg1c=[Baselocal getalldatafromstatement:@"SELECT alumnosid,actividad,SUM(calificacion) FROM grupos GROUP BY alumnosid,actividad ORDER BY actividad,alumnosid ASC"  campos:rpg1c];
    NSArray *extgra1=[NSArray arrayWithObjects:@"Campos",@"Acumulado",@"Campo",@"Valor", nil];
    
    [grafica1 setRectangulos:[sub subgraf:drpg1 acumulados:drpg1a campos:drpg1c info:rpg1 info2:rpg1a info3:rpg1c info4:extgra1]];
    [grafica1 updateview];

    
    //Roles
    NSArray *rpg2=[NSArray arrayWithObjects:@"alumnosid", nil];
    NSDictionary *drpg2=[Baselocal getalldatafromstatement:@"SELECT alumnosid FROM grupos GROUP BY alumnosid ORDER BY SUM(calificacion) DESC" campos:rpg2];
    //Acumulados
    NSArray *rpg2a=[NSArray arrayWithObjects:@"alumnosid",@"ccalificacion",@"scalificacion", nil];
    NSDictionary *drpg2a=[Baselocal getalldatafromstatement:@"SELECT alumnosid,COUNT(posicion),SUM(calificacion) FROM grupos GROUP BY alumnosid ORDER BY SUM(calificacion) DESC" campos:rpg2a];
    //Campos
    NSArray *rpg2c=[NSArray arrayWithObjects:@"posicion",@"alumnosid",@"calificacion", nil];
    NSDictionary *drpg2c=[Baselocal getalldatafromstatement:@"SELECT posicion,alumnosid,SUM(calificacion) FROM grupos GROUP BY posicion,alumnosid ORDER BY SUM(calificacion) DESC"  campos:rpg2c];
    NSArray *extgra2=[NSArray arrayWithObjects:@"Campos",@"Acumulado",@"Campo",@"Valor", nil];
    
    
    [grafica2 setRectangulos:[sub subgraf:drpg2 acumulados:drpg2a campos:drpg2c info:rpg2 info2:rpg2a info3:rpg2c info4:extgra2]];
    [grafica2 updateview];

}
-(IBAction)saveactivity:(id)sender{
    //NSLog(@"Ejecute Save");
    if (![TfSaveActivity.text isEqualToString:@""]) {
        //NSLog(@"Pase 1");
        NSDictionary *randeo=[valores objectForKey:@"Randeo"];
        NSArray *AID=[randeo objectForKey:@"Id"];
        NSArray *AGrupo=[randeo objectForKey:@"Grupo"];
        NSArray *APosicion=[randeo objectForKey:@"Posicion"];
        
        NSArray *AStudentId=[randeo objectForKey:@"Studentid"];
        NSUInteger conteo=[AID count];
        if (conteo>0) {
            for (int a=0; a<=conteo-1; a++) {
                
                NSRange Alto = [[APosicion objectAtIndex:a] rangeOfString:@"("];
                NSString *ID=[[APosicion objectAtIndex:a] substringWithRange:NSMakeRange(0, Alto.location)];
                NSArray *grupos=[NSArray arrayWithObjects:[AGrupo objectAtIndex:a],[AStudentId objectAtIndex:a],TfSaveActivity.text,ID,@"0",nil];
                //NSLog(@"revision %@_%@",[valores objectForKey:@"BDLocalSGR"],grupos);
                [Baselocal revisarBD2T:[valores objectForKey:@"BDLocalSGR"] Valores:grupos Testigo:@"id" Tabla:@"grupos" Campo:@"actividad" Nombre:TfSaveActivity.text Campo2:@"alumnosid" Nombre2:[AStudentId objectAtIndex:a]];
                
            }
        }

        [TActividades cargartablas:[sub titc1subc2c3:[Baselocal getalldatafromstatement:[NSString stringWithFormat:@"SELECT Grupono,Actividad,Calificacion FROM grupos GROUP BY Grupono,Actividad,Calificacion ORDER BY Actividad"] campos:[valores objectForKey:@"BDLocalSTAGR"]] c1:@"Grupono" c2:@"Actividad" c3:@"Calificacion"]];

        TfSaveActivity.text=@"";
    }
    [self Graficdata];
}

-(IBAction)back:(id)sender{
    [self.delegatem ClassesDidFinish:self];
}






//Textfields edition
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect textFieldRect =
    [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect =
    [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =
    midline - viewRect.origin.y
    - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator =
    (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation =
    [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}





@end
