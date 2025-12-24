# Environment Configuration

## Cách sử dụng file .env

File `.env` được sử dụng để lưu trữ các biến môi trường nhạy cảm như API keys. File này sẽ không được commit lên Git để bảo mật.

### Setup

1. File `.env` đã được tạo trong thư mục root của project
2. Chứa `GEMINI_API_KEY` với giá trị thực tế của bạn
3. Đã được thêm vào `.gitignore` để tránh commit nhầm

### Sử dụng

Trong code, bạn có thể truy cập environment variables như sau:

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Load .env file trong main()
await dotenv.load(fileName: ".env");

// Sử dụng API key
String? apiKey = dotenv.env['GEMINI_API_KEY'];
```

### Cấu hình hiện tại

- `GEMINI_API_KEY`: Đã được cấu hình với key thực tế
- `OPENAI_API_KEY`: Tùy chọn, có thể thêm nếu cần

### Bảo mật

⚠️ **QUAN TRỌNG**: 
- KHÔNG bao giờ commit file `.env` lên Git
- KHÔNG chia sẻ API keys với người khác
- Sử dụng API keys khác nhau cho development và production

### Production Deployment

Khi deploy lên production:
1. Tạo file `.env` mới trên server
2. Hoặc sử dụng environment variables của platform hosting
3. Đảm bảo API keys được bảo mật

### File structure sau khi setup:

```
interview_app/
├── .env                    # Environment variables (ignored by Git)
├── .gitignore             # Updated với .env
├── pubspec.yaml           # Added flutter_dotenv
├── lib/
│   └── main.dart          # Updated để load .env
└── ...
```
