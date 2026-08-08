//
//  RandyMenu.h
//  RandyTheStudent
//
//  Created by Enrique Galicia on 8/21/12.
//  Copyright (c) 2012 Enrique Galicia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataBase.h"
#import "ComboBox.h"
#import "Subtitulados.h"
#import "Classes.h"
#import "Credits.h"



@interface RandyMenu : UIViewController<ComboDelegate,ClassesDelegate,CreditsDelegate>{
    IBOutlet UIButton *lclases;
    IBOutlet UITextField *NuevaClase;
    IBOutlet UIButton *Nueva;
    IBOutlet UIButton *Rename;
    IBOutlet UIButton *Credits;
    DataBase *BasedeBases;
    ComboBox *BasesDatos;
    NSMutableDictionary *valores;
    NSUserDefaults *prefs;
    IBOutlet UIImageView* IvBase;
    Subtitulados *sub;
}
-(IBAction)enterclass:(id)sender;
-(IBAction)newclass:(id)sender;
-(IBAction)renameclass:(id)sender;
-(IBAction)credits:(id)sender;
-(void)ClassesDidFinish:(Classes*)controller;
-(void)CreditsDidFinish:(Credits*)controller;


@end
