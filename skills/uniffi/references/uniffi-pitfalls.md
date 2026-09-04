# uniffi 陷阱（适用于 0.31 / 0.32）

## 错误排查优先级

遇到问题时，按以下决策树定位：

| 症状 | 最可能的原因 | 跳转到 |
|------|-------------|--------|
| 生成的 .kt 文件为空（没报错但没输出） | `strip=true` 销毁了元数据 | → 第 1 节 |
| 生成的 .kt 文件为空（或者条目少） | `lto=true` 移除了元数据段 | → 第 2 节 |
| `cargo install uniffi_bindgen` 失败（"无二进制文件"） | 0.31/0.32 的 bindgen crate 均为纯库，无二进制 | → 第 3 节 |
| `generate --library` 命令 panic | 缺少 `--out-dir` 参数 | → 第 4 节 |
| 编译错误：`uniffi::Error` derive 失败 | Error 枚举使用了元组变体 | → 第 5 节 |
| Kotlin 编译成功但 IDE 有格式警告 | ktlint 未安装 | → 第 6 节 |
| `cargo build` 中 uniffi-cli feature 未找到 | feature 命名映射不正确 | → 第 7 节 |
| 核心类型的字段不被 uniffi 接受 | 直接往核心类型加宏，而不是用 FFI 包装层 | → 第 8 节 |
| 跨 runtime panic（"Cannot start a runtime from within a runtime"） | 核心库和 uniffi 各自创建了 tokio runtime | → 第 9 节 |

---

## 1. strip=true 会销毁 UNIFFI_META

Rust 的 `strip=true`（在 Cargo.toml 的 `[profile.release]` 中）会从编译后的 .so 中移除
UNIFFI_META_* 字符串表。这会导致 `generate --library` 生成的 Kotlin/Swift 输出中没有任何函数——只有空文件。

**症状：**
- `cargo run ... -- generate --library <so>` 以代码 0 退出
- 输出目录为空（没有 .kt/.swift 文件）
- `strings <so> | grep UNIFFI_META` 没有任何输出

**修复方法：**
在 Cargo.toml 中设置 `strip="none"`。生成绑定后，
使用 NDK 的 `llvm-strip` 来压缩 .so——它会保留字符串表。

**已验证的测试：**
```
# strip 前：11 MB，UNIFFI_META=16 条目
# Rust strip 后：UNIFFI_META=0，generate 什么都不生成
# llvm-strip 后：4.0 MB，UNIFFI_META=16 条目 ✅
```

## 2. lto=true 也会移除元数据

使用 `lto=true` 时，链接器会移除"未引用"的节，包括 uniffi 元数据。
uniffi 构建务必设置 `lto=false`。

## 3. `uniffi_bindgen` 二进制文件命名

- uniffi 0.31 和 0.32 在 crates.io 上发布的 `uniffi_bindgen` crate 均为纯库（无二进制），
  `cargo install uniffi_bindgen` 会因"没有二进制文件"而失败。
- 正确的方法：在 Cargo.toml 中定义一个 `[[bin]]`，
  配合 `required-features = ["uniffi-cli"]`，然后执行
  `cargo run --features uniffi-cli --bin uniffi-bindgen`。

## 4. `generate --library` vs `generate`

- `generate --library <path.so>` — 从编译后的二进制文件中提取元数据 ✅
- `generate <udl-file>` — 读取 UDL 文件（用户拒绝使用） ❌
- `generate --library` 需要 `--out-dir`，否则会 panic

## 5. uniffi 的 Error 变体命名 + 已有 Error 类型的移植

`#[derive(uniffi::Error)]` 要求枚举变体有命名字段（0.31/0.32 均如此）。
元组变体如 `ParseError(String)` 是不允许的。

**核心原则：NEVER 修改核心库的 Error 类型。在 FFI 包装层新建 FfiError 并通过 From trait 映射。**

```rust
// ---------- 已有核心库的 Error（不修改它） ----------
pub enum CoreError {
    ParseError(String),              // 元组变体——不能直接 #[derive(uniffi::Error)]
    HttpError(u16, String),          // 同样不符合
    FatalError,                      // 无字段单元变体
}

// ---------- FFI 包装层 ----------
#[derive(uniffi::Error, Debug)]
pub enum FfiCoreError {
    ParseError { message: String },            // ✅ 命名字段
    HttpError { status: u16, message: String }, // ✅ 命名字段
    FatalError {},                             // ✅ 单元变体加显式 {}
}

// From 映射：将核心错误转换为 FFI 兼容版本
impl From<CoreError> for FfiCoreError {
    fn from(e: CoreError) -> Self {
        match e {
            CoreError::ParseError(msg) => Self::ParseError { message: msg },
            CoreError::HttpError(code, msg) => Self::HttpError { status: code, message: msg },
            CoreError::FatalError => Self::FatalError {},
        }
    }
}
```

在 FFI 导出中使用 `?` 自动转换：

```rust
#[uniffi::export]
pub fn process(input: String) -> Result<String, FfiCoreError> {
    let result = crate::process(&input)?;     // CoreError 自动转换为 FfiCoreError
    Ok(result)
}
```

**关键规则：**
- 元组变体 → 命名字段：`ParseError(String)` → `ParseError { message: String }`
- 多元素元组 → 多个命名字段：`HttpError(u16, String)` → `HttpError { status: u16, message: String }`
- 无字段单元变体 → 加 `{}`：`FatalError` → `FatalError {}`
- 有数据的变体用 `{ field_name: Type }`，不允许元组

## 6. ktlint 格式警告

生成 Kotlin 时，uniffi 会尝试运行 `ktlint` 来格式化输出。
如果 `ktlint` 未安装，它会打印警告，但生成的代码是有效的。
使用 `--no-format` 来抑制此警告。

## 7. Cargo.toml 功能命名

面向用户的特性名 `uniffi-cli` 必须映射到 `uniffi/cli`：
```toml
[features]
uniffi-cli = ["uniffi/cli"]
```

运行 `cargo run --features uniffi-cli` 会启用 uniffi crate 的 `cli` 特性，
这会拉取 `clap`、`askama` 等依赖。

## 8. 直接往核心类型加 uniffi 宏导致的编译错误

当已有库的核心类型包含非 FFI 兼容字段时，直接加 `#[derive(uniffi::Record)]` 或
`#[derive(uniffi::Error)]` 会导致编译错误。

**症状：**
- `the trait `uniffi::FfiConverter` is not implemented for `Duration``
- `the trait `uniffi::FfiConverter` is not implemented for `DateTime<Utc>``
- 错误堆栈指向核心库的 struct/enum 定义

**修复方法：**
在 `src/ffi.rs` 中创建 FFI 包装类型，将所有非兼容字段转换为 FFI 兼容的基本类型。
参见 `references/type.md` 中的"不兼容类型的转换模式"。

## 9. Async runtime 冲突

如果核心库通过 `#[tokio::main]` 创建了自己的 runtime，而 uniffi 也会在
FFI 边界自动创建另一个 tokio runtime，导致 panic。

**症状：**
```
thread 'main' panicked at 'Cannot start a runtime from within a runtime.
This happens because a function (like `block_on`) attempted to block the
current thread while the thread is being used to drive asynchronous tasks.'
```

**修复方法：**
- 方案 A（推荐）：移除核心库中的 `#[tokio::main]` 或 `Runtime::new().block_on(...)`，全部由 uniffi runtime 驱动
- 方案 B：如果必须保持多个 runtime，在 FFI 函数中通过 `Handle::current()` 获取 uniffi runtime handle 并传递给核心逻辑，让核心逻辑不在自己的 runtime 中执行
