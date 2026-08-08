//
//  MainViewController.h
//  RandyTheStudent
//
//  Created by Enrique Galicia on 8/8/12.
//  Copyright (c) 2012 Enrique Galicia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RandytheStudent-Swift.h"


@protocol ClassesDelegate;

@interface Classes : UIViewController<basictable,ComboDelegate>{
    id<ClassesDelegate>delegateclass;
    

    IBOutlet UIButton *BuNewClass;
    IBOutlet UIButton *BuG2;
    IBOutlet UIButton *BuG3;
    IBOutlet UIButton *BuG4;
    IBOutlet UIButton *BuG5;
    IBOutlet UIButton *BuG6;
    IBOutlet UIButton *BuSel;
    IBOutlet UIButton *BuPart;
    IBOutlet UIButton *BuEdit;
    IBOutlet UIButton *BuGraph;
    IBOutlet UIButton *BuSave;
    IBOutlet UIButton *BuModify;
    IBOutlet UIButton *BuDelete;
    IBOutlet UIButton *BuUp;
    IBOutlet UIButton *BuDown;
    IBOutlet UIButton *BuExport;
    IBOutlet UIButton *BuGrade;
    IBOutlet UIButton *BuSaveAct;
    IBOutlet UIButton *BuBack;
    IBOutlet UIButton *BuDeleteActivity;
    IBOutlet UIButton *BuGraph2;
    IBOutlet UIButton *BuGroups;
    IBOutlet UIButton *BuRandy;
    
    IBOutlet UILabel *LaTitle;
    IBOutlet UILabel *LaName;
    IBOutlet UILabel *LaStudentId;
    IBOutlet UILabel *LaFirstName;
    IBOutlet UILabel *LaLastName;
    IBOutlet UILabel *LaEmail;
    IBOutlet UILabel *LaGroup;
    IBOutlet UILabel *LaStudentPerformance;
    
    IBOutlet UITextField *TfClass;
    IBOutlet UITextField *TfStudent;
    IBOutlet UITextField *TfFirstName;
    IBOutlet UITextField *TfLastName;
    IBOutlet UITextField *TfEmailName;
    IBOutlet UITextField *TfGradeGroup;
    IBOutlet UITextField *TfSaveActivity;
    
    IBOutlet UIImageView *IvBase;
    IBOutlet UIImageView *IvGrupos;
    IBOutlet UIImageView *IvAlumnos;
    IBOutlet UIImageView *IvActividades;
    
    IBOutlet InfoCharts *grafica1;
    IBOutlet InfoCharts *grafica2;

    CGFloat animatedDistance;
    

    DataBase *Baselocal;
    Subtitulados *sub;
    NSMutableDictionary *valores;
    
    ComboBox *BasesDatos;
    BasicTable *TGrupos;
    BasicTable *TAlumnos;
    BasicTable *TActividades;
    
    NSUserDefaults *prefs;
    NSString *archivo1;
    
}
@property(retain, nonatomic)NSString *archivo1;
@property(assign, nonatomic)id<ClassesDelegate> delegatem;




-(IBAction)newrandy:(id)sender;
-(IBAction)group1:(id)sender;
-(IBAction)group2:(id)sender;
-(IBAction)group3:(id)sender;
-(IBAction)group4:(id)sender;
-(IBAction)group5:(id)sender;
-(IBAction)group6:(id)sender;
-(IBAction)edition:(id)sender;
-(IBAction)graphs:(id)sender;
-(IBAction)save:(id)sender;
-(IBAction)modify:(id)sender;
-(IBAction)deleteid:(id)sender;
-(IBAction)deleteactivity:(id)sender;
-(IBAction)upup:(id)sender;
-(IBAction)down:(id)sender;
-(IBAction)exportdata:(id)sender;
-(IBAction)gradegroup:(id)sender;
-(IBAction)saveactivity:(id)sender;
-(IBAction)back:(id)sender;


-(IBAction)changegroups:(id)sender;
-(IBAction)graphs2:(id)sender;
-(IBAction)changerandy:(id)sender;


@end

@protocol ClassesDelegate
-(void)ClassesDidFinish:(Classes*)controller;
@end
