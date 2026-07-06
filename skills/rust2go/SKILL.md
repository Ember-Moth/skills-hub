---
name: rust2go
description: Rust↔Go 双向 FFI 框架使用指南。用 Rust trait 语法定义跨语言接口，自动生成 Go 胶水代码。支持同步/异步 Rust→Go 调用、Go→Rust 回调、共享内存高频通信。在 Rust 项目中集成 Go 代码时使用。
---

# Rust2Go 使用指南

## 概述

Rust2Go 是一个 Rust↔Go 双向 FFI 框架。用户用受限的 Rust trait 语法定义跨语言接口，框架自动生成：
- Rust 侧：repr(C) Ref 类型、`ToRef`/`FromRef` 转换、Future 包装
- Go 侧：CGO export 函数、Go struct/interface、类型转换辅助函数
- 构建：bindgen 绑定生成、CGO 编译集成

## 何时使用此 Skill

- 在 Rust 项目中需要调用 Go 代码（库或服务）
- 需要用 Go 回调 Rust 函数
- 需要 Rust 与 Go 之间的高频双向通信
- 用户提到 rust2go、Rust FFI、Go CGO、跨语言调用
- 用户询问如何集成 Go 和 Rust

## 项目初始化

### 目录结构

```
project/
├── Cargo.toml
├── build.rs              # 构建：编译 Go → 生成 bindings
├── src/
│   ├── main.rs
│   └── user.rs           # IDL：定义 struct + trait
└── go/
    ├── go.mod
    ├── gen.go            # 自动生成，勿手动编辑
    └── impl.go           # 手写 Go 业务实现
```

### Cargo.toml

```toml
[dependencies]
rust2go = "0.4"

[build-dependencies]
rust2go = { version = "0.4", features = ["build"] }
```

### go.mod

```
module my-project
go 1.21
require github.com/ihciah/rust2go v0.4.0
```

### build.rs

```rust
fn main() {
    rust2go::Builder::new()
        .with_go_src("./go")
        .with_regen("./src/user.rs", "./go/gen.go")  // build 时自动重新生成 Go 代码
        .build();
}
```

**Builder 配置项：**

| 方法 | 说明 |
|---|---|
| `.with_go_src(path)` | Go 源码目录（必填） |
| `.with_regen(src, dst)` | build 时自动重新生成 Go 代码 |
| `.with_regen_arg(Args)` | 同上，带完整 CLI 参数 |
| `.with_binding(name)` | 自定义 binding 文件名，默认 `_go_bindings.rs` |
| `.with_link(LinkType::Dynamic)` | 动态链接，默认静态 |
| `.with_copy_lib(CopyLib::DefaultPath)` | 复制 .so/.dll 到 target 目录 |
| `.compiler_arg(arg)` | Go 编译器额外参数 |
| `.compiler_env(k, v)` | Go 编译器环境变量 |

### 手动生成 Go 代码（不依赖 build.rs）

```bash
cargo install rust2go-cli
rust2go-cli --src src/user.rs --dst go/gen.go --package-name main
```

CLI 参数：
- `--src`：源 Rust 文件路径
- `--dst`：目标 Go 文件路径
- `--package-name`：Go 包名（默认 `main`）
- `--go118`：Go 1.18-1.19 兼容模式
- `--without-main`：不生成 `func main(){}`
- `--no-fmt`：不执行 `go fmt`

## 定义跨语言接口（user.rs）

### 1. Binding 模块声明

```rust
pub mod binding {
    #![allow(warnings)]
    rust2go::r2g_include_binding!();         // 默认文件名
    // rust2go::r2g_include_binding!("custom_bindings.rs");  // 自定义文件名
}
```

### 2. 数据结构（必须 derive R2G）

```rust
#[derive(rust2go::R2G, Clone)]
pub struct User {
    pub name: String,
    pub age: u8,
}

#[derive(rust2go::R2G, Clone, Copy)]
pub struct Response {
    pub pass: bool,
    pub code: u32,
}

#[derive(rust2go::R2G, Clone)]
pub struct ComplexRequest {
    pub users: Vec<User>,
    pub tags: Vec<String>,
    pub raw: Vec<u8>,
}
```

