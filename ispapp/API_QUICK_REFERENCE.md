# 🚀 Quick Reference: AppNetworkHelper API

## Basic Usage

```dart
import 'package:ispapp/core/services/api_service.dart';
import 'package:ispapp/core/helpers/network_helper.dart';
```

---

## Common Patterns

### ✅ GET Request
```dart
final response = await ApiService.instance.get<MyModel>(
  '/api/endpoint',
  mapper: (data) => MyModel.fromJson(data),
);

if (response.success) {
  print(response.data?.name);
}
```

### ✅ POST Request
```dart
final response = await ApiService.instance.post<ResponseModel>(
  '/api/endpoint',
  data: {'key': 'value'},
  mapper: (data) => ResponseModel.fromJson(data),
);
```

### ✅ PUT Request
```dart
final response = await ApiService.instance.put<MyModel>(
  '/api/endpoint/123',
  data: {'name': 'Updated Name'},
  mapper: (data) => MyModel.fromJson(data),
);
```

### ✅ DELETE Request
```dart
final response = await ApiService.instance.delete<dynamic>(
  '/api/endpoint/123',
);
```

---

## Response Handling

### Pattern 1: Basic Check
```dart
if (response.success) {
  // Success
  print(response.data);
} else {
  // Error
  print(response.message);
}
```

### Pattern 2: Handle Response Helper
```dart
try {
  final data = ApiService.instance.handleResponse(response);
  // Use data (throws if error)
} catch (errorMessage) {
  print('Error: $errorMessage');
}
```

### Pattern 3: Safe Extraction
```dart
final data = ApiService.instance.getDataOrNull(response);
if (data != null) {
  // Use data
}
```

---

## Error Status Codes

| Status | Meaning |
|--------|---------|
| 0 | No internet connection |
| 200 | Success |
| 401 | Unauthorized (invalid/expired token) |
| 403 | Forbidden (no permission) |
| 404 | Not found |
| 422 | Validation error |
| 500+ | Server error |

---

## Common Use Cases

### Check Internet
```dart
if (!await ApiService.instance.hasInternet()) {
  Get.snackbar('No Internet', 'Check connection');
  return;
}
```

### Query Parameters
```dart
final response = await ApiService.instance.get(
  '/api/search',
  queryParameters: {
    'q': 'search term',
    'page': '1',
    'limit': '20',
  },
);
```

### Custom Headers
```dart
final response = await ApiService.instance.post(
  '/api/endpoint',
  data: {...},
  headers: {
    'Custom-Header': 'value',
  },
);
```

### List Response
```dart
final response = await ApiService.instance.get<List<Item>>(
  '/api/items',
  mapper: (data) {
    if (data is List) {
      return data.map((item) => Item.fromJson(item)).toList();
    }
    return <Item>[];
  },
);
```

---

## Controller Integration

```dart
class MyController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final data = Rx<MyModel?>(null);

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await ApiService.instance.get<MyModel>(
      '/api/data',
      mapper: (json) => MyModel.fromJson(json),
    );

    if (response.success) {
      data.value = response.data;
    } else {
      errorMessage.value = response.message;
    }

    isLoading.value = false;
  }
}
```

---

## Tips

1. ✅ Always use typed responses with `mapper`
2. ✅ Check `response.success` before using `response.data`
3. ✅ Handle no internet (status = 0)
4. ✅ Handle 401 errors (redirect to login)
5. ✅ Use loading states in UI
6. ✅ Show error messages to users
7. ✅ Log errors for debugging

---

That's it! Simple and powerful. 🚀
