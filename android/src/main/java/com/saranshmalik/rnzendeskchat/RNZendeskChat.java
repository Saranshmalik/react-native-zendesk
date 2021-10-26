
package com.saranshmalik.rnzendeskchat;

import android.app.Activity;
import android.content.Context;

import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;
import com.zendesk.logger.Logger;

import java.lang.String;
import java.util.ArrayList;
import java.util.List;

import zendesk.chat.Chat;
import zendesk.chat.ChatConfiguration;
import zendesk.chat.ChatEngine;
import zendesk.chat.ChatProvider;
import zendesk.chat.ProfileProvider;
import zendesk.chat.PushNotificationsProvider;
import zendesk.chat.Providers;
import zendesk.chat.VisitorInfo;
import zendesk.configurations.Configuration;
import zendesk.core.JwtIdentity;
import zendesk.core.AnonymousIdentity;
import zendesk.core.Identity;
import zendesk.messaging.MessagingActivity;
import zendesk.core.Zendesk;
import zendesk.support.CustomField;
import zendesk.support.Support;
import zendesk.support.guide.HelpCenterActivity;
import zendesk.support.guide.ViewArticleActivity;
import zendesk.answerbot.AnswerBot;
import zendesk.answerbot.AnswerBotEngine;
import zendesk.support.SupportEngine;
import zendesk.support.request.RequestActivity;

public class RNZendeskChat extends ReactContextBaseJavaModule {

  private ReactContext appContext;
  private static final String TAG = "ZendeskChat";

  public RNZendeskChat(ReactApplicationContext reactContext) {
    super(reactContext);
    appContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNZendeskChat";
  }

  private String getBotName(ReadableMap options){
    if(options.hasKey("botName")){
      return options.getString("botName");
    }
    return "Chat Bot";
  }

  /* helper methods */
  private Boolean getBoolean(ReadableMap options, String key){
    if(options.hasKey(key)){
      return options.getBoolean(key);
    }
    return null;
  }

  private String getString(ReadableMap options, String key){
    if(options.hasKey(key)){
      return options.getString(key);
    }
    return null;
  }


  @ReactMethod
  public void setVisitorInfo(ReadableMap options) {

    Providers providers = Chat.INSTANCE.providers();
    if (providers == null) {
      Log.d(TAG, "Can't set visitor info, provider is null");
      return;
    }
    ProfileProvider profileProvider = providers.profileProvider();
    if (profileProvider == null) {
      Log.d(TAG, "Profile provider is null");
      return;
    }
    ChatProvider chatProvider = providers.chatProvider();
    if (chatProvider == null) {
      Log.d(TAG, "Chat provider is null");
      return;
    }
    VisitorInfo.Builder builder = VisitorInfo.builder();
    String name = getString(options,"name");
    String email = getString(options,"email");
    String phone = getString(options,"phone");
    String department = getString(options,"department");
    if (name != null) {
      builder = builder.withName(name);
    }
    if (email != null) {
      builder = builder.withEmail(email);
    }
    if (phone != null) {
      builder = builder.withPhoneNumber(phone);
    }
    VisitorInfo visitorInfo = builder.build();
    profileProvider.setVisitorInfo(visitorInfo, null);
    if (department != null)
      chatProvider.setDepartment(department, null);

  }

  @ReactMethod
  public void init(ReadableMap options) {
    String appId = options.getString("appId");
    String clientId = options.getString("clientId");
    String url = options.getString("url");
    String key = options.getString("key");
    Context context = appContext;
    Zendesk.INSTANCE.init(context, url, appId, clientId);
    Support.INSTANCE.init(Zendesk.INSTANCE);
    AnswerBot.INSTANCE.init(Zendesk.INSTANCE, Support.INSTANCE);
    initChat(key);
  }

  private void checkIdentity(){
    Identity identity = Zendesk.INSTANCE.getIdentity();
    Log.v(TAG,"identity: " + identity != null ? "not null" : "null");
  }

  @ReactMethod
  public void resetUserIdentity() {
    Chat.INSTANCE.resetIdentity();
    Log.v(TAG,"resetUserIdentity");
  }

  @ReactMethod
  public void initChat(String key) {
    Context context = appContext;
    Chat.INSTANCE.init(context, key);
  }

  @ReactMethod
  public void setUserIdentity(ReadableMap options) {
    String token = getString(options,"token");
    if (token != null) {
      Identity identity = new JwtIdentity(token);
      Zendesk.INSTANCE.setIdentity(identity);
    } else {
      String name = options.getString("name");
      String email = options.getString("email");
      Identity identity = new AnonymousIdentity.Builder()
        .withNameIdentifier(name).withEmailIdentifier(email).build();
      Zendesk.INSTANCE.setIdentity(identity);
    }
    checkIdentity();
  }

  @ReactMethod
  public void showHelpCenter(ReadableMap options) {
    Activity activity = getCurrentActivity();
    /*
    // config must be passed as 2nd parameter to show method
    List<CustomField> customFields = new ArrayList<>();
    customFields.add(new CustomField(360028434358L, "testValoreDaApp"));
    Configuration config = RequestActivity.builder()
      .withCustomFields(customFields)
      .withTags("tag1","tag2")
      .config();
     */
    Boolean withChat = getBoolean(options,"withChat");
    Boolean disableTicketCreation = getBoolean(options,"withChat");
    if (withChat) {
      HelpCenterActivity.builder()
        .withEngines(ChatEngine.engine())
        .show(activity);
    } else if (disableTicketCreation) {
      HelpCenterActivity.builder()
        .withContactUsButtonVisible(false)
        .withShowConversationsMenuButton(false)
        .show(activity, ViewArticleActivity.builder()
          .withContactUsButtonVisible(false)
          .config());
    } else {
      HelpCenterActivity.builder()
        .show(activity);
    }
  }

  @ReactMethod
  public void startChat(ReadableMap options) {
    setUserIdentity(options);
    setVisitorInfo(options);
    setUserIdentity(options);
    String botName = getBotName(options);
    ChatConfiguration chatConfiguration = ChatConfiguration.builder()
      .withAgentAvailabilityEnabled(true)
      .withOfflineFormEnabled(true)
      .build();

    Activity activity = getCurrentActivity();
    if (options.hasKey("chatOnly")) {
      MessagingActivity.builder()
        .withBotLabelString(botName)
        .withEngines(ChatEngine.engine(), SupportEngine.engine())
        .show(activity, chatConfiguration);
    } else {
      MessagingActivity.builder()
        .withBotLabelString(botName)
        .withEngines(AnswerBotEngine.engine(), ChatEngine.engine(), SupportEngine.engine())
        .show(activity, chatConfiguration);
    }

  }

  @ReactMethod
  public void setNotificationToken(String token) {
    PushNotificationsProvider pushProvider = Chat.INSTANCE.providers().pushNotificationsProvider();
    if (pushProvider != null) {
      pushProvider.registerPushToken(token);
    }
  }
}
