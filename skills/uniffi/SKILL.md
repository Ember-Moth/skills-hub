---
name: uniffi
title: Rust uniffi
description: 给已有 Rust 库添加 uniffi 0.31 proc-macros FFI 导出，生成 Kotlin 绑定。涵盖 FFI 包装层架构、Android NDK 交叉编译、Kotlin 绑定生成、以及生产环境 strip 工作流程。
tags: [rust, uniffi, android-ndk, kotlin, ffi, cross-compilation]
---
# Rust uniffi

给已有 Rust 库添加 uniffi 0.31 proc-macros FFI 导出，交叉编译 Android 版本（通过 NDK），生成 Kotlin 绑定。

## 前置判断：方案选择

给已有库加 uniffi 导出有两种方案，根据库的规模和场景选择：

| 方案 | 做法 | 适用场景 |
|------|------|----------|
| **A. 在当前 crate 直接导出** | 改 Cargo.toml 加 `uniffi` deps + `cdylib` crate-type | 库较小、对编译时间不敏感、只做 Android |
| **B. 独立 ffi crate**（推荐） | 新建 `my-lib-ffi`，依赖核心库 `my-lib` | 大型库、不想污染核心 crate 的 deps、多平台 |

方案 B 的优势：
- 核心 crate 不需要引入 uniffi 及其依赖链（clap、askama 等），编译不受影响
- FFI 层的类型和核心类型解耦，改 FFI API 不影响核心逻辑
- 多平台（Android + iOS）各自的绑定配置分开管理

以下内容方案 A 和 B 均适用。若选方案 B，将 `Cargo.toml` 模板应用于 `my-lib-ffi` crate，核心库保持原样。

---

## 核心架构：FFI 包装层（必读）

### ⛔ NEVER 直接往核心类型上加 uniffi 宏

已有库的核心类型可能包含：
- 不符合 uniffi 要求的字段类型（`Duration`、`DateTime<Utc>`、`Box<dyn Trait>` 等）
- 带 lifetime 参数的结构体
- 不符合 `#[derive(uniffi::Error)]` 变体命名约束的错误枚举
- 私有字段或复杂的泛型约束

直接在核心类型上乱加宏会导致编译失败，且会污染核心 crate 的依赖。

### ✅ ALWAYS 创建 `src/ffi.rs` 作为 FFI 包装层

```
调用链：Kotlin → FFI 包装层 (src/ffi.rs) → 核心逻辑 (src/lib.rs) → 返回
```

### 完整示例

假设已有 Rust 库提供以下核心类型：

```rust
// src/lib.rs — 已有核心逻辑，不添加任何 uniffi 宏

use std::time::Duration;

pub struct SearchResult {
    pub title: String,
    pub score: f64,
    pub cached_at: Duration,          // 不兼容 uniffi 的类型
}

pub enum EngineError {
    ParseError(String),               // 元组变体，不符合 uniffi Error 要求
    HttpError(u16, String),           // 同样不符合
    EngineNotInitialized,
}

pub async fn search(query: &str) -> Result<Vec<SearchResult>, EngineError> {
    // ... 核心搜索逻辑
}
```

FFI 包装层：

```rust
// src/ffi.rs — FFI 包装层，所有 uniffi 宏集中在这里

use crate::{SearchResult, EngineError};

// 1. 为每个需要导出的核心类型创建 FFI 版本
#[derive(uniffi::Record)]
pub struct FfiSearchResult {
    pub title: String,
    pub score: f64,
    pub cached_at_ms: u64,           // Duration → 毫秒时间戳
}

impl From<SearchResult> for FfiSearchResult {
    fn from(r: SearchResult) -> Self {
        Self {
            title: r.title,
            score: r.score,
            cached_at_ms: r.cached_at.as_millis() as u64,
        }
    }
}

// 2. 新建 FFI 错误类型（符合 uniffi Error 约束：命名字段）
#[derive(uniffi::Error, Debug)]
pub enum FfiEngineError {
    ParseError { message: String },
    HttpError { code: u16, message: String },
    EngineNotInitialized {},
}

impl From<EngineError> for FfiEngineError {
    fn from(e: EngineError) -> Self {
        match e {
            EngineError::ParseError(msg) => Self::ParseError { message: msg },
            EngineError::HttpError(code, msg) => Self::HttpError { code, message: msg },
            EngineError::EngineNotInitialized => Self::EngineNotInitialized {},
        }
    }
}

// 3. 导出函数：签名使用 FFI 类型，内部委托给核心逻辑
#[uniffi::export]
pub async fn search(query: String) -> Result<Vec<FfiSearchResult>, FfiEngineError> {
    let results = crate::search(&query).await?;           // 调用核心逻辑
    Ok(results.into_iter().map(FfiSearchResult::from).collect())
}
```

在 `src/lib.rs` 中声明模块（uniffi 需要 `uniffi::setup_scaffolding` 宏）：

```rust
// src/lib.rs
mod ffi;              // FFI 包装层

uniffi::setup_scaffolding!();
```

更多不兼容类型的转换模式见 `references/type.md`。

---

## 硬约束

违反以下任何一条将导致构建失败或生成的绑定为空。

### ⛔ 禁止

- **NEVER 创建 .udl 文件**。uniffi 0.31 使用纯 proc-macro，用户拒绝任何 UDL 文件
- **NEVER 在 `[profile.release]` 中设置 `strip=true`**——会销毁 `UNIFFI_META_*` 字符串段
- **NEVER 在 `[profile.release]` 中设置 `lto=true`**——链接器会移除"未引用"的 uniffi 元数据
- **NEVER 直接往核心类型上添加 uniffi 宏**——始终通过 `src/ffi.rs` 包装层进行

