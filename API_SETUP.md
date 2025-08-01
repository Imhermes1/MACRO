# MACRO App - API Configuration Guide

## 🔑 Secure API Key Setup

MACRO uses AI services for intelligent nutrition analysis. To enable these features, you need to configure API keys securely.

### ⚠️ Security Notice

**NEVER commit API keys to version control!** This guide shows you secure ways to configure your keys.

## 🛠️ Setup Options

### Option 1: Environment Variables (Recommended for Development)

1. **In Xcode:**
   - Open your project scheme (Product → Scheme → Edit Scheme)
   - Go to "Run" → "Environment Variables"
   - Add the following variables:

   ```
   OPENAI_API_KEY = sk-your-openai-api-key-here
   ANTHROPIC_API_KEY = sk-ant-your-anthropic-key-here
   USDA_API_KEY = your-usda-api-key-here
   EDAMAM_APP_ID = your-edamam-app-id
   EDAMAM_APP_KEY = your-edamam-app-key
   ```

2. **From Terminal (for testing):**
   ```bash
   export OPENAI_API_KEY="sk-your-openai-api-key-here"
   export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key-here"
   # Then run your app
   ```

### Option 2: Keychain Storage (Recommended for Production)

```swift
// Store keys securely in keychain (one-time setup)
KeychainManager.shared.setValue("sk-your-openai-key", for: "OPENAI_API_KEY")
KeychainManager.shared.setValue("sk-ant-your-anthropic-key", for: "ANTHROPIC_API_KEY")
KeychainManager.shared.setValue("your-usda-key", for: "USDA_API_KEY")
KeychainManager.shared.setValue("your-edamam-id", for: "EDAMAM_APP_ID")
KeychainManager.shared.setValue("your-edamam-key", for: "EDAMAM_APP_KEY")
```

### Option 3: Configuration File (Development Only)

1. Create `Config.xcconfig` in your project root (add to .gitignore!):
   ```
   OPENAI_API_KEY = sk-your-openai-api-key-here
   ANTHROPIC_API_KEY = sk-ant-your-anthropic-key-here
   USDA_API_KEY = your-usda-api-key-here
   EDAMAM_APP_ID = your-edamam-app-id
   EDAMAM_APP_KEY = your-edamam-app-key
   ```

2. In your Xcode project settings:
   - Select your target
   - Go to "Build Settings" 
   - Set "Configuration File" to point to your Config.xcconfig

3. Update Info.plist to reference these values:
   ```xml
   <key>OPENAI_API_KEY</key>
   <string>$(OPENAI_API_KEY)</string>
   ```

## 🔗 Getting API Keys

### OpenAI API
1. Visit [OpenAI API Platform](https://platform.openai.com/)
2. Create account / sign in
3. Go to API Keys section
4. Create new secret key
5. Copy the key (starts with `sk-`)

### Anthropic API (Claude)
1. Visit [Anthropic Console](https://console.anthropic.com/)
2. Create account / sign in  
3. Go to API Keys section
4. Create new key
5. Copy the key (starts with `sk-ant-`)

### USDA FoodData Central API
1. Visit [USDA FoodData Central](https://fdc.nal.usda.gov/)
2. Sign up for API access
3. Get your API key from the account section
4. No credit card required - free tier available

### Edamam Nutrition API
1. Visit [Edamam Developer Portal](https://developer.edamam.com/)
2. Sign up for Nutrition Analysis API
3. Get your APP_ID and APP_KEY
4. Free tier available

## 🏗️ Configuration Priority

The app loads configuration in this order:

1. **Environment Variables** (highest priority)
2. **Keychain Storage** 
3. **Info.plist Values** (lowest priority)

## ✅ Verification

To check if your configuration is working:

```swift
// In development builds, check configuration status
#if DEBUG
AppConfiguration.printConfigurationStatus()
#endif

// Check if AI services are available
if AppConfiguration.hasAIConfiguration {
    print("✅ AI services ready")
} else {
    print("❌ No AI API keys configured")
}
```

## 🚀 Service Selection

The app automatically selects the best available AI service:

- **OpenAI GPT-4**: For text analysis and vision (image analysis)
- **Anthropic Claude**: For text analysis (fallback)
- **Mock Service**: When no API keys are configured (development)

## 🔒 Production Deployment

For production apps:

1. **Never** include API keys in your app bundle
2. Use keychain storage for persistent keys
3. Consider using your own backend API to proxy AI requests
4. Implement usage monitoring and rate limiting
5. Use different keys for development vs production

## 🐛 Troubleshooting

### No AI Analysis Working
- Check `AppConfiguration.printConfigurationStatus()` output
- Verify API keys are correctly formatted
- Ensure API keys have sufficient credits/quota

### Image Analysis Not Working
- Image analysis requires OpenAI API (GPT-4 Vision)
- Anthropic Claude doesn't support vision yet
- Check that OPENAI_API_KEY is configured

### API Errors
- Check API key validity
- Verify you have sufficient API credits
- Check network connectivity
- Review app logs for specific error messages

## 💡 Best Practices

1. **Use environment variables for development**
2. **Use keychain for production**
3. **Monitor API usage and costs**
4. **Implement fallback mechanisms**
5. **Keep API keys secure and rotate regularly**
6. **Test with mock data when API quota is limited**

---

Need help? Check the [MACRO documentation](../README.md) or create an issue in the repository.
