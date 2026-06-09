# 类型问题

## Kotlin 模块：从 uniffi.toml 导入

`uniffi.toml` 定义了：
```toml
[bindings.kotlin]
package_name = "<PACKAGE_NAME>"
cdylib_name = "<LIB_NAME>"
```

Kotlin 模块包装器必须从 uniffi.toml 中声明的包导入：
```kotlin
import <PACKAGE_NAME>.*  // ✅ 正确
import uniffi.<LIB_NAME>.*  // ❌ 错误
```

## Swift 模块：使用 uniffi.toml 中的 module_name

```toml
[bindings.swift]
module_name = "<SWIFT_MODULE>"
cdylib_name = "<LIB_NAME>"
```

Swift 包装器直接使用模块名：
```swift
<SWIFT_MODULE>.<LIB_NAME>_init()
<SWIFT_MODULE>.<LIB_NAME>_search(...)
```

---

## 基础类型映射

| Rust | Kotlin | Swift |
|------|--------|-------|
| `bool` | `Boolean` | `Bool` |
| `i8`/`i16`/`i32`/`i64` | `Byte`/`Short`/`Int`/`Long` | `Int8`/`Int16`/`Int32`/`Int64` |
| `u8`/`u16`/`u32`/`u64` | `UByte`/`UShort`/`UInt`/`ULong` | `UInt8`/`UInt16`/`UInt32`/`UInt64` |
| `f32`/`f64` | `Float`/`Double` | `Float`/`Double` |
| `String` | `String` | `String` |
| `Vec<u8>` | `List<UByte>` | `Data` |

### 泛型容器

| Rust | Kotlin | Swift |
|------|--------|-------|
| `Option<T>` | `T?` | `Optional<T>` |
| `Vec<T>` | `List<T>` | `[T]` |
| `HashMap<K,V>` | `Map<K,V>` | `[K: V]` |

### 自定义类型

| Rust | Kotlin | Swift |
|------|--------|-------|
| `#[derive(uniffi::Record)]` struct | `data class`，属性 camelCase | `struct`，属性 snake_case |
| 普通 enum | `enum class` | `enum` |
| `#[derive(uniffi::Error)]` enum | `Exception` 子类 | `Error` 枚举 |

---

## 异步函数映射

| Rust | Kotlin | Swift | Expo Module |
|------|--------|-------|-------------|
| `async fn` | `suspend fun` | `async throws` | `AsyncFunction` |

---

## 不兼容类型的转换模式

已有 Rust 库的核心类型常常包含 uniffi 无法直接导出的字段。必须在 FFI 包装层（`src/ffi.rs`）中将其转换为 FFI 兼容类型。

### 时间类型

| 核心类型 | FFI 类型 | 转换方向 | 转换代码 |
|---------|---------|---------|---------|
| `std::time::Duration` | `u64`（毫秒） | Rust→FFI | `d.as_millis() as u64` |
| | | FFI→Rust | `Duration::from_millis(ms)` |
| `std::time::Instant` | `u64`（毫秒） | Rust→FFI | `inst.elapsed().as_millis() as u64` |
| `chrono::DateTime<Utc>` | `i64`（unix timestamp） | Rust→FFI | `dt.timestamp()` |
| | | FFI→Rust | `Utc.timestamp_opt(ts, 0).unwrap()` |
| `chrono::NaiveDateTime` | `String`（ISO 8601） | Rust→FFI | `dt.format("%Y-%m-%dT%H:%M:%S").to_string()` |
| | | FFI→Rust | `NaiveDateTime::parse_from_str(&s, "%Y-%m-%dT%H:%M:%S")` |

```rust
// 示例：Duration 字段转换
#[derive(uniffi::Record)]
pub struct FfiConfig {
    pub timeout_ms: u64,        // 核心类型中的 Duration → u64
}

impl From<crate::Config> for FfiConfig {
    fn from(c: crate::Config) -> Self {
        Self {
            timeout_ms: c.timeout.as_millis() as u64,
        }
    }
}
```

### 引用类型（带 lifetime）

uniffi 不支持 lifetime 参数。所有引用必须转为自有类型：

| 核心类型 | FFI 类型 |
|---------|---------|
| `&str` | `String` |
| `&[u8]` | `Vec<u8>` |
| `&[T]` | `Vec<T>` |
| `Cow<'_, str>` | `String` |
| `&'a Path` | `String` |

### Map 类型

`HashMap<K, V>` 在 uniffi 中映射为 `Map<K, V>`，但如果 K 不是基本类型，需要转换为记录列表：

```rust
#[derive(uniffi::Record)]
pub struct FfiEntry {
    pub key: String,
    pub value: i32,
}

// HashMap<String, i32> → Vec<FfiEntry>
impl From<HashMap<String, i32>> for FfiEntryList {
    fn from(m: HashMap<String, i32>) -> Self {
        let entries: Vec<FfiEntry> = m.into_iter()
            .map(|(key, value)| FfiEntry { key, value })
            .collect();
        FfiEntryList { entries }
    }
}
```

### 动态分发类型

| 核心类型 | 处理方式 |
|---------|---------|
| `Box<dyn Trait>` | ❌ 无法直接导出。用 enum 枚举所有实现变体 |
| `Arc<dyn Trait + Send + Sync>` | ❌ 同上，改用 enum + match 分派 |
| `Arc<T>`（具体类型） | ✅ uniffi 原生支持，无需转换 |

```rust
// ❌ 无法导出
// pub fn get_handler() -> Box<dyn Handler> { ... }

// ✅ 改用 enum 枚举所有实现
pub enum HandlerType {
    LocalHandler { path: String },
    RemoteHandler { url: String },
}

impl HandlerType {
    fn to_handler(&self) -> Box<dyn Handler> {
        match self {
            Self::LocalHandler { path } => Box::new(LocalHandler::new(path)),
            Self::RemoteHandler { url } => Box::new(RemoteHandler::new(url)),
        }
    }
}
```

---

## 数据类映射

带有 `#[derive(uniffi::Record)]` 的 Rust 结构体变为：
- Kotlin：`data class`，属性使用 camelCase
- Swift：`struct`，属性使用 snake_case

Kotlin/Swift 模块包装器在构建返回映射时，必须在 snake_case（uniffi）和
camelCase（JS 约定）之间进行映射转换。

---

## 补充参考

- 多平台类型兼容性：仅 uniffi 支持的基本类型可安全跨平台。其他 Rust std 类型（`PathBuf`、`IpAddr` 等）均需手动转换为 `String` 或基本类型
- 嵌套 Record：`#[derive(uniffi::Record)]` 结构体可以嵌套其他 Record，但不能嵌套非 FFI 兼容类型
- 枚举的 associated values：Swift 支持，Kotlin 用 sealed class 模拟。复杂 enum 建议拆分为多个 Record + 标记字段
