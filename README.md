
# react-native-zendesk
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

For android currently one small addition is needed on root build.gradle (Trying to fix this up, let me know if you have suggestions for it)

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

Step 3. When you want to show up the chat dialog use the following code :
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

### Styling
For styling in android create a theme with name `ZendeskTheme` in your AndroidManifest.xml file with the following properties
```
<style  name="ZendeskTheme"  parent="Theme.MaterialComponents.Light">

<item  name="colorPrimary">@color/primary</item>

<item  name="colorPrimaryDark">@color/primary</item>

<item  name="colorAccent">@color/primary</item>

</style>
```
For iOS only passing color in startChat function is supported at the moment working on adding more configuration in that.
## TODO

- Allow setting form configuration from JS
- Add examples
- Allowing more native methods for updating visitorInfo

## License

React Native is MIT licensed, as found in the [LICENSE](https://github.com/Saranshmalik/react-native-zendesk/LICENSE) file.
