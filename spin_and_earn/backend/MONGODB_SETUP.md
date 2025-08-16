# MongoDB Atlas Setup Guide

## 🔍 Current Issue
The MongoDB connection string you provided is not working due to DNS resolution issues. The cluster domain `cluster0.tnblqwa.mongodb.net` cannot be resolved.

## 🚀 Quick Fix Options

### Option 1: Verify Your MongoDB Atlas Cluster
1. **Login to MongoDB Atlas**: https://cloud.mongodb.com
2. **Check your cluster name** - it should be visible in your dashboard
3. **Verify the cluster is running** (green status)
4. **Check network access** - ensure your IP is whitelisted

### Option 2: Get Fresh Connection String
1. In MongoDB Atlas, click on your cluster
2. Click "Connect"
3. Choose "Connect your application"
4. Copy the new connection string
5. Replace `<password>` with your actual password
6. Replace `<dbname>` with `spinandearn` (or your preferred database name)

### Option 3: Create New MongoDB Atlas Cluster
If the current cluster is not working:

1. **Create New Cluster**:
   - Click "Build a Database"
   - Choose "FREE" tier (M0)
   - Select your preferred cloud provider and region
   - Click "Create"

2. **Set Up Database Access**:
   - Go to "Database Access"
   - Click "Add New Database User"
   - Create username and password
   - Set privileges to "Read and write to any database"

3. **Set Up Network Access**:
   - Go to "Network Access"
   - Click "Add IP Address"
   - Choose "Allow Access from Anywhere" (for development)
   - Or add your specific IP address

4. **Get Connection String**:
   - Go back to your cluster
   - Click "Connect"
   - Choose "Connect your application"
   - Copy the connection string

## 🔧 Connection String Format

### Standard Format
```
mongodb+srv://username:password@cluster-name.xxxxx.mongodb.net/database-name?retryWrites=true&w=majority
```

### Example
```
mongodb+srv://myuser:mypassword123@mycluster.abc123.mongodb.net/spinandearn?retryWrites=true&w=majority
```

## 📝 Environment Configuration

1. **Update your .env file**:
```bash
cp env.example .env
```

2. **Edit .env file** with your working MongoDB URI:
```env
MONGO_URI=mongodb+srv://your_username:your_password@your_cluster.xxxxx.mongodb.net/spinandearn?retryWrites=true&w=majority
```

3. **Test the connection**:
```bash
node test-mongo.js
```

## 🧪 Testing Connection

After updating your MongoDB URI, test it with:
```bash
node test-mongo.js
```

You should see:
```
✅ MongoDB Connected: your-cluster.xxxxx.mongodb.net
📊 Database: spinandearn
🔌 Port: 27017
📚 Collections found: 0
🔌 Disconnected from MongoDB
```

## 🚨 Common Issues & Solutions

### Issue: DNS Resolution Error
- **Cause**: Cluster domain doesn't exist or is incorrect
- **Solution**: Verify cluster name in MongoDB Atlas dashboard

### Issue: Authentication Failed
- **Cause**: Wrong username/password
- **Solution**: Check database user credentials in MongoDB Atlas

### Issue: Network Access Denied
- **Cause**: IP address not whitelisted
- **Solution**: Add your IP to MongoDB Atlas Network Access

### Issue: Cluster Not Running
- **Cause**: Cluster is paused or stopped
- **Solution**: Resume cluster in MongoDB Atlas dashboard

## 🔒 Security Best Practices

1. **Use Strong Passwords**: Avoid special characters that need URL encoding
2. **Limit Network Access**: Only whitelist necessary IP addresses
3. **Use Database Users**: Don't use root user for applications
4. **Environment Variables**: Never commit .env files to version control

## 📱 For Mobile App Development

If you're developing a mobile app:
1. **Allow Access from Anywhere** in Network Access (for testing)
2. **Use environment-specific URIs** (dev/staging/production)
3. **Consider IP restrictions** for production deployments

## 🆘 Still Having Issues?

1. **Check MongoDB Atlas Status**: https://status.mongodb.com/
2. **Verify Cluster Region**: Ensure it's in a region accessible from your location
3. **Test with MongoDB Compass**: Use the desktop app to test connection
4. **Check Firewall**: Ensure no local firewall is blocking MongoDB connections

## 🎯 Next Steps

Once MongoDB is connected:
1. **Start the server**: `npm run dev`
2. **Test API endpoints**: Use the provided Postman collection
3. **Deploy to Vercel**: Use the deployment script
4. **Connect your Flutter app**: Update the API base URL

## 📞 Support Resources

- **MongoDB Atlas Documentation**: https://docs.atlas.mongodb.com/
- **MongoDB Community**: https://community.mongodb.com/
- **Stack Overflow**: Tag with `mongodb-atlas`
