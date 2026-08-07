//
//  BasicTable.m
//  Magma
//
//  Created by Enrique Galicia on 19/08/13.
//  Copyright (c) 2013 Enrique Galicia. All rights reserved.
//

#import "BasicTable.h"

@interface BasicTable ()

@end

@implementation BasicTable
@synthesize delegadobase=_delegadobase,tamsubtit,tamtit,funcion;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    cantidaddeelementos=0;
    valoresphp=[[NSMutableDictionary alloc]init];

}
-(void)cargartablas:(NSDictionary*)informacion{

    titulo=[informacion objectForKey:@"Titulo"];
    titulo2=[titulo copy];
    subtitulo=[informacion objectForKey:@"Subtitulo"];
    subtitulo2=[subtitulo copy];


    cantidaddeelementos=[titulo2 count];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (cantidaddeelementos>0) {
        return cantidaddeelementos;
    }
    else{
    return 1;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CountryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
	NSString *tituloss = [titulo2 objectAtIndex:indexPath.row];
	cell.textLabel.text = tituloss;
    cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
    cell.textLabel.numberOfLines = 1;
    cell.textLabel.font = [UIFont  fontWithName:@"Futura-CondensedMedium" size:tamtit];
    cell.backgroundColor=[UIColor whiteColor];
    
    NSString *subtituloss =  [subtitulo objectAtIndex:indexPath.row];
    cell.detailTextLabel.text=subtituloss;
    cell.detailTextLabel.numberOfLines = 2;
    cell.detailTextLabel.font = [UIFont fontWithName:@"Futura-CondensedMedium" size:tamsubtit];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSRange Alto = [cell.textLabel.text rangeOfString:@"_"];
    if (Alto.location!=2147483647) {
        NSString *ID=[cell.textLabel.text substringWithRange:NSMakeRange(0, Alto.location)];
        NSString *TareaAsignar=ID;
        [self.delegadobase setselected:TareaAsignar fun:funcion];
    }
    else{
        [self.delegadobase setselected:cell.textLabel.text fun:funcion];
    }

    
    
    
}


@end