### 3. Rust→Go 调用接口（#[r2g]）

```rust
#[rust2go::r2g]
pub trait MyService {
    // 同步 oneway（无返回值，调用即忘）
    fn log(user: &User);

    // 同步调用（有返回值，调用期间阻塞）
    fn check(user: &User) -> Response;

    // 异步调用（返回 Future）
    fn fetch(req: &ComplexRequest) -> impl std::future::Future<Output = Response>;

    // drop_safe 异步：传所有权而非引用，Future 可安全 drop
    #[drop_safe_ret]
    fn process(req: ComplexRequest) -> impl std::future::Future<Output = Response>;
}
```

### 4. Go→Rust 回调接口（#[g2r]，可选）

```rust
#[rust2go::g2r]
pub trait RustCallback {
    fn on_log(message: String);
    fn validate(user: User) -> Response;
}

// 必须为 {TraitName}Impl 实现 trait
impl RustCallback for RustCallbackImpl {
    fn on_log(message: String) {
        println!("[Rust] {message}");
    }
    fn validate(user: User) -> Response {
        Response { pass: user.age >= 18, code: 0 }
    }
}
```

## 类型映射

| Rust | Go | 传递方式 |
|---|---|---|
| `u8`/`u16`/`u32`/`u64` | `uint8`/`uint16`/`uint32`/`uint64` | 值拷贝 |
| `i8`/`i16`/`i32`/`i64` | `int8`/`int16`/`int32`/`int64` | 值拷贝 |
| `f32`/`f64` | `float32`/`float64` | 值拷贝 |
| `bool` | `bool` | 值拷贝 |
| `usize`/`isize` | `uint`/`int` | 值拷贝 |
| `String` | `string` | 指针+长度（零拷贝） |
| `Vec<Primitive>` | `[]Primitive` | 指针+长度（零拷贝） |
| `Vec<CustomType>` | `[]CustomType` | 单次 malloc buffer |
| `自定义 struct` | 同名 Go struct | 朴素→有 C Ref 中转 |
| `Option<T>` | `[]T` (同 Vec) | 同 Vec |

### 类型层级（影响内存分配策略）

- **Level 0（Primitive）**：`u8`/`i32`/`bool`/`f64` 等，直接传值
- **Level 1（SimpleWrapper）**：`String`、`Vec<Primitive>`，传指针+长度
- **Level 2（Complex）**：`Vec<CustomStruct>` 等嵌套，使用预计算大小的 buffer 单次 malloc

### 不支持的类型

- 泛型 struct：`struct Foo<T>` — `#[derive(R2G)]` 会跳过
- 多段路径类型：`a::b::MyType`
- 带生命周期的引用（除 `&str` → `String` 外）
- `HashMap`、`BTreeMap` 等 map 类型

## 属性参考

### trait 级别

| 属性 | 说明 |
|---|---|
| `#[rust2go::r2g]` | Rust→Go 调用接口 |
| `#[rust2go::r2g(binding = my_mod)]` | 指定 binding 模块名 |
| `#[rust2go::r2g(queue_size = 4096)]` | 共享内存队列大小（搭配 `#[mem]`） |
| `#[rust2go::g2r]` | Go→Rust 调用接口 |

### fn 级别（仅 #[r2g]）

| 属性 | 说明 |
|---|---|
| `#[drop_safe]` | async fn 不带引用参数，Future drop 安全 |
| `#[drop_safe_ret]` | 更安全：drop 时返回参数所有权，可重新发起调用 |
| `#[mem]` / `#[shm]` | 走共享内存 ring buffer（仅 oneway 或 async） |
| `#[cgo]` / `#[cgo_callback]` | 回调使用 CGO 而非 asmcall 汇编 |
| `#[go_pass_struct]` | Go 侧参数传值不传指针 |

