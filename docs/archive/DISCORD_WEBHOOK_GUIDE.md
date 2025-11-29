# 📱 Discord Webhook Setup Guide

## 🎯 **Quick Setup Steps**

### **Step 1: Access Server Settings**
```
Discord App → Your Server → Click Server Name → Server Settings
```
OR right-click your server icon in the left sidebar and select "Server Settings"

### **Step 2: Navigate to Webhooks**
```
Server Settings → Integrations → Webhooks → Create Webhook
```

### **Step 3: Configure Webhook**
**Basic Settings:**
- **Name**: `AutoAdmin Alert Bot`
- **Channel**: Choose where alerts should go
- **Avatar**: (Optional) Upload a bot icon

**Advanced Settings:**
- Keep default permissions
- No need to modify unless you want custom behavior

### **Step 4: Copy Webhook URL**
After creating, you'll get a URL like:
```
https://discord.com/api/webhooks/123456789012345678/ABCDEFGHIJKLMNOPQR...
```
🔒 **Keep this URL secret!** Anyone with it can post to your channel.

### **Step 5: Test Webhook**
You can test it immediately in Discord by clicking "Send Test Message"

---

## 🖼️ **Visual Navigation**

```
1. Server Name Dropdown
   └── Server Settings
        └── Integrations
             └── Webhooks
                  └── Create Webhook
                       └── Configure
                            └── Copy URL
```

## ⚠️ **Security Tips**
- Don't share your webhook URL publicly
- Webhook URLs contain secret tokens
- You can regenerate if compromised
- Webhooks bypass rate limits for legitimate use

## 🎨 **Customization Ideas**
**Channel Names:**
- `#server-alerts`
- `#autoadmin-reports`
- `#sysadmin-notifications`
- `#infrastructure-health`

**Bot Names:**
- `AutoAdmin Bot`
- `Server Guardian`
- `SysAdmin Assistant`
- `Infrastructure Monitor`

---

## 🚀 **Next Steps**
Once you have your webhook URL:

1. **Return to terminal** and run:
   ```bash
   nano ~/.bashrc
   ```

2. **Add at the end**:
   ```bash
   export DISCORD_WEBHOOK="YOUR_WEBHOOK_URL_HERE"
   ```

3. **Reload environment**:
   ```bash
   source ~/.bashrc
   ```

4. **Test with AutoAdmin**:
   ```bash
   sudo systemctl start autoadmin.service
   ```

---

## 🆘 **Troubleshooting**

**Can't create webhook?**
- You need "Manage Webhooks" permission
- Ask server admin for help

**Webhook not working?**
- Check URL is correct (no extra spaces)
- Verify webhook wasn't deleted in Discord
- Test with curl:
  ```bash
  curl -H "Content-Type: application/json" -X POST -d '{"content":"Test message"}' "$DISCORD_WEBHOOK"
  ```

**Too many notifications?**
- Consider creating a dedicated alerts channel
- You can mute the channel and still receive important alerts

---

**Questions?** The Discord docs are also helpful:
https://support.discord.com/hc/en-us/articles/228383668-Intro-to-Webhooks