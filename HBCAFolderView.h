#import <Velox/VeloxFolderViewProtocol.h>

@interface HBCAFolderView : UIView <VeloxFolderViewProtocol, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
	UITableView *_tableView;
	UITextField *_textField;
	NSArray *_toDos;
	float _cellHeight;
	BOOL _isShowingTextField;
	BOOL _isDragging;
	UITapGestureRecognizer *_gestureRecognizer;
}
@end
