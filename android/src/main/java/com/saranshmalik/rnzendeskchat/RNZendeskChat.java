
package com.saranshmalik.rnzendeskchat;

import android.app.Activity;
import android.content.Context;

import android.graphics.Color;
import android.os.Build;
import androidx.core.content.ContextCompat;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.FrameLayout;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.lang.String;

import javax.annotation.Nullable;
import zendesk.chat.Chat;
import zendesk.chat.ChatConfiguration;
import zendesk.chat.ChatEngine;
import zendesk.chat.ChatProvider;
import zendesk.chat.ChatSessionStatus;
import zendesk.chat.ChatState;
import zendesk.chat.ObservationScope;
import zendesk.chat.Observer;
import zendesk.chat.PreChatFormFieldStatus;
import zendesk.chat.ProfileProvider;
import zendesk.chat.Providers;
import zendesk.chat.VisitorInfo;
import zendesk.core.AnonymousIdentity;
import zendesk.core.Identity;
import zendesk.messaging.MessagingActivity;
import zendesk.core.Zendesk;
import zendesk.support.Support;
import zendesk.support.guide.HelpCenterActivity;
import zendesk.support.requestlist.RequestListActivity;
import zendesk.answerbot.AnswerBot;
import zendesk.answerbot.AnswerBotEngine;
import zendesk.support.SupportEngine;

public class RNZendeskChat extends ReactContextBaseJavaModule {

  private ReactContext mReactContext;

  public RNZendeskChat(ReactApplicationContext reactContext) {
        super(reactContext);
        mReactContext = reactContext;
  }

  @Override
  public String getName() {
    return "RNZendeskChat";
  }
  private final String LOG_TAP = "Zendesk";

  @ReactMethod
    public void setVisitorInfo(ReadableMap options) {

        Providers providers = Chat.INSTANCE.providers();
        if (providers == null) {
            Log.d(LOG_TAP, "Can't set visitor info, provider is null");
            return;
        }
        ProfileProvider profileProvider = providers.profileProvider();
        if (profileProvider == null) {
            Log.d(LOG_TAP, "Profile provider is null");
            return;
        }
        ChatProvider chatProvider = providers.chatProvider();
        if (chatProvider == null) {
            Log.d(LOG_TAP, "Chat provider is null");
            return;
        }
        VisitorInfo.Builder builder = VisitorInfo.builder();
        if (options.hasKey("name")) {
            builder = builder.withName(options.getString("name"));
        }
        if (options.hasKey("email")) {
            builder = builder.withEmail(options.getString("email"));
        }
        if (options.hasKey("phone")) {
            builder = builder.withPhoneNumber(options.getString("phone"));
        }
        VisitorInfo visitorInfo = builder.build();
        profileProvider.setVisitorInfo(visitorInfo, null);
        if (options.hasKey("department"))
            chatProvider.setDepartment(options.getString("department"), null);

    }

    @ReactMethod
    public void init(ReadableMap options) {
        String appId = options.getString("appId");
        String clientId = options.getString("clientId");
        String url = options.getString("url");
        String key = options.getString("key");
        Context context = mReactContext;
        Zendesk.INSTANCE.init(context, url, appId, clientId);
        Support.INSTANCE.init(Zendesk.INSTANCE);
        Chat.INSTANCE.init(context, key);
    }

    @ReactMethod
    public void initChat(String key) {
        Context context = mReactContext;
        Chat.INSTANCE.init(context, key);
    }

    @ReactMethod
    public void setUserIdentity(ReadableMap options) {
        if (options.hasKey('token')) {
          Identity identity = new JwtIdentity(options.getString("token"));
        } else {
          String name = options.getString("name");
          String email = options.getString("email");
          Identity identity = new AnonymousIdentity.Builder()
                  .withNameIdentifier(name).withEmailIdentifier(email).build();
        }
        Zendesk.INSTANCE.setIdentity(identity);
    }

    @ReactMethod
    public void startChat(ReadableMap options) {
        Providers providers = Chat.INSTANCE.providers();
        setUserIdentity(options);
        setVisitorInfo(options);
        String botName = options.getString('botName')
        ChatConfiguration chatConfiguration = ChatConfiguration.builder()
                .withAgentAvailabilityEnabled(true)
                .withOfflineFormEnabled(true)
                .build();

        Activity activity = getCurrentActivity();
        if (options.hasKey('chatOnly')) {
           MessagingActivity.builder()
                    .withBotLabelString(botName)
                    .withEngines(ChatEngine.engine())
                    .show(activity, chatConfiguration);
        } else {
            MessagingActivity.builder()
                    .withBotLabelString(botName)
                    .withEngines(AnswerBotEngine.engine(), SupportEngine.engine(), ChatEngine.engine())
                    .show(activity, chatConfiguration);
        }
      
    }
}