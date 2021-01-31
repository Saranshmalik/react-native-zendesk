
#import "RNZendeskChat.h"
#import <AnswerBotSDK/AnswerBotSDK.h>
#import <AnswerBotProvidersSDK/AnswerBotProvidersSDK.h>
#import <ChatSDK/ChatSDK.h>
#import <ChatProvidersSDK/ChatProvidersSDK.h>
#import <MessagingSDK/MessagingSDK.h>
#import <CommonUISDK/CommonUISDK.h>
#import <SupportSDK/SupportSDK.h>
#import <SupportProvidersSDK/SupportProvidersSDK.h>
#import <ZendeskCoreSDK/ZendeskCoreSDK.h>
#import <React/RCTConvert.h>

@implementation RCTConvert (ZDKChatFormFieldStatus)

RCT_ENUM_CONVERTER(ZDKFormFieldStatus,
				   (@{
					   @"required": @(ZDKFormFieldStatusRequired),
					   @"optional": @(ZDKFormFieldStatusOptional),
					   @"hidden": @(ZDKFormFieldStatusHidden),
					}),
				   ZDKFormFieldStatusOptional,
				   integerValue);

@end

@implementation RNZendeskChat

RCT_EXPORT_MODULE()
ZDKChatAPIConfiguration *_visitorAPIConfig;


#define RNZDKConfigHashErrorLog(options, what)\
if (!!options) {\
	NSLog(@"[RNZendeskChatModule] Invalid %@ -- expected a config hash", what);\
}

RCT_EXPORT_METHOD(setVisitorInfo:(NSDictionary *)options) {
  ZDKChat.instance.configuration = _visitorAPIConfig = [self applyVisitorInfo:options visitorConfig: _visitorAPIConfig ?: [[ZDKChatAPIConfiguration alloc] init]];
}

RCT_EXPORT_METHOD(startChat:(NSDictionary *)options) {
  if (!options || ![options isKindOfClass: NSDictionary.class]) {
		if (!!options){
			RNZDKConfigHashErrorLog(options,@"Start Chat Configuration Options");
		}
		options = NSDictionary.dictionary;
	}

  dispatch_sync(dispatch_get_main_queue(), ^{
    [self startChatFunction:options];
  });
}

RCT_EXPORT_METHOD(showHelpCenter:(NSDictionary *)options) {
  [self setVisitorInfo:options];
  dispatch_sync(dispatch_get_main_queue(), ^{
    [self showHelpCenterFunction:options];
  });
}

RCT_EXPORT_METHOD(setUserIdentity: (NSDictionary *)user) {
  if (user[@"token"]) {
    id<ZDKObjCIdentity> userIdentity = [[ZDKObjCJwt alloc] initWithToken:user[@"token"]];
    [[ZDKZendesk instance] setIdentity:userIdentity];
  } else {
    id<ZDKObjCIdentity> userIdentity = [[ZDKObjCAnonymous alloc] initWithName:user[@"name"] // name is nullable
                                          email:user[@"email"]]; // email is nullable
    [[ZDKZendesk instance] setIdentity:userIdentity];
  }
}

RCT_EXPORT_METHOD(init:(NSDictionary *)options) {
  [ZDKZendesk initializeWithAppId:options[@"appId"]
      clientId: options[@"clientId"]
      zendeskUrl: options[@"url"]];
  [ZDKSupport initializeWithZendesk: [ZDKZendesk instance]];
  [ZDKAnswerBot initializeWithZendesk:[ZDKZendesk instance] support:[ZDKSupport instance]];
  [ZDKChat initializeWithAccountKey:options[@"key"] queue:dispatch_get_main_queue()];
}

RCT_EXPORT_METHOD(initChat:(NSString *)key) {
  [ZDKChat initializeWithAccountKey:key queue:dispatch_get_main_queue()];
}

RCT_EXPORT_METHOD(setPrimaryColor:(NSString *)color) {
  [ZDKCommonTheme currentTheme].primaryColor = [self colorFromHexString:color];
}

