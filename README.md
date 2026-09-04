# skills-hub

Claude Code / Codex 可用的个人 skills 集合。每个 skill 是一个独立目录，包含 `SKILL.md`（入口 + frontmatter）和按需加载的参考文件。

## Skills

| Skill | 说明 |
|---|---|
| [gpui-kit](skills/gpui-kit/) | GPUI Kit（`gpui-kit` crate）桌面应用开发指南：组件目录、编码规范（Coding Guides）、GPUI 机制参考（entity/element/event/async/test 等）。**从上游 [longbridge/gpui-kit](https://github.com/longbridge/gpui-kit) 自动同步，勿本地编辑** |
| [gpui-kit-design-guides](skills/gpui-kit-design-guides/) | GPUI Kit 桌面应用的规范设计指南：视觉语言、布局、交互状态、浮层、动效、文案、无障碍。**同样从上游自动同步** |
| [design-md](skills/design-md/) | DESIGN.md 工作流：在仓库根建立视觉设计契约（Google Labs design.md 格式），从 VoltAgent 风格目录采纳/混搭风格，lint 与一致性审计 |
| [rust2go](skills/rust2go/) | Rust↔Go 双向 FFI 框架使用指南：trait 定义跨语言接口、类型映射、异步安全模型、共享内存高频通信、排错 |
| [tauri-android-native-plugin](skills/tauri-android-native-plugin/) | Tauri v2 Android 插件开发：包装 AAR 原生库、VpnService/前台服务、gomobile 绑定、权限与生命周期踩坑清单 |
| [uniffi](skills/uniffi/) | 给已有 Rust 库加 uniffi proc-macro FFI 导出（0.31/0.32）：FFI 包装层架构、Android NDK 交叉编译、Kotlin 绑定、strip 工作流 |
| [龙族文风](skills/龙族文风/) | 从《龙族》全系列蒸馏的通用中文文学写作体系：叙事工程、人物构建、修辞工厂、情感工程、场景模板 |

## 使用方式

把需要的 skill 目录链接或复制到 `~/.claude/skills/`：

```bash
# 方式一：软链（推荐，仓库更新即生效）
ln -s "$PWD/skills/gpui-kit" ~/.claude/skills/gpui-kit

# 方式二：复制
cp -R skills/gpui-kit ~/.claude/skills/
```

之后在 Claude Code 中通过 `/skill名` 调用，或由模型按任务描述自动触发。

## 上游同步

`skills/gpui-kit` 和 `skills/gpui-kit-design-guides` 是 [longbridge/gpui-kit](https://github.com/longbridge/gpui-kit) 官方 skills 的逐字节镜像，由 [.github/workflows/sync-gpui-skills.yml](.github/workflows/sync-gpui-skills.yml) 每周自动同步（也可在 Actions 页面手动触发）。上游有变化时 workflow 会直接提交到 main，commit message 带上游 SHA。

对这两个目录的本地修改会在下次同步时被覆盖——要改进请提到上游。

## 维护约定

- **目录名 == frontmatter 的 `name:`**（如 `skills/design-md/` 对应 `name: design-md`）
- **不写机器特定路径**（`/root/...`、`/Users/...`），缓存路径用 `$CARGO_HOME` 等环境变量表达
- **API 示例必须验证过**：来自编译通过的代码、官方文档或上游源码，不凭猜测写方法签名
- 锁定版本的知识要在文中注明适用版本及核对日期

## License

见 [LICENSE](LICENSE)。单个 skill 目录如来自上游（gpui-kit 系列），其内容遵循上游仓库的许可证。
