#line 1 "Tweak.xm"
#include <UIKit/UIKit.h>

#define UNREAD_PATH @"/Library/Application Support/MessageUnread/unread.txt"

@interface IMChat : NSObject
@property (nonatomic, readonly) NSString *chatIdentifier;
@property (nonatomic, readonly) NSString *guid;
- (id)chatItems;
@end

@interface CKConversation : NSObject
- (id)name;
- (IMChat *)chat;
- (void)markAllMessagesAsRead;
- (BOOL)hasUnreadMessages;
@end

@interface CKNavigationController : UINavigationController
@end

@interface CKConversationListController : UITableViewController<UITableViewDelegate, UITableViewDataSource>
- (void)viewWillAppear:(BOOL)arg1;
- (id)conversationList;
-(void)updateConversationList;
-(void)test;
@end

@interface CKConversationListCell : UITableViewCell
- (CKConversation *)conversation;
- (void)layoutSubviews;
- (void)updateContentsForConversation:(id)arg1;
@end

@interface CKConversationList : NSObject
- (id)conversations;
@end



static BOOL enabled = TRUE;
static BOOL messageMarking = TRUE;
static NSString *unreadImageColor;



NSArray *unreadArray;
UITableView *table;




#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class CKConversationListController; @class CKConversation; 
static void (*_logos_orig$_ungrouped$CKConversationListController$tableView$didSelectRowAtIndexPath$)(_LOGOS_SELF_TYPE_NORMAL CKConversationListController* _LOGOS_SELF_CONST, SEL, UITableView *, NSIndexPath *); static void _logos_method$_ungrouped$CKConversationListController$tableView$didSelectRowAtIndexPath$(_LOGOS_SELF_TYPE_NORMAL CKConversationListController* _LOGOS_SELF_CONST, SEL, UITableView *, NSIndexPath *); static UISwipeActionsConfiguration * _logos_method$_ungrouped$CKConversationListController$tableView$leadingSwipeActionsConfigurationForRowAtIndexPath$(_LOGOS_SELF_TYPE_NORMAL CKConversationListController* _LOGOS_SELF_CONST, SEL, UITableView *, NSIndexPath *); static void _logos_method$_ungrouped$CKConversationListController$test(_LOGOS_SELF_TYPE_NORMAL CKConversationListController* _LOGOS_SELF_CONST, SEL); static BOOL (*_logos_orig$_ungrouped$CKConversation$hasUnreadMessages)(_LOGOS_SELF_TYPE_NORMAL CKConversation* _LOGOS_SELF_CONST, SEL); static BOOL _logos_method$_ungrouped$CKConversation$hasUnreadMessages(_LOGOS_SELF_TYPE_NORMAL CKConversation* _LOGOS_SELF_CONST, SEL); 

#line 51 "Tweak.xm"


static void _logos_method$_ungrouped$CKConversationListController$tableView$didSelectRowAtIndexPath$(_LOGOS_SELF_TYPE_NORMAL CKConversationListController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UITableView * tableView, NSIndexPath * indexPath) { 
    
    CKConversationListCell *cell = (CKConversationListCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    CKConversation *convo = [cell conversation]; 

    [convo markAllMessagesAsRead]; 

    NSString *identifier = [convo chat].chatIdentifier; 

    NSArray *unreadList = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"unread"]];
    NSMutableArray *unreadListMutable = [unreadList mutableCopy]; 

    for(NSString *string in unreadList){
        if([string isEqual:@""]){ 
            [unreadListMutable removeObject: string];
        }
        if([string isEqual: identifier]){ 
            [unreadListMutable removeObject: string];
            [[NSUserDefaults standardUserDefaults] setObject:unreadListMutable forKey:@"unread"];
        }
    }
    _logos_orig$_ungrouped$CKConversationListController$tableView$didSelectRowAtIndexPath$(self, _cmd, tableView, indexPath); 
}