RCT_EXPORT_METHOD(setNotificationToken:(NSData *)deviceToken) {
  dispatch_sync(dispatch_get_main_queue(), ^{
    [self registerForNotifications:deviceToken];
  });
}

- (ZDKChatAPIConfiguration*)applyVisitorInfo:(NSDictionary*)options visitorConfig:(ZDKChatAPIConfiguration*)config {
	if (options[@"department"]) {
		config.department = options[@"department"];
	}
	if (options[@"tags"]) {
		config.tags = options[@"tags"];
	}
	config.visitorInfo = [[ZDKVisitorInfo alloc] initWithName:options[@"name"]
														email:options[@"email"]
												  phoneNumber:options[@"phone"]];
  return config;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (ZDKHelpCenterUiConfiguration *) filterHelpCenterArticles: (NSDictionary*)options {
  ZDKHelpCenterUiConfiguration* hcConfig = [ZDKHelpCenterUiConfiguration new];
  if (!options || ![options isKindOfClass:NSDictionary.class]) {
		RNZDKConfigHashErrorLog(options, @"helpCenter config options");
		return hcConfig;
	}

  if (options[@"type"] && ([options[@"type"] isEqualToString:@"category"] || [options[@"type"] isEqualToString:@"section"])) {
    [hcConfig setGroupType:ZDKHelpCenterOverviewGroupTypeCategory];
    [hcConfig setGroupIds:options[@"values"]];
  }
  else if (options[@"values"]) {
    [hcConfig setLabels:options[@"values"]];
  }
  return hcConfig;
}

- (void) showHelpCenterFunction:(NSDictionary *)options {
    NSError *error = nil;
    NSArray *engines = @[];
    ZDKMessagingConfiguration *messagingConfiguration = [self messagingConfigurationFromConfig: options[@"messagingOptions"]];
    if (options[@"withChat"]) {
      engines = @[(id <ZDKEngine>) [ZDKChatEngine engineAndReturnError:&error]];
    }
    ZDKHelpCenterUiConfiguration* helpCenterUiConfig = [ZDKHelpCenterUiConfiguration new];
    ZDKArticleUiConfiguration* articleUiConfig = [ZDKArticleUiConfiguration new];

    if(options[@"filterArticles"]) {
      helpCenterUiConfig = [self filterHelpCenterArticles: options[@"filter"]];
    }

    if (options[@"disableTicketCreation"]) {
         helpCenterUiConfig.showContactOptions = NO;
         articleUiConfig.showContactOptions = NO;
    }

    helpCenterUiConfig.objcEngines = engines;
    articleUiConfig.objcEngines = engines;

    UIViewController* controller = [ZDKHelpCenterUi buildHelpCenterOverviewUiWithConfigs: @[helpCenterUiConfig, articleUiConfig, messagingConfiguration]];

    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController: controller];
    [topController presentViewController:navControl animated:YES completion:nil];
}

- (ZDKMessagingConfiguration *)messagingConfigurationFromConfig:(NSDictionary*)options {
	ZDKMessagingConfiguration *config = [[ZDKMessagingConfiguration alloc] init];
	if (!options || ![options isKindOfClass:NSDictionary.class]) {
		RNZDKConfigHashErrorLog(options, @"MessagingConfiguration config options");
		return config;
	}
	if (options[@"botName"]) {
		config.name = options[@"botName"];
	}

	if (options[@"botAvatarName"]) {
		config.botAvatar = [UIImage imageNamed:@"botAvatarName"];
	} else if (options[@"botAvatarUrl"]) {
		config.botAvatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:options[@"botAvatarUrl"]]]];
	}

	return config;
}