### ✅ 必须

- **ALWAYS 使用 `#[uniffi::export]` / `#[derive(uniffi::Record)]` / `#[derive(uniffi::Error)]` proc-macros**
- **ALWAYS 在 `[profile.release]` 中设置 `strip="none"` 和 `lto=false`**
- **ALWAYS 从编译后的 .so 生成绑定**，而不是从源码
- **ALWAYS 创建 `src/ffi.rs` FFI 包装层**，在其中定义 FFI 专用类型和 From 转换
- **ALWAYS 在构建后使用 NDK 的 `llvm-strip` 来压缩 .so**（它保留 UNIFFI_META 元数据）

---

## Async Runtime 桥接

如果你的核心库使用了 tokio（最常见的情况），需要注意 async runtime 的衔接。

### 默认行为

uniffi 0.31 会在 FFI 边界自动创建 tokio runtime。`#[uniffi::export] async fn` 将自动在该 runtime 上执行，无需手动干预：

```rust
#[uniffi::export]
pub async fn search(query: String) -> Result<Vec<FfiSearchResult>, FfiEngineError> {
    // ✅ 直接在 FFI 包装函数中 await 核心逻辑
    crate::search(&query).await.map_err(Into::into)
}
```

### 避免跨 runtime 问题

如果核心库内部使用了 `tokio::spawn`，被 spawn 的任务默认在当前 runtime 上执行。通过带 context 的方式传递 handle：

```rust
// 核心库导出一个接受 runtime handle 的初始化函数
use tokio::runtime::Handle;

#[uniffi::export]
pub async fn init_engine(handle: Option<u64>) {
    // uniffi 自动管理 runtime，大多数场景不需要手动传 handle
    // 仅在核心库需要 spawn 子任务时，通过 Handle::current() 获取
    crate::init().await;
}
```

### 多 Runtime 冲突处理

如果核心库通过 `#[tokio::main]` 创建了自己的 runtime 而 uniffi 也创建了一个，这会导致 panic（"Cannot start a runtime from within a runtime"）。解决方案：

1. **推荐**：移除核心库中的 `#[tokio::main]`，让所有 async 逻辑由 uniffi runtime 驱动
2. **备选**：如果是库（lib crate），核心逻辑应使用 `#[tokio::test]` 做测试但不内置 `#[tokio::main]`

---

## Cargo.toml 模板

```toml
[lib]
crate-type = ["staticlib", "cdylib"]

[dependencies]
uniffi = "0.31"

[features]
uniffi-cli = ["uniffi/cli"]

[[bin]]
name = "uniffi-bindgen"
path = "bin/uniffi-bindgen.rs"
required-features = ["uniffi-cli"]

[profile.release]
opt-level = "z"
lto = false
codegen-units = 1
# strip="none": uniffi 元数据必须保留以供 bindgen 使用
strip = "none"
```

`bin/uniffi-bindgen.rs`（项目根目录下 `bin/` 目录）:
```rust
fn main() { uniffi::uniffi_bindgen_main() }
```

---

## uniffi.toml 模板

放在项目根目录，与 `Cargo.toml` 同级。

```toml
[bindings.kotlin]
package_name = "<PACKAGE_NAME>"
cdylib_name = "<LIB_NAME>"

[bindings.swift]
module_name = "<PACKAGE_NAME>"
cdylib_name = "<LIB_NAME>"
```

---

## 构建流程（Android）

```bash
# 0. 前置依赖（仅首次）
rustup target add aarch64-linux-android armv7-linux-androideabi x86_64-linux-android
cargo install cargo-ndk

# 1. 设置 NDK
export ANDROID_NDK_HOME=<NDK_PATH>  # 例如 /opt/android-sdk/ndk/27.1.12297006

# 2. 交叉编译（strip=none，元数据完整）
cargo ndk -t aarch64-linux-android -t armv7-linux-androideabi \
  -t x86_64-linux-android -o ../jniLibs build --release

# 3. 生成 Kotlin 绑定（从 .so 读取 UNIFFI_META）
cargo run --features uniffi-cli --bin uniffi-bindgen -- generate \
  --library ../jniLibs/arm64-v8a/lib<LIB_NAME>.so \
  --language kotlin --out-dir ../src/main/java

# 4. 使用 NDK llvm-strip 精简 .so（保留 UNIFFI_META）
STRIP=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip
$STRIP ../jniLibs/arm64-v8a/lib<LIB_NAME>.so

# 5. 验证
strings ../jniLibs/arm64-v8a/lib<LIB_NAME>.so | grep -c UNIFFI_META
# 输出应 > 0（通常 10-20 个条目）
ls ../src/main/java/uniffi/**/*.kt
# 应有生成的 Kotlin 文件
```

---

## Kotlin 端使用

```kotlin
import <PACKAGE_NAME>.*

// 调用从 Rust async fn 导出的 Kotlin suspend fun
lifecycleScope.launch {
    val results = search("some query")  // suspend fun
    results.forEach { result ->
        println("${result.title} - score: ${result.score}")
    }
}
```

---

## 参考资料

- `references/uniffi-pitfalls.md` — 真实构建中的详细陷阱记录 + 错误排查决策树
- `references/type.md` — 类型问题，含不兼容类型的转换模式