static UISwipeActionsConfiguration * _logos_method$_ungrouped$CKConversationListController$tableView$leadingSwipeActionsConfigurationForRowAtIndexPath$(_LOGOS_SELF_TYPE_NORMAL CKConversationListController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, UITableView * tableView, NSIndexPath * indexPath) {
  UIContextualAction *unread = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleDestructive title:@"Unread" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
    
      if(enabled && messageMarking){

        CKConversationListCell *cell = (CKConversationListCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
        CKConversation *convo = [cell conversation]; 
        BOOL reallyHadUnread = NO;

        if([convo hasUnreadMessages]){ 
            [convo markAllMessagesAsRead];
            reallyHadUnread = YES; 
            [self test];
        }

        IMChat *chat = [convo chat];  
        NSString *identifier = chat.chatIdentifier;

        BOOL adding = YES; 
        NSArray *unreadList = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"unread"]];
        NSMutableArray *unreadListMutable = [unreadList mutableCopy]; 
        for(NSString *string in unreadList){
            if([string isEqual:@""]){
                [unreadListMutable removeObject: string];
            }
            if([string isEqual: identifier]){ 
                
                [unreadListMutable removeObject: string];
                [[NSUserDefaults standardUserDefaults] setObject:unreadListMutable forKey:@"unread"];
                adding = NO;
                [self test];
            }
        }
        if(adding && !reallyHadUnread){ 
            [unreadListMutable addObject: identifier];
            [[NSUserDefaults standardUserDefaults] setObject:unreadListMutable forKey:@"unread"]; 
            [self test];
        }
        
        
        completionHandler(true);
    }
  }];
  unread.backgroundColor = [UIColor  grayColor];
  UISwipeActionsConfiguration *swipeActionConfig = [UISwipeActionsConfiguration configurationWithActions:@[unread]];
  swipeActionConfig.performsFirstActionWithFullSwipe = YES;
  [self updateConversationList]; 
  return swipeActionConfig;
}


static void _logos_method$_ungrouped$CKConversationListController$test(_LOGOS_SELF_TYPE_NORMAL CKConversationListController* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {
  [self updateConversationList];
}





static BOOL _logos_method$_ungrouped$CKConversation$hasUnreadMessages(_LOGOS_SELF_TYPE_NORMAL CKConversation* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd) {

    unreadArray = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"unread"]];
    NSMutableArray *tempArray = [unreadArray mutableCopy];

    for(NSString *string in unreadArray){ 
        if([string isEqual: @""]){
            [tempArray removeObject: string];
        }
    }

    BOOL isOnList = NO; 
    unreadArray = [[NSArray alloc] initWithArray: tempArray]; 

    IMChat *chat = [self chat];
    NSString *identifier = chat.chatIdentifier; 

    for(id unread in unreadArray){
        if([identifier isEqual: unread]){ 
            isOnList = YES;
        }
    }

    if(isOnList && messageMarking){
        return YES; 
    }else {
        return _logos_orig$_ungrouped$CKConversation$hasUnreadMessages(self, _cmd); 
    }

}



static __attribute__((constructor)) void _logosLocalCtor_b2403fe0(int __unused argc, char __unused **argv, char __unused **envp) {
  NSArray *unreadList = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"unread"]];
  if ([[NSString stringWithFormat:@"%@", unreadList] isEqualToString:@"(null)"]) {
      [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"unread"];
    }
}
static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$CKConversationListController = objc_getClass("CKConversationListController"); MSHookMessageEx(_logos_class$_ungrouped$CKConversationListController, @selector(tableView:didSelectRowAtIndexPath:), (IMP)&_logos_method$_ungrouped$CKConversationListController$tableView$didSelectRowAtIndexPath$, (IMP*)&_logos_orig$_ungrouped$CKConversationListController$tableView$didSelectRowAtIndexPath$);{ char _typeEncoding[1024]; unsigned int i = 0; memcpy(_typeEncoding + i, @encode(UISwipeActionsConfiguration *), strlen(@encode(UISwipeActionsConfiguration *))); i += strlen(@encode(UISwipeActionsConfiguration *)); _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; memcpy(_typeEncoding + i, @encode(UITableView *), strlen(@encode(UITableView *))); i += strlen(@encode(UITableView *)); memcpy(_typeEncoding + i, @encode(NSIndexPath *), strlen(@encode(NSIndexPath *))); i += strlen(@encode(NSIndexPath *)); _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$CKConversationListController, @selector(tableView:leadingSwipeActionsConfigurationForRowAtIndexPath:), (IMP)&_logos_method$_ungrouped$CKConversationListController$tableView$leadingSwipeActionsConfigurationForRowAtIndexPath$, _typeEncoding); }{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$CKConversationListController, @selector(test), (IMP)&_logos_method$_ungrouped$CKConversationListController$test, _typeEncoding); }Class _logos_class$_ungrouped$CKConversation = objc_getClass("CKConversation"); MSHookMessageEx(_logos_class$_ungrouped$CKConversation, @selector(hasUnreadMessages), (IMP)&_logos_method$_ungrouped$CKConversation$hasUnreadMessages, (IMP*)&_logos_orig$_ungrouped$CKConversation$hasUnreadMessages);} }
#line 176 "Tweak.xm"