## Go 侧实现

### impl.go 模板

```go
package main

import "fmt"

type Service struct{}

func init() {
    // 关键：注册实现。变量名必须是 {TraitName}Impl
    MyServiceImpl = Service{}
}

func (Service) log(user *User) {
    fmt.Printf("[Go] user: %s, age: %d\n", user.name, user.age)
}

func (Service) check(user *User) Response {
    return Response{pass: user.age >= 18, code: 0}
}

func (Service) fetch(req *ComplexRequest) Response {
    // 异步模式，此函数在独立 goroutine 中执行
    fmt.Printf("[Go] got %d users, %d tags\n", len(req.users), len(req.tags))
    return Response{pass: true, code: 200}
}

func (Service) process(req *ComplexRequest) Response {
    // #[drop_safe_ret] 模式
    return Response{pass: len(req.users) > 0, code: 0}
}
```

### gen.go 中的约定

自动生成的文件包含以下内容（**不要手动编辑**）：

- `var {TraitName}Impl {TraitName}` — 全局变量，Go 侧在此注册实现
- `type {TraitName} interface { ... }` — 接口定义
- `//export C{TraitName}_{fnName}` — CGO export 函数
- `new{Type}()` / `cnt{Type}()` / `ref{Type}()` / `own{Type}()` — 类型转换四件套
- `new_list_mapper()` / `ref_list_mapper()` — 泛型 list 转换辅助
- `cvt_ref()` / `cvt_ref_cap()` — 二阶段转换（先算大小再填充）

### 内存安全约定

- **Go 侧接收的是 Rust 数据的引用**，仅在调用期间有效
- 如需将数据逃逸到 Go 侧的生命周期外，**必须使用 `own{Type}()` 深拷贝**
- `new{Type}()` 浅拷贝（string 和 list 的底层引用仍指向 Rust 内存）
- `own{Type}()` 深拷贝（将 string 和 list 的底层数据复制到 Go 堆上）

## Rust 侧调用

### 同步调用

```rust
use user::{MyService, MyServiceImpl, User};

// oneway：不阻塞，不返回
MyServiceImpl::log(&user);

// 同步带返回值：阻塞直到 Go 返回
let resp: Response = MyServiceImpl::check(&user);
```

### 异步调用

```rust
// 普通异步：注意传引用时是 unsafe 的（Future drop 后 Go 侧访问悬垂指针）
let resp: Response = unsafe { MyServiceImpl::fetch(&req).await };

// drop_safe_ret 异步：安全，drop 后返回参数所有权
let (resp, (req,)) = MyServiceImpl::process(req).await;
```

### 异步安全模型

| 场景 | 签名 | Future drop 安全？ |
|---|---|---|
| 传引用，无属性 | `fn f(&T) -> impl Future` | ❌ unsafe |
| 传引用 + `#[drop_safe]` | N/A（不能有引用参数） | N/A |
| 传所有权 + `#[drop_safe]` | `fn f(T) -> impl Future` | ✅ 安全 |
| 传所有权 + `#[drop_safe_ret]` | `fn f(T) -> impl Future<Output=(R, (T,))>` | ✅ 安全，返回参数 |

**unsafe 的原因**：传引用给 Go 侧时，Future 持有 Ref 指针。如果 Future 被 drop：
1. Rust 侧释放了数据
2. Go 侧 goroutine 还在运行，继续访问已释放的内存 → use-after-free

**`#[drop_safe_ret]` 的原理**：参数所有权转移到 Go 侧后，返回的 Future 输出包含原参数元组。如果 Future 被 drop，参数仍在 Go 侧的有效引用中，Go 完成后回写结果时参数才被释放。

## 共享内存模式（高频通信）

### 何时使用

- 每秒数千到数百万次调用
- 需要避开 CGO 调用开销（G→M goroutine 切换）
- oneway 或 request-response 异步模式

### 用法

