# 🚨 MongoDB Connection Quick Fix

## ❌ Current Issue
Your MongoDB Atlas cluster `cluster0.tnblqwa.mongodb.net` cannot be resolved. This means:
- The cluster doesn't exist
- The cluster name is incorrect
- The cluster is down or inaccessible

## 🔧 Immediate Solutions

### Option 1: Verify Your MongoDB Atlas Cluster
1. **Go to MongoDB Atlas**: https://cloud.mongodb.com
2. **Login with your credentials**
3. **Check if the cluster exists** in your dashboard
4. **Verify the cluster name** - it should match exactly

### Option 2: Get Fresh Connection String
1. **In MongoDB Atlas, click on your cluster**
2. **Click "Connect" button**
3. **Choose "Connect your application"**
4. **Copy the new connection string**
5. **Replace `<password>` with your actual password**
6. **Replace `<dbname>` with `spinandearn`

### Option 3: Create New MongoDB Atlas Cluster
If your current cluster is not working:

1. **Click "Build a Database"**
2. **Choose "FREE" tier (M0)**
3. **Select cloud provider and region**
4. **Click "Create"**
5. **Wait for cluster to be ready (green status)**

## 📝 Update Your Environment

1. **Edit your .env file**:
```bash
nano .env
```

2. **Update the MONGO_URI** with your working connection string:
```env
MONGO_URI=mongodb+srv://your_username:your_password@your_cluster.xxxxx.mongodb.net/spinandearn?retryWrites=true&w=majority
```

3. **Save and test**:
```bash
node test-connection.js
```

## 🧪 Test Connection

After updating your MongoDB URI, test it:
```bash
node test-connection.js
```

You should see:
```
✅ MongoDB Connected: your-cluster.xxxxx.mongodb.net
📊 Database: spinandearn
🔌 Port: 27017
📚 Collections found: 0
🔌 Disconnected from MongoDB
```

## 🚀 Once Connected

1. **Start the server**:
```bash
npm run dev
```

2. **Seed the database** with sample data:
```bash
npm run seed
```

3. **Test the API**:
```bash
curl http://localhost:3001/health
```

## 🔍 Common Issues & Solutions

### Issue: DNS Resolution Error
- **Cause**: Cluster domain doesn't exist
- **Solution**: Verify cluster name in MongoDB Atlas

### Issue: Authentication Failed
- **Cause**: Wrong username/password
- **Solution**: Check database user credentials

### Issue: Network Access Denied
- **Cause**: IP not whitelisted
- **Solution**: Add your IP to Network Access

### Issue: Cluster Not Running
- **Cause**: Cluster is paused/stopped
- **Solution**: Resume cluster in dashboard

## 📞 Need Help?

1. **Check MongoDB Atlas Status**: https://status.mongodb.com/
2. **Verify your cluster is running** (green status)
3. **Ensure your IP is whitelisted** in Network Access
4. **Double-check username and password**

## 🎯 Next Steps

Once MongoDB is connected:
1. ✅ **Backend will start successfully**
2. ✅ **Database will be accessible**
3. ✅ **Sample data can be seeded**
4. ✅ **API endpoints will work**
5. ✅ **Referral system will function**

## 🔗 Useful Links

- **MongoDB Atlas**: https://cloud.mongodb.com
- **MongoDB Documentation**: https://docs.atlas.mongodb.com/
- **Connection String Help**: https://docs.atlas.mongodb.com/connect-to-cluster/
