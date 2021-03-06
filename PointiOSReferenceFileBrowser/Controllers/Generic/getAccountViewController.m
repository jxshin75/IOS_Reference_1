//
//  getAccountViewController.m
//  PointiOSReferenceFileBrowser
//
//  Created by jimboyle on 7/27/13.
//  Copyright (c) 2013 PointIO. All rights reserved.
//

#import "getAccountViewController.h"
#import "MBProgressHUD.h"
#import "Common.h"


@interface getAccountViewController ()

@end

@implementation getAccountViewController


static NSString *const kPointAPIKey = @"b022de6e-9bf6-11e2-b014-12313b093415";
static NSString *const kPointAPISecret = @"NX6KLn8nQWy1mz0QI8KlNquUqEArkpqmyv5ic7Vtee2vRWGONROnqSEMSHGmYtp";

NSArray* temp;


- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _passwordTextField.text=@"Set Password";
    _passwordTextField.font = [UIFont fontWithName:@"System" size:18.0];
    _passwordTextField.textColor = [UIColor lightGrayColor];
}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"getAccountViewController viewDidAppear, and password is %@", _password);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}



#pragma mark
#pragma Text Delegate Methods

- (IBAction)dismissKeyboard: (id)sender {
    [sender resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // [textField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self textFieldShouldReturn:textField];
}





#pragma mark
#pragma Business Logic
- (IBAction)okButtonPressed:(id)sender  {
    NSLog(@"The password is %@",_password);
    
    if([[_firstNameTextField text] isEqualToString:@""]
       || [[_lastNameTextField text] isEqualToString:@""]
       || [[_emailTextField text] isEqualToString:@""]){
        UIAlertView* alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:@"Entered data is not valid. No blank fields allowed"
                              delegate:nil
                              cancelButtonTitle:@"Dismiss"
                              otherButtonTitles: nil];
        [alert show];
    } else if (_password==nil){
        UIAlertView* alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Password looks Empty, Please try to Set a Password"
                                  delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles: nil];
        [alert show];
    }
    else {
        [self getPartnerSession];
    }
 }

- (IBAction)cancelButtonPressed:(id)sender {
    [self.delegate getAccountViewControllerDidCancel:self];
}

- (void) getPartnerSession{
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        NSDictionary* params = @{
                                 @"email":@"alex@valexconsulting.com",
                                 @"password":@"Valex123",
                                 @"apikey":@"b022de6e-9bf6-11e2-b014-12313b093415"
                                 };
        
        NSMutableArray* pairs = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSString* key in params){
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
        }
        NSString* requestParams = [pairs componentsJoinedByString:@"&"];
        
        NSURLResponse* urlResponseList;
        NSError* requestErrorList;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.point.io/v2/users/preauth.json"]];
        [request setHTTPMethod:@"POST"];
        NSData* payload = [requestParams dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:payload];
        NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
        if(!response){
            UIAlertView* alert = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:@"Request response is nil"
                                  delegate:nil
                                  cancelButtonTitle:@"Dismiss"
                                  otherButtonTitles: nil];
            [alert show];
        }
        else {
            NSArray* temp = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            _partnerSession = [temp valueForKey:@"PARTNERKEY"];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self createUser];
            });
        }
    });   
}

- (void) createUser{
    
    // NSString *kPAPIKey = [Common getAppKey:@"kPointAppId"];
    // NSString *kPAPISecret = [Common getAppKey:@"keyPointAppSecret"];
    NSArray* objects = [NSArray arrayWithObjects:
                        [_emailTextField text],
                        [_firstNameTextField text],
                        [_lastNameTextField text],
                        _password,
                        kPointAPIKey,
                        kPointAPISecret,
                        nil];
    NSArray* keys = [NSArray arrayWithObjects:
                     @"email",
                     @"firstname",
                     @"lastname",
                     @"password",
                     @"appId",
                     @"appSecret",
                     nil];
    
    if (![objects count] == [keys count]){
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Invalid # of Parameters"
                                                       delegate:nil
                                              cancelButtonTitle:@"Dismiss"
                                              otherButtonTitles: nil];
        [alert show];
    }
    else {
        NSDictionary* params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        NSMutableArray* pairs = [[NSMutableArray alloc] initWithCapacity:0];
        for(NSString* key in params){
            if(params[key] == nil){
                break;
            }
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, params[key]]];
        }
        NSString* requestParams = [pairs componentsJoinedByString:@"&"];
        NSURLResponse* urlResponseList;
        NSError* requestErrorList;
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:@"https://api.point.io/v2/users/create.json"]];
        [request setHTTPMethod:@"POST"];
        NSData* payload = [requestParams dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:payload];
        [request addValue:_partnerSession forHTTPHeaderField:@"Authorization"];
        NSData* response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponseList error:&requestErrorList];
        
        if(!response){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Request response is nil"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles: nil];
            [alert show];
        }
        else {
            NSArray *temp = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingMutableContainers error:nil];
            if([[temp valueForKey:@"ERROR"]integerValue] == 1){
                NSString* message = [temp valueForKey:@"MESSAGE"];
                message = [message stringByReplacingOccurrencesOfString:@"ERROR - " withString:@""];
                UIAlertView* alert = [[UIAlertView alloc]
                                      initWithTitle:@"Error"
                                      message:message
                                      delegate:nil
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil];
                [alert show];
            } else {
                /*
                 UIAlertView* alert = [[UIAlertView alloc]
                                      initWithTitle:@"Success"
                                      message:@"Account Created"
                                      delegate:nil
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil];
                [alert show];
                */
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                [self.delegate getAccountViewController:self username:_emailTextField.text password:_password];
            }
        }
    }
}

-(NSArray*)findAllTextFieldsInView:(UIView*)view{
    NSMutableArray* textfieldarray = [[NSMutableArray alloc] init];
    for(id x in [view subviews]){
        if([x isKindOfClass:[UITextField class]])
            [textfieldarray addObject:x];
        
        if([x respondsToSelector:@selector(subviews)]){
            // if it has subviews, loop through those, too
            [textfieldarray addObjectsFromArray:[self findAllTextFieldsInView:x]];
        }
    }
    return textfieldarray;
}

#pragma mark
#pragma Implement Delegate Methods
- (void)passwordPickerViewControllerDidCancel:(passwordPickerViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
    _passwordTextField.text=@"Set Password";
    _password=nil;
}


- (void)passwordPickerViewController:(passwordPickerViewController *)controller didSelectValue:(NSString *)theSelectedValue {
    [self dismissViewControllerAnimated:YES completion:nil];
    _passwordTextField.text = @"***************";
    _password = theSelectedValue;
}


#pragma mark
#pragma Segue Logic
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"goToPasswordPicker"]){
        NSLog(@"Inside prepareForSegue, The password is %@",_password);
        
        /*
        [_emailTextField resignFirstResponder];
        [_firstNameTextField resignFirstResponder];
        [_lastNameTextField resignFirstResponder];
        */
        
        NSArray *allTextFields = [self findAllTextFieldsInView:[self view]];
        for(id x in allTextFields){
            [x resignFirstResponder];
        }

        
        UINavigationController *navigationController = segue.destinationViewController;
        passwordPickerViewController *pickerVC  = [[navigationController viewControllers] objectAtIndex:0];
        pickerVC.delegate = self;
    }    
}




@end