```rust
#[rust2go::r2g(queue_size = 4096)]  // ring buffer 大小
pub trait FastService {
    #[mem]                              // 标记：走共享内存
    fn emit(&self, event: &Event);      // oneway（无返回）

    #[mem]
    #[drop_safe_ret]
    fn query(&self, q: Query)           // async request-response
        -> impl std::future::Future<Output = Response>;
}
```

### 实现原理

```
Rust thread                    Go goroutine pool (ants)
    │                                │
    ├─ write ring buffer ──────────►│  (eventfd 通知)
    │                                ├─ handler 执行
    │                                ├─ 结果回写 ring buffer
    │  ◄────────────────────────────┤  (eventfd 通知唤醒 Future)
    │                                │
```

共享内存路径不使用 CGO export 函数，而是：
1. Rust 侧将参数打包为 C Ref → 写入 `WriteQueue`
2. Go 侧 `ReadQueue` 的 handler 被 eventfd 唤醒 → 从 `ants.MultiPool` 取 goroutine 执行
3. 结果回写 `WriteQueue` → Rust 侧 `Future` 被唤醒

## Go→Rust 回调

### Rust 侧（user.rs）

```rust
#[rust2go::g2r]
pub trait RustCallback {
    fn on_data(data: String);
    fn transform(input: ComplexRequest) -> Response;
}

impl RustCallback for RustCallbackImpl {
    fn on_data(data: String) { /* ... */ }
    fn transform(input: ComplexRequest) -> Response { /* ... */ }
}
```

### Go 侧调用

```go
func (s Service) handle(user *User) {
    // 调用 Rust 函数
    RustCallbackImpl{}.on_data(&user.name, &user.age)
    result := RustCallbackImpl{}.transform(&someRequest)
}
```

### 限制

- **Go→Rust 仅支持同步调用**，不支持 async
- 需要异步时在 Rust impl 中手动 `tokio::spawn`
- 所有参数都会经过 `own{Type}()` 深拷贝

## 运行

```bash
GODEBUG=invalidptr=0,cgocheck=0 cargo run
```

环境变量是必须的：
- `invalidptr=0`：Go GC 不检查栈上的指针有效性（FFI 产生的"指针"可能看起来像野指针）
- `cgocheck=0`：关闭 CGO 指针检查（框架已保证安全性）

## 常见问题排查

### Go build 失败

```
error: Go build failed
```

**原因**：Go 模块依赖未下载或环境不完整。

**解决**：
```bash
cd go && go mod tidy && cd ..
GODEBUG=invalidptr=0,cgocheck=0 cargo build
```

### cbindgen 报错

```
Unable to generate bindings
```

**原因**：通常是因为 Rust struct 中有 cbingen 不认识的类型。

**解决**：确保所有自定义 struct 都 `#[derive(R2G)]`，字段类型都在支持列表中。

### 运行时 segfault / panic

**原因**：大概率是 `GODEBUG=invalidptr=0,cgocheck=0` 没设置。

**解决**：确认环境变量。
```bash
export GODEBUG=invalidptr=0,cgocheck=0
```

### async Future 被 drop 后 Go 侧 panic

**原因**：传给 async fn 的是引用，Future drop 后 Rust 侧释放了内存，Go 侧还在用。

**解决**：使用 `#[drop_safe_ret]` 并传所有权：
```rust
// 错误：传引用，drop 不安全
fn bad(req: &Data) -> impl Future<Output = Response>;

// 正确：传所有权 + drop_safe_ret
#[drop_safe_ret]
fn good(req: Data) -> impl Future<Output = (Response, (Data,))>;
```

### 自定义 struct 字段类型报错

```
only path types are supported
types with multiple segments are not supported
```

**原因**：类型必须是单段路径，不能用 `std::collections::HashMap` 或泛型 `MyType<T>`。

**解决**：使用支持的类型（`Vec`/`String`/`Option`/基础类型/自定义 struct）。

### header 文件变化导致重编译

`build.rs` 已内置优化：编译后比对 header 内容，未变则重置 mtime 避免不必要重编译。如果问题持续，删除 `target/` 后重试。