- (ZDKChatFormConfiguration * _Nullable)preChatFormConfigurationFromConfig:(NSDictionary*)options {
	if (!options || ![options isKindOfClass:NSDictionary.class]) {
		RNZDKConfigHashErrorLog(options, @"pre-Chat-Form Configuration Options");
		return nil;
	}

  #define ParseFormFieldStatus(key)\
    ZDKFormFieldStatus key = [RCTConvert ZDKFormFieldStatus:options[@"" #key]]
    ParseFormFieldStatus(name);
    ParseFormFieldStatus(email);
    ParseFormFieldStatus(phone);
    ParseFormFieldStatus(department);
  #undef ParseFormFieldStatus

	return [[ZDKChatFormConfiguration alloc] initWithName:name
													email:email
											  phoneNumber:phone
											   department:department];
}

- (ZDKChatConfiguration *)chatConfigurationFromConfig:(NSDictionary*)options {
	options = options ?: @{};

	ZDKChatConfiguration* config = [[ZDKChatConfiguration alloc] init];
	if (![options isKindOfClass:NSDictionary.class]){
		RNZDKConfigHashErrorLog(options, @"Chat Configuration Options");
		return config;
	}
	NSDictionary * chatOptions = options[@"chatOptions"];
	if (!chatOptions || ![chatOptions isKindOfClass:NSDictionary.class]) {
		RNZDKConfigHashErrorLog(chatOptions, @"chatOptions -- expected a config hash");
		chatOptions = NSDictionary.dictionary;
	}

  #define ParseBehaviorFlag(key, target)\
  config.target = [RCTConvert BOOL: chatOptions[@"" #key] ?: @YES]
    ParseBehaviorFlag(showPreChatForm, isPreChatFormEnabled);
    ParseBehaviorFlag(showChatTranscriptPrompt, isChatTranscriptPromptEnabled);
    ParseBehaviorFlag(showOfflineForm, isOfflineFormEnabled);
    ParseBehaviorFlag(showAgentAvailability, isAgentAvailabilityEnabled);
  #undef ParseBehaviorFlag

	if (config.isPreChatFormEnabled) {
		ZDKChatFormConfiguration * formConfig = [self preChatFormConfigurationFromConfig:options[@"preChatOptions"]];
		if (!!formConfig) {
			config.preChatFormConfiguration = formConfig;
		}
	}
	return config;
}

- (void) startChatFunction:(NSDictionary *)options {
    ZDKChat.instance.configuration = [self applyVisitorInfo:options visitorConfig: _visitorAPIConfig ?: [[ZDKChatAPIConfiguration alloc] init]];

		ZDKChatConfiguration * chatConfiguration = [self chatConfigurationFromConfig:options];
    NSError *error = nil;
		NSArray *engines = @[
        (id <ZDKEngine>) [ZDKAnswerBotEngine engineAndReturnError:&error],
        (id <ZDKEngine>) [ZDKChatEngine engineAndReturnError:&error],
        (id <ZDKEngine>) [ZDKSupportEngine engineAndReturnError:&error], 
      ];

		ZDKMessagingConfiguration *messagingConfiguration = [self messagingConfigurationFromConfig: options[@"messagingOptions"]];

    if (options[@"chatOnly"]) {
      engines = @[
        (id <ZDKEngine>) [ZDKChatEngine engineAndReturnError:&error]
      ];
    }

    UIViewController *chatController =[ZDKMessaging.instance buildUIWithEngines:engines
                                                                        configs:@[messagingConfiguration, chatConfiguration]
                                                                            error:&error];
    if (error) {
      NSLog(@"Error occured %@", error);
      return;
    }

    chatController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Close"
                                                                                       style: UIBarButtonItemStylePlain
                                                                                      target: self
                                                                                      action: @selector(chatClosedClicked)];


    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }

    UINavigationController *navControl = [[UINavigationController alloc] initWithRootViewController: chatController];
    [topController presentViewController:navControl animated:YES completion:nil];
}

- (void) chatClosedClicked {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    [topController dismissViewControllerAnimated:TRUE completion:NULL];
}

- (void) registerForNotifications:(NSData *)deviceToken {
   [ZDKChat registerPushToken:deviceToken];
}

@end
