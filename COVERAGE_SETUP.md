# Setup Instructions cho Coverage Reporting

## 1. Cài đặt Dependencies

```bash
bundle install
```

## 2. Setup GitHub Secrets

1. Đi tới repository Settings > Secrets and variables > Actions
2. Thêm secret `CODECOV_TOKEN`:
   - Đăng nhập vào [codecov.io](https://codecov.io) bằng GitHub account
   - Add repository `dc-be`
   - Copy token từ repository settings
   - Paste vào GitHub Secret với tên `CODECOV_TOKEN`

## 3. Chạy Tests với Coverage

```bash
# Chạy test suite với coverage
bundle exec rspec

# Coverage report sẽ được tạo trong thư mục coverage/
open coverage/index.html
```

## 4. GitHub Actions Workflow

Workflow sẽ tự động:
- Chạy tests khi có PR vào `main` hoặc `develop`
- Tạo coverage report
- Upload coverage lên Codecov
- Hiển thị test results trong PR
- Codecov sẽ comment coverage changes trong PR

## 5. File Coverage Format

- HTML report: `coverage/index.html`
- Cobertura XML: `coverage/coverage.xml` (cho Codecov)
- JUnit XML: `tmp/rspec.xml` (cho GitHub Actions)

## 6. Coverage Thresholds

- Project coverage target: 70%
- Patch coverage target: 60%
- Minimum coverage fail threshold: 70%

Điều chỉnh các thresholds này trong:
- `codecov.yml` (cho Codecov)
- `spec/spec_helper.rb` (cho local development)
