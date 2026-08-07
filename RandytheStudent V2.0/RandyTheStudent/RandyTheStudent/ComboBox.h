#import <UIKit/UIKit.h>
@protocol ComboDelegate;

@interface ComboBox : UIViewController<UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
{
    id<ComboDelegate>delegadocombo;
    UIPickerView* pickerView;
    IBOutlet UITextField* textField;
    NSMutableArray *dataArray;
    IBOutlet UIImageView* flecha;
    int activo;
    NSString *titulo;
}

-(void) setComboData:(NSMutableArray*) data; //set the picker view items
-(void) text:(NSString*) texto;
-(void) hide;
-(void) show;
@property (assign, nonatomic)int activo;
@property(nonatomic, retain)NSString *titulo;
@property (retain, nonatomic)id<ComboDelegate>delegadocombo;
@property (retain, nonatomic) NSString* selectedText; //the UITextField text
@property (retain, nonatomic) IBOutlet UITextField* textField;

-(NSString*)valordeltexto;
-(NSString*)textinside;
@end
@protocol ComboDelegate
-(void)sendselection:(NSString*)sendselection titulo:(NSString*)titulo;

@end