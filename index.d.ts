declare module 'react-native-zendesk-v2' {

  /**
   * To initiate a chat session
   * @param chatOptions
   */
  export function startChat(chatOptions: ChatOptions): void;

 /**
  * To initialize the Zendesk SDK with all capabilities
  * @param initializationOptins 
  */
  export function init(initializationOptins: InitOptions): void;

  /**
   * To initialize the Chat SDK only, to be used only if you just want Chat SDK
   * @param accountKey 
   */
  export function initChat(accountKey: string): void;

  /**
   * Set primary color of chat on iOS
   * @param color 
   */
  export function setPrimaryColor(color: string): void;

  /**
   * To show help center from Zendesk Support SDK, can also have chat feature
   * @param chatOptions 
   */
  export function showHelpCenter(chatOptions: HelpCenterOptions): void;

  /**
   * Base function to set visitor info in Zendesk
   * @param visitorInfo 
   */
  export function setVisitorInfo(visitorInfo: UserInfo): void;

  /**
   * Function to register your notification token with Zendesk, to receive notifications on device
   * @param token 
   */
  export function setNotificationToken(token: string): void;
  
  interface ChatOptions extends UserInfo {
    /** Chat Department, optional */
    department?: string
    /** Tags to set for the chat to better redirect, optional */
    tags?: Array<string>
    /**
     * Default chat options to configure
     * Read more about them here: 
     * https://developer.zendesk.com/embeddables/docs/chat-sdk-v-2-for-ios/customize_the_look#customizing-the-chat-experience
     */
    chatOptions?: {
      showPreChatForm?:boolean
      showChatTranscriptPrompt?:boolean
      showOfflineForm?:boolean
      showAgentAvailability?:boolean
    }
    /**
     * In case you have enabled pre chat forms, you can configure what fields to be required
     * Read more here:
     * https://developer.zendesk.com/embeddables/docs/chat-sdk-v-2-for-ios/customize_the_look#configuring-a-pre-chat-form
     */
    preChatOptions?: {
      name? : 'required' | 'optional' | 'hidden'
      email? : 'required' | 'optional'| 'hidden'
      phone? : 'required' | 'optional'| 'hidden'
      department? : 'required' | 'optional'| 'hidden'
    }
    /**
     * Configuration to set up bot name, image in chat
     */
    messagingOptions?: {
      botName?:string
      botAvatarName?:string
      botAvatarUrl?:string
    }
    /**
     * If you wish to just initialize Chat SDK on start of a chat, set this to true
     * To use all SDKs in chat like Answer Bot and Support please set this to false only
     */
    chatOnly?: boolean
  }

  interface HelpCenterOptions extends ChatOptions {
    /**
     * Whether you also want the help center to give live chat option at bottom
     */
    withChat?: boolean
    /**
     * In case you want to not let users create tickets
     */
    disableTicketCreation?: boolean
    /**
     * Send this as true in case you don't want to see the complete list and filter by some value
     */
    filterArticles?:boolean
    /**
     * Required if filterArticles is set to true, needs the type of filter and values to filter upon
     */
    filter?: {
      type : 'category' | 'section' | 'label'
      values : Array<string>
    }
  }

  interface InitOptions {
    /**
     * Chat key of your Zendesk account
     */
    key: string,
    /**
    * app id of your Zendesk account
    */
    appId: string,
    /** Client id of your Zendesk account */
    clientId: string,
    /**
    * Support url for the account
    */
    url: string,
  }

  interface UserInfo {
    /** User Name */
    name: string
    /** User Email */
    email: string
    /** User Phone, optional */
    phone?: number
  }

}
