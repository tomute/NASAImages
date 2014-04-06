//
//  SettingTableViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SettingTableViewController.h"
#import "AboutViewController.h"
#import "OptionTableViewController.h"

#import "SFHFKeychainUtils.h"

#define	LABEL_TAG		111
#define	TEXTFIELD_TAG	222
#define SWITCH_TAG		333

@implementation SettingTableViewController

- (void)dealloc {
	[titleArray release];
	[keyArray release];
	[defaultArray release];
	[usernameField release];
	[passwordField release];
	
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	titleArray = [[NSArray arrayWithObjects:
				   [NSArray arrayWithObjects:@"Type", nil],
				   [NSArray arrayWithObjects:@"Media Type", @"Image Quality", @"Font Size", nil],
				   [NSArray arrayWithObjects:@"Media Type", @"Sort Type", nil],
				   nil] retain];
	
	keyArray = [[NSArray arrayWithObjects:
				 [NSArray arrayWithObjects:@"Type", nil],
				 [NSArray arrayWithObjects:@"Item Media Type", @"Image Quality", @"Font Size", nil],
				 [NSArray arrayWithObjects:@"Search Media Type", @"Sort Type", nil],
				 nil] retain];
	
	defaultArray = [[NSArray arrayWithObjects:
					 [NSArray arrayWithObjects:@"Recently Added", nil],
					 [NSArray arrayWithObjects:@"All", @"Low", @"Medium", nil],
					 [NSArray arrayWithObjects:@"All", @"No Sort", nil],
					 nil] retain];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	[self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	[keyArray release];
	[defaultArray release];
	[super viewDidUnload];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	int rtn = 0;
	switch (section) {
		case 0:
		case 1:
		case 2:
			rtn = [[keyArray objectAtIndex:section] count];
			break;
		case 3:
			rtn = 3;
			break;
		case 4:
			rtn = 1;
			break;
		default:
			break;
	}
	
    return rtn;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier1 = @"TextCell";
	static NSString *CellIdentifier2 = @"PassCell";
	static NSString *CellIdentifier3 = @"SwitchCell";
    
    UITableViewCell *cell = nil;
	int section = [indexPath section];
	int row = [indexPath row];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (section == 0 || section == 1 || section == 2 || section == 4) {
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier1] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		
		if (section == 0 || section == 1 || section == 2) {
			cell.textLabel.text = [[titleArray objectAtIndex:section] objectAtIndex:row];
			NSString *selected = [defaults stringForKey:[[keyArray objectAtIndex:section] objectAtIndex:row]];
			if (selected == nil) {
				selected = [[defaultArray objectAtIndex:section] objectAtIndex:row];
			}
			cell.detailTextLabel.text = selected;
		} else if (section == 4) {
			cell.textLabel.text = @"About";
			cell.detailTextLabel.text = @"";
		}	
	} else if (section == 3) {
		if (row == 0 || row == 1) {
			UILabel *label = nil;
			UITextField *textField = nil;
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2] autorelease];
				label = [[UILabel alloc] initWithFrame:CGRectMake(10, 6, 100, 30)];
				label.font = [UIFont boldSystemFontOfSize:18];
				label.tag = LABEL_TAG;
				textField = [[UITextField alloc] initWithFrame:CGRectMake(110, 10, 150, 30)];
				textField.returnKeyType = UIReturnKeyDone;
				textField.delegate = self;
				textField.tag = TEXTFIELD_TAG + row;
				[cell.contentView addSubview:label];
				[cell.contentView addSubview:textField];
				[label release];
				[textField release];
			}
			
			label = (UILabel *)[cell viewWithTag:LABEL_TAG];
			textField = (UITextField *)[cell viewWithTag:TEXTFIELD_TAG + row];
			
			NSString *username = [defaults objectForKey:@"USERNAME"];
			if (row == 0) {
				label.text = @"Username";
				textField.text = username;
				usernameField = [textField retain];
			} else {
				label.text = @"Password";
				textField.secureTextEntry = YES;
				NSError *error;
				textField.text = [SFHFKeychainUtils getPasswordForUsername:username
															andServiceName:@"com.tomute.NASAImages"
																	 error:&error];
				passwordField = [textField retain];
			}
		} else if (row == 2) {
			UISwitch *httpsSwitch = nil;
			cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3];
			if (cell == nil) {
				cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier3] autorelease];
				httpsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(cell.frame.size.width - 124, 8, 64, 24)];
				httpsSwitch.tag = SWITCH_TAG;
				[httpsSwitch addTarget:self action:@selector(httpsSwitch:) forControlEvents:UIControlEventValueChanged];
				[cell.contentView addSubview:httpsSwitch];
				[httpsSwitch release];
			}
			BOOL isHttpsOn = [defaults boolForKey:@"HTTPS_ON"];
			httpsSwitch = (UISwitch *)[cell viewWithTag:SWITCH_TAG];
			[httpsSwitch setOn:isHttpsOn];
			cell.textLabel.text = @"HTTPS";
			cell.detailTextLabel.text = @"";
		}
		
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *optionsArray = [NSArray arrayWithObjects:
							 [NSArray arrayWithObjects:
							  [NSArray arrayWithObjects:@"Recently Added", @"Most Downloaded", nil],
							  nil],
							 [NSArray arrayWithObjects:
							  [NSArray arrayWithObjects:@"All", @"Image", @"Movie", nil],
							  [NSArray arrayWithObjects:@"Low", @"High", nil],
							  [NSArray arrayWithObjects:@"Small", @"Medium", @"Large", nil],
							  nil],
							 [NSArray arrayWithObjects:
							  [NSArray arrayWithObjects:@"All", @"Image", @"Movie", nil],
							  [NSArray arrayWithObjects:@"No Sort", @"From New", @"From Old", nil],
							  nil],
							 nil];
	
	int section = [indexPath section];
    if (section == 0 || section == 1 || section == 2) {
		int row = [indexPath row];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSString *storedKey = [[keyArray objectAtIndex:section] objectAtIndex:row];
		NSString *selected = [defaults stringForKey:storedKey];
		if (selected == nil) {
			selected = [[defaultArray objectAtIndex:section] objectAtIndex:row];
		}
		
		OptionTableViewController *otvc = [[OptionTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
		otvc.title = [[titleArray objectAtIndex:section] objectAtIndex:row];
		otvc.storedKey = storedKey;
		otvc.options = [[optionsArray objectAtIndex:section] objectAtIndex:row];
		otvc.selected = [otvc.options indexOfObject:selected];
		[self.navigationController pushViewController:otvc animated:YES];
		[otvc release];
	} else if (section == 4) {
		AboutViewController *avc = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
		[self.navigationController pushViewController:avc animated:YES];
		[avc release];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return @"Images";
			break;
		case 1:
			return @"Items";
			break;
		case 2:
			return @"Search";
			break;
		case 3:
			return @"Twitter";
			break;
		case 4:
			return @"Other";
			break;
		default:
			break;
	}

	return nil;
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	if (section == 4) {
		NSString *string = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		return [NSString stringWithFormat:@"Version %@", string];
	}
	
	return nil;
}


- (void)httpsSwitch:(UISwitch *)switchObject {
	[[NSUserDefaults standardUserDefaults] setBool:[switchObject isOn] forKey:@"HTTPS_ON"];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if (textField.tag == TEXTFIELD_TAG) {
		[defaults setObject:usernameField.text forKey:@"USERNAME"];
		[passwordField becomeFirstResponder];
	} else if (textField.tag == TEXTFIELD_TAG + 1) {
		NSError *error;
		[defaults setObject:usernameField.text forKey:@"USERNAME"];
		if ([usernameField.text length]) {
			[SFHFKeychainUtils storeUsername:usernameField.text
								 andPassword:passwordField.text
							  forServiceName:@"com.tomute.NASAImages"
							  updateExisting:YES
									   error:&error];
		}
		[textField resignFirstResponder];
	}
	
	return YES;
}

@end

