# Setup Instructions cho Coverage Reporting

## ✅ Đã Setup Xong

### 1. SimpleCov Configuration
- ✅ Đã cấu hình trong `spec/spec_helper.rb`
- ✅ Tạo HTML và XML coverage reports
- ✅ Set minimum coverage 70%

### 2. Basic Tests
- ✅ ApplicationRecord test
- ✅ ApplicationController test  
- ✅ ApplicationJob test
- ✅ User model test

### 3. CI Workflow
- ✅ GitHub Actions với permissions
- ✅ PostgreSQL database setup
- ✅ RSpec test execution
- ✅ Coverage generation
- ✅ Conditional Codecov upload

## Bước tiếp theo

### 1. Install Dependencies
```bash
bundle install
```

### 2. Setup GitHub Secrets
1. Đi tới repository Settings > Secrets and variables > Actions
2. Thêm secret `CODECOV_TOKEN`:
   - Đăng nhập vào [codecov.io](https://codecov.io) bằng GitHub account
   - Add repository `dc-be`
   - Copy token từ repository settings
   - Paste vào GitHub Secret với tên `CODECOV_TOKEN`

### 3. Test Local
```bash
# Chạy test suite với coverage
bundle exec rspec

# Coverage report sẽ được tạo trong thư mục coverage/
open coverage/index.html
```

## File Structure
```
coverage/
├── index.html          # HTML report để xem local
├── coverage.xml        # XML report cho Codecov
└── assets/            # CSS/JS cho HTML report

tmp/
└── rspec.xml          # JUnit format cho GitHub Actions
```

## Workflow Features

✅ **Test Execution:** RSpec với JUnit output  
✅ **Coverage Generation:** SimpleCov với HTML + XML  
✅ **Test Results:** GitHub Actions UI  
✅ **Coverage Tracking:** Codecov integration  
✅ **Error Handling:** Continue on failures  
✅ **Conditional Upload:** Only when coverage exists
