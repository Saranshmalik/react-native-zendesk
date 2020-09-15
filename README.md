
# react-native-zendesk [![npm version](https://badge.fury.io/js/react-native-zendesk-v2.svg)](https://badge.fury.io/js/react-native-zendesk-v2)
[![NPM](https://nodei.co/npm/react-native-zendesk-v2.png?downloads=true&downloadRank=true&stars=true)](https://nodei.co/npm/react-native-zendesk-v2/)

React native wrapper for zendesk unified SDK. Supports both iOS and Android platforms.

# NOTICE
This is my very first npm package and I am still a newbie. Anyone if has suggestions/improvements or any feature PRs you are most welcome, would love to get make the package as much generalised for everyone as possible. Only very basic stuff is supported at this moment.


## VERSIONS
It's an alpha version release as of now and only tested on RN >=0.61.0. Bugs and issues can be there.

## Getting Started

### Manual install

1. With npm:

   `npm install react-native-zendesk-v2`

   or with yarn:

   `yarn add react-native-zendesk-v2`

#### iOS

2. Pod Install:

   then run pod install: `(cd ios; pod install)`

   or manually:

   In Xcode, drag and drop `node_modules/react-native-zendesk-chat/RNZendeskChat.m` and `node_modules/react-native-zendesk-chat/RNZendeskChat.h` into your project.


#### Android

You need to add this in your root build.gradle under allProjects -> repositories file of the project.
`maven { url 'https://zendesk.jfrog.io/zendesk/repo' }`

## Usage

In your code add:

Step 1. import RNZendeskChat from 'react-native-zendesk'

### Initialisation
Place this code at the root of your application to initialize Zendesk SDK.

For all supported SDKs
```javascript
RNZendeskChat.init({
      key: <chatAccountKey>,
      appId: <appId>,
      url: <zendeskUrl>,
      clientId: <zendeskClientId>,
})
```

If you just want ChatSDK use this instead:
`RNZendeskChat.initChat('<chatAccountKey>')`

Step 2. Set user identifier
- If your chat just runs behind a login you can pass in name and email whenever user logins if not, pass a JWT Token to identify the user on chat

```
    RNZendeskChat.setUserIdentity({
        name: <name>,
        email: <email>,
    })
 ```
- If you want to start chat without any user details you can use a JWT token.
```
    RNZendeskChat.setUserIdentity({
		token: <JWT TOKEN>
    })
```

Step 3. Show the UI based on what SDK you want to use
### Chat SDK
** To use chat sdk without answer bot, please add `chatOnly: true` in this method
```
    ZendeskChat.startChat({
      name: user.full_name,
      email: user.email,
      phone: user.mobile_phone,
      tags: ['tag1', 'tag2'],
      department: "Your department"
    });
```
| Props  | Description |
|--|--|
| name | Name of the user |
| email | Email of the user
| phone | Phone number of the user |
| tags | Some specific tags you want to associate with the chat
| department | Any department you want to associate chat with |
| chatOnly | If you just want to start the ChatSDK and not answer or support SDKs. | 
| botName | The botname you want to show on your chat |
| color | Primary color (hex code) for chat bubbles only on iOS |

### Help Center (with and Without Chat SDK)
To initiate and display help center use the following method:
```
RNZendesk.showHelpCenter({
      withChat: true // add this if you want to use chat instead of ticket creation
			disableTicketCreation: true // add this if you want to just show help center and not add ticket creation
})
```
You can use either of these options `withChat` or `disableTicketCreation`, both can't be used together. 

*NOTE: Zendesk support with chat enabled is currently buggy, I am trying to resolve that issue. At present you can show help center with normal ticket creation.*
Working on currently adding more config options here and add customising properties.

### Customising Looks
For styling in android create a theme in your android folder with the following properties
```
<style  name="ZendeskTheme"  parent="Theme.MaterialComponents.Light">

<item  name="colorPrimary">@color/primary</item>

<item  name="colorPrimaryDark">@color/primary</item>

<item  name="colorAccent">@color/primary</item>

</style>
```
And then add following to your project's AndroidManifest.xml file (use only the SDKs you use)
```
      <activity android:name="zendesk.support.guide.HelpCenterActivity"
            android:theme="@style/ZendeskTheme" />

        <activity android:name="zendesk.support.guide.ViewArticleActivity"
            android:theme="@style/ZendeskTheme" />

        <activity android:name="zendesk.support.request.RequestActivity"
            android:theme="@style/ZendeskTheme" />

        <activity android:name="zendesk.support.requestlist.RequestListActivity"
            android:theme="@style/ZendeskTheme" />
        <activity android:name="zendesk.messaging.MessagingActivity"
            android:theme="@style/ZendeskTheme" />
```

For iOS only added a new function which can be used as below. This would set the primary color for the chat and other sdks
```
	RNZendesk.setPrimaryColor(<hex color string>)

```

## TODO

- ~~Add Help center~~
- Allow setting form configuration from JS
- Add examples
- Allowing more native methods for updating visitorInfo
- Adding customisation of SDK support
- Exposing individual methods to support all SDKs and different combinations
- Add more support of dynamic properties
- More config for looks on iOS
- Add support for PushNotifications

Contributions and PRs are always welcome.

## License

React Native is MIT licensed, as found in the [LICENSE](https://github.com/Saranshmalik/react-native-zendesk/LICENSE) file.
