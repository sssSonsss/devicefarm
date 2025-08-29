# STF Device Farm - Flexible Deployment

## 🎯 **Tổng quan**

STF Device Farm với khả năng triển khai linh hoạt cho cả **localhost** và **LAN**, giúp bạn dễ dàng chuyển đổi giữa các môi trường khác nhau.

**✅ Đã test và hoạt động hoàn hảo!**

## 📁 **Cấu trúc file**

```
device_farm/
├── docker-compose-localhost.yaml    # Cấu hình cho localhost
├── docker-compose-prod.yaml         # Cấu hình cho LAN
├── nginx.conf                       # Cấu hình Nginx cho LAN
├── nginx-localhost.conf             # Cấu hình Nginx cho localhost
├── stf-manager.sh                   # Script quản lý linh hoạt
├── test-flexible.sh                 # Script test nhanh
├── build-and-export.sh              # Script build/export image
├── quick-migration.sh               # Script migration nhanh
└── README-FLEXIBLE.md              # Hướng dẫn này
```

## 🚀 **Cách sử dụng**

### **1. Sử dụng STF Manager (Khuyến nghị)**

```bash
# Tự động phát hiện và khởi động
./stf-manager.sh auto start

# Khởi động cho localhost
./stf-manager.sh localhost start

# Khởi động cho LAN
./stf-manager.sh lan start

# Kiểm tra trạng thái
./stf-manager.sh status

# Dừng tất cả services
./stf-manager.sh stop

# Restart services
./stf-manager.sh restart

# Xem logs
./stf-manager.sh logs stf-app

# Xem logs tất cả services
./stf-manager.sh logs

# Test nhanh các mode
./test-flexible.sh localhost  # Test localhost mode
./test-flexible.sh lan        # Test LAN mode
./test-flexible.sh auto       # Test auto-detect mode
./test-flexible.sh all        # Test tất cả modes

# Build và export image (cho chuyển máy)
./build-and-export.sh all     # Build và export image
./build-and-export.sh import  # Import image trên máy mới

# Migration nhanh
./quick-migration.sh export   # Export từ máy cũ
./quick-migration.sh import   # Import trên máy mới
```

### **2. Sử dụng Docker Compose trực tiếp**

```bash
# Cho localhost
docker-compose -f docker-compose-localhost.yaml up -d

# Cho LAN
docker-compose -f docker-compose-prod.yaml up -d
```

## 🔧 **Các chế độ hoạt động**

### **Localhost Mode**
- **URL**: `http://localhost:8081/`
- **Database**: `http://localhost:8080/`
- **API**: `http://localhost:3700/`
- **Phù hợp**: Phát triển, testing local

### **LAN Mode**
- **URL**: `http://[YOUR_IP]:8081/`
- **Database**: `http://[YOUR_IP]:8080/`
- **API**: `http://[YOUR_IP]:3700/`
- **Phù hợp**: Production, team access

## 📊 **Kiểm tra trạng thái**

```bash
# Kiểm tra containers
docker ps | grep stf

# Kiểm tra logs
docker logs stf-app
docker logs stf-websocket
docker logs stf-provider

# Kiểm tra network
docker network ls | grep stf
```

## 🔐 **Authentication**

### **Default Login:**
- **Email**: `administrator@fakedomain.com`
- **Password**: (không cần password với mock auth)

### **Tạo user mới:**
```bash
# Truy cập database
docker exec -it stf-api node

# Tạo user
const dbapi = require('./lib/db/api')
dbapi.createUser('test@example.com', 'Test User', '127.0.0.1')
```

## 🚀 **Migration - Chuyển máy nhanh**

### **Trên máy cũ:**
```bash
# Export image và files
./quick-migration.sh export

# Copy toàn bộ thư mục sang máy mới
scp -r device_farm/ user@new-machine:/path/
```

### **Trên máy mới:**
```bash
# Import và setup
./quick-migration.sh import

# Khởi động STF
./stf-manager.sh localhost start

# Test hoạt động
./test-flexible.sh localhost
```

### **Lợi ích:**
- ✅ **Nhanh**: 5-10 phút thay vì 30-60 phút build lại
- ✅ **Đơn giản**: Chỉ cần 2 lệnh chính
- ✅ **An toàn**: Giữ nguyên toàn bộ code customize

## 🛠️ **Troubleshooting**

### **Vấn đề thường gặp:**

1. **Services không start**
   ```bash
   ./stf-manager.sh stop
   ./stf-manager.sh auto start
   ```

2. **Database connection failed**
   ```bash
   docker restart rethinkdb
   sleep 5
   docker restart stf-app stf-auth stf-api stf-websocket
   ```

3. **WebSocket disconnect**
   ```bash
   docker logs stf-websocket
   docker restart stf-websocket
   ```

4. **Provider không detect devices**
   ```bash
   docker logs stf-provider
   docker restart adb stf-provider
   ```

### **Kiểm tra ports:**
```bash
# Kiểm tra ports đang listen
netstat -tlnp | grep -E "(8081|8080|3700|3600|7120)"

# Kiểm tra triproxy ports
netstat -tlnp | grep -E "(7150|7160|7170|7250|7260|7270)"
```

## 📋 **Services Architecture**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  RethinkDB  │    │     ADB     │    │   Triproxy  │
│   (Database)│    │  (Devices)  │    │ (Communication)
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Storage   │    │    Auth     │    │     App     │
│   Services  │    │   Service   │    │   Service   │
└─────────────┘    └─────────────┘    └─────────────┘
                           │                   │
                           └───────────────────┼───┐
                                               │   │
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ WebSocket   │    │     API     │    │   Provider  │
│  Service    │    │   Service   │    │   Service   │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                    ┌─────────────┐
                    │    Nginx    │
                    │   Proxy     │
                    └─────────────┘
```

## 🎯 **Features**

### ✅ **Đã hoàn thành:**
- [x] Flexible deployment (localhost/LAN)
- [x] Auto-detection network mode
- [x] Service health monitoring
- [x] Easy management script
- [x] Provider device tracking
- [x] WebSocket communication
- [x] Authentication system
- [x] Database persistence
- [x] Nginx reverse proxy
- [x] CORS configuration
- [x] AngularJS frontend fixes
- [x] Image build and export tools
- [x] Migration tools for new machines
- [x] Automated setup scripts

### 🔧 **Cải tiến:**
- [x] Safe $apply() implementation
- [x] Error handling improvements
- [x] Network connectivity fixes
- [x] Session management
- [x] WebSocket proxy configuration

## 📞 **Support**

Nếu gặp vấn đề, hãy:

1. **Kiểm tra logs:**
   ```bash
   ./stf-manager.sh logs
   ```

2. **Restart services:**
   ```bash
   ./stf-manager.sh restart
   ```

3. **Kiểm tra network:**
   ```bash
   ./stf-manager.sh status
   ```

## 🎉 **Kết luận**

STF Device Farm hiện tại đã được tối ưu hóa để:
- ✅ **Linh hoạt** chuyển đổi giữa localhost và LAN
- ✅ **Ổn định** với error handling tốt
- ✅ **Dễ quản lý** với script automation
- ✅ **Sẵn sàng sử dụng** cho production

**Happy testing! 🚀**
