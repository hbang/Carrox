#import "HBCAFolderView.h"
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SBBulletinListCell.h>

#define kHBCAFont [UIFont boldSystemFontOfSize:18.f]
#define kHBCATextFieldFont [UIFont systemFontOfSize:18.f]
#define kHBCANoToDosText @"No To-Dos" // this feels dirty, but carrot only supports english anyway so...
#define kHBCAPullToAddText @"Pull down to add item"
#define kHBCAReleaseToAddText @"Release!"

@interface HBCAFolderView (Private)
- (void)hideTextFieldWithDoneTapped:(BOOL)doneTapped;
@end

@implementation HBCAFolderView
+ (int)folderHeight {
	return 250;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		_cellHeight = [@"X" sizeWithFont:kHBCAFont].height + 20.f;

		_tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
		_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tableView.dataSource = self;
		_tableView.delegate = self;
		_tableView.backgroundView = nil;
		_tableView.backgroundColor = [UIColor clearColor];
		_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
		_tableView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"VeloxCellSeparator"]]; // normal one gets heighted, so bensge made his own one! <3 bensge.
		[self addSubview:_tableView];

		_textField = [[UITextField alloc] initWithFrame:CGRectMake(10.f, -_cellHeight, frame.size.width - 20.f, _cellHeight)];
		_textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		_textField.delegate = self;
		_textField.font = kHBCATextFieldFont;
		_textField.placeholder = kHBCAPullToAddText;
		_textField.textColor = [UIColor whiteColor];
		_textField.returnKeyType = UIReturnKeyDone;
		_textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[_tableView addSubview:_textField];

#if DEBUG
		NSArray *items = [[NSDictionary dictionaryWithContentsOfFile:[[[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:@"com.grailr.CARROT2"].sandboxPath stringByAppendingString:@"/Documents/todo.archive"]] objectForKey:@"$objects"];
#else
		NSArray *items = [[NSDictionary dictionaryWithContentsOfFile:[[[%c(SBApplicationController) sharedInstance] applicationWithDisplayIdentifier:@"com.grailr.CARROT"].sandboxPath stringByAppendingString:@"/Documents/todo.archive"]] objectForKey:@"$objects"];
#endif
		NSMutableArray *newToDos = [NSMutableArray array];

		for (id item in items) {
			if ([item isKindOfClass:NSString.class] && ![item isEqualToString:@"$null"] && ![item isEqualToString:@"Daily"] && ![item isEqualToString:@"Weekly"] && ![item isEqualToString:@"Monthly"]) {
				[newToDos addObject:item];
			}
		}

		_toDos = [newToDos copy];

		[_tableView reloadData];
	}

	return self;
}

- (float)realHeight {
	return _toDos.count ? _tableView.contentSize.height : _cellHeight * 3.f;
}

- (void)hideTextField {
	[self hideTextFieldWithDoneTapped:NO];
}

- (void)hideTextFieldWithDoneTapped:(BOOL)doneTapped {
	if (_isDragging || !_isShowingTextField) {
		return;
	}

	_isShowingTextField = NO;

	[_textField resignFirstResponder];

	if (_gestureRecognizer) {
		[self removeGestureRecognizer:_gestureRecognizer];
		[_gestureRecognizer release];
		_gestureRecognizer = nil;
	}

	if (_textField.text && ![_textField.text isEqualToString:@""]) {
#if DEBUG
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"carrot2://addTask/?%@", [_textField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
#else
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"carrot://addTask/?%@", [_textField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
#endif

		NSMutableArray *newToDos = [_toDos mutableCopy];
		[newToDos insertObject:_textField.text atIndex:0];
		_toDos = [newToDos copy];

		[_tableView reloadData];
	} else {
		[UIView animateWithDuration:0.3f animations:^{
			_tableView.contentInset = UIEdgeInsetsZero;
		}];
	}

	_textField.text = @"";
}

- (void)dealloc {
	[_tableView release];
	[_textField release];
	[_toDos release];
	[_gestureRecognizer release];
	[super dealloc];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _toDos.count ?: 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"CarroxCell";

	SBBulletinListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (!cell) {
		cell = [[[%c(SBBulletinListCell) alloc] initWithLinenView:nil reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.bulletinAccessoryStyle = SBBulletinListCellAccessoryStyleDot;
	}

	if (_toDos.count) {
		cell.textLabel.text = [_toDos objectAtIndex:indexPath.row];
	} else {
		cell.textLabel.text = kHBCANoToDosText;
		cell.textLabel.textAlignment = UITextAlignmentCenter;
	}

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return _toDos.count ? _cellHeight : _cellHeight * 3.f;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[self hideTextFieldWithDoneTapped:YES];

	return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[self hideTextFieldWithDoneTapped:NO];
}

#pragma mark - UIScrollViewDelegate

// based on https://github.com/leah/PullToRefresh/blob/master/Classes/PullRefreshTableViewController.m

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	if (_isShowingTextField) {
		return;
	}

	_isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (_isShowingTextField) {
		if (_tableView.contentOffset.y > 0) {
			_tableView.contentInset = UIEdgeInsetsZero;
		} else if (_tableView.contentOffset.y >= -_cellHeight) {
			_tableView.contentInset = UIEdgeInsetsMake(-_tableView.contentOffset.y, 0, 0, 0);
		}
	} else if (_isDragging && _tableView.contentOffset.y < 0) {
		_textField.placeholder = _tableView.contentOffset.y <= -_cellHeight ? kHBCAReleaseToAddText : kHBCAPullToAddText;
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if (_isShowingTextField) {
		return;
	}

	_isDragging = NO;

	if (_tableView.contentOffset.y <= -_cellHeight) {
		_isShowingTextField = YES;

		[_textField becomeFirstResponder];
		[_textField performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
		_textField.placeholder = @"";

		_gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTextField)];
		[self addGestureRecognizer:_gestureRecognizer];

		[UIView animateWithDuration:0.3f animations:^{
			_tableView.contentInset = UIEdgeInsetsMake(_cellHeight, 0, 0, 0);
		}];
	}
}

@end
