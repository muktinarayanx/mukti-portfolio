# PDF Share App

A full-stack application to upload, download and manage PDF files securely.

---

## Project Structure

```
pdf-sender-app/
├── server/                  ← Node.js + Express backend
│   ├── controllers/
│   │   ├── authController.js
│   │   └── pdfController.js
│   ├── middleware/
│   │   ├── authMiddleware.js
│   │   └── uploadMiddleware.js
│   ├── models/
│   │   ├── User.js
│   │   └── File.js
│   ├── routes/
│   │   ├── authRoutes.js
│   │   └── pdfRoutes.js
│   ├── uploads/             ← PDF files stored here (auto-created)
│   ├── server.js
│   ├── package.json
│   └── .env.example
└── flutter_app/             ← Flutter frontend
    ├── lib/
    │   ├── constants/
    │   │   └── app_constants.dart
    │   ├── models/
    │   │   ├── user_model.dart
    │   │   └── pdf_model.dart
    │   ├── services/
    │   │   ├── auth_service.dart
    │   │   └── pdf_service.dart
    │   ├── screens/
    │   │   ├── login_screen.dart
    │   │   ├── register_screen.dart
    │   │   ├── home_screen.dart
    │   │   ├── upload_screen.dart
    │   │   ├── pdf_list_screen.dart
    │   │   └── download_screen.dart
    │   └── main.dart
    └── pubspec.yaml
```

---

## Step 1 — Set Up MongoDB Atlas

1. Go to [https://cloud.mongodb.com](https://cloud.mongodb.com) and create a free account.
2. Create a **free M0 cluster** (choose any region).
3. In **Database Access**, create a database user with username/password.
4. In **Network Access**, click **Add IP Address → Allow Access from Anywhere** (0.0.0.0/0).
5. Click **Connect → Connect your application** and copy the connection string. It looks like:
   ```
   mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/
   ```
6. Replace `<username>` and `<password>` with your credentials.

---

## Step 2 — Configure & Run the Backend

### Prerequisites
- Node.js v18+ installed → https://nodejs.org

### Setup

```bash
# Navigate to the server folder
cd pdf-sender-app/server

# Copy env template
copy .env.example .env
```

Open `.env` and fill in your values:
```env
PORT=5000
MONGO_URI=mongodb+srv://youruser:yourpassword@cluster0.xxxxx.mongodb.net/pdf_share_db?retryWrites=true&w=majority
JWT_SECRET=mysupersecretjwtkey123456
```

### Install dependencies and start

```bash
npm install
npm run dev
```

You should see:
```
✅ Connected to MongoDB Atlas
🚀 Server running on http://localhost:5000
```

---

## Step 3 — Configure & Run the Flutter App

### Prerequisites
- Flutter SDK 3.x installed → https://docs.flutter.dev/get-started/install
- Android Studio or VS Code with Flutter/Dart plugins
- Android emulator running (or real device connected)

### Configure API URL

Open `flutter_app/lib/constants/app_constants.dart`:

| Environment | URL to use |
|-------------|-----------|
| Android Emulator | `http://10.0.2.2:5000` ✅ (default) |
| iOS Simulator | `http://localhost:5000` |
| Real Device | `http://YOUR_PC_LOCAL_IP:5000` |

Find your PC IP: run `ipconfig` on Windows → look for **IPv4 Address**.

### Install & run

```bash
cd pdf-sender-app/flutter_app

flutter pub get

# Run on connected device / emulator
flutter run
```

---

## API Endpoints Reference

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| POST | `/api/auth/register` | ❌ | Register a new user |
| POST | `/api/auth/login` | ❌ | Login and get JWT token |
| GET | `/api/auth/me` | ✅ JWT | Get current user profile |
| POST | `/api/pdf/upload` | ✅ Uploader | Upload a PDF (multipart) |
| GET | `/api/pdf/list` | ✅ JWT | List all PDFs |
| GET | `/api/pdf/download/:id` | ✅ JWT | Download a PDF by ID |
| DELETE | `/api/pdf/:id` | ✅ Owner | Delete a PDF |

---

## User Roles

| Role | Can Upload | Can Download | Can Delete |
|------|-----------|-------------|-----------|
| `uploader` | ✅ | ✅ | ✅ (own files) |
| `downloader` | ❌ | ✅ | ❌ |

Select your role during **Registration**.

---

## Security Features

- ✅ Passwords hashed with **bcryptjs** (salt rounds: 10)
- ✅ JWT tokens expire in **7 days**
- ✅ Tokens stored in **FlutterSecureStorage** (Keystore/Keychain)
- ✅ Upload-only-PDF MIME type validation (`application/pdf`)
- ✅ **10 MB** file size limit enforced server-side via Multer
- ✅ Role-based route protection (upload = uploader only)
- ✅ Download count tracked in MongoDB on each download

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `Network error` on emulator | Make sure backend is running; use `10.0.2.2` not `localhost` |
| `MongoDB connection error` | Check MONGO_URI in `.env`, ensure IP whitelist includes `0.0.0.0/0` |
| `Only PDF files allowed` | App enforces PDF-only via file picker; backend validates MIME type |
| `Not authorized` | Token expired — log out and log in again |
| File picker not working | Grant storage permission on the device when prompted |
