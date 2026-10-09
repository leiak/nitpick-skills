[English](README.md) | 中文

# Nitpick

面向 Claude Code 和 Codex 的全方位项目审查插件。

Nitpick 对代码库进行六个维度的深度审查，识别系统性根因，并生成按依赖排序的升级路线图。

## 工作原理

```
项目画像 ──▶ 评分框架 ──▶ 六维度审查 ──▶ 跨维度综合 ──▶ 报告 + 路线图
 (Step 1)    (Step 2)      (Step 3)         (Step 4)         (Steps 5-6)
```

1. **画像**：识别项目类型（库 / 应用 / 服务 / CLI / Monorepo），据此调整各维度权重。
2. **评分框架**：共享的评分标准定义 P0-P3 严重级别、分数锚点和证据要求。
3. **维度审查**：每个维度提出诊断问题，要求 agent 阅读实际源码（而非仅看文件名）。
4. **综合**：将跨维度信号聚合为系统性根因。
5. **报告**：结构化输出评分、发现和依赖排序的路线图（先修 X 再修 Y）。

## 理论基础

每个维度植根于经典软件工程书籍的核心原则：

| 书籍 | 作者 | 融入维度 |
|------|------|----------|
| *A Philosophy of Software Design* | John Ousterhout | 架构：深模块、复杂度管理、信息隐藏 |
| *The Pragmatic Programmer* | Hunt & Thomas | 架构（正交性、DRY）、安全（Design by Contract）、DX（破窗户） |
| *Clean Code* | Robert C. Martin | 代码质量：命名、函数、错误处理、注释 |
| *Systems Performance* | Brendan Gregg | 性能：USE 方法、RED 方法 |
| *Growing Object-Oriented Software Guided by Tests* | Freeman & Pryce | 测试：测试即设计、测试金字塔 |

## 审查维度

| # | 维度 | 诊断焦点 |
|---|------|----------|
| 0 | 共享评分框架 | 严重级别定义、分数锚点、证据标准、跨维度信号 |
| 1 | 架构与设计 | 深模块 vs 浅模块。复杂度累积。信息隐藏。正交性。DRY。基础设施决策的可逆性。 |
| 2 | 代码质量 | 命名意图。函数设计。注释。错误处理。类内聚。边界。类型安全。 |
| 3 | 安全 | Design by Contract。密钥。输入校验。认证授权。依赖。数据保护。 |
| 4 | 性能 | USE 方法。RED 方法。N+1 查询。缓存。网络效率。内存。 |
| 5 | 测试与可靠性 | 测试金字塔。测试质量。Mock 优先级。反模式。CI。优雅降级。可观测性。 |
| 6 | 开发者体验 | 首次变更时间。破窗户。Tracer Bullet。Good-Enough 校准。CI。文档新鲜度。 |

## 语言支持

## 语言专属审查

除了六个通用维度外，Nitpick 还根据每种语言的经典书籍提供专属诊断问题：

| 语言 | 书籍来源 | 核心检查 |
|------|----------|----------|
| TypeScript / JavaScript | *Effective TypeScript*, *Programming TypeScript* | 类型安全、可辨识联合、禁止 any、依赖注入、async 模式 |
| Python | *Fluent Python*, *Effective Python* | Pythonic 惯用法、dunder 方法、可变默认参数、类型标注、GIL 意识 |
| Go | *Effective Go*, *100 Go Mistakes* | 小接口、错误包装、context 传播、goroutine 泄漏、竞态检测 |
| Rust | *The Rust Programming Language*, *Rust for Rustaceans* | 所有权、借用、避免 unwrap、trait 设计、newtype、async 陷阱 |
| Java | *Effective Java*, *Java Concurrency in Practice* | Builder 模式、不可变性、DI、泛型、try-with-resources、并发 |
| Kotlin | *Kotlin in Action*, Kotlin docs | 空安全（禁 `!!`）、协程、结构化并发、sealed class、scope 函数 |
| C# / .NET | *C# in Depth*, *CLR via C#*, *Adaptive Code* | 可空引用类型、LINQ 延迟执行、async/await、record、Span/Memory |
| C / C++ | *Effective C++*, *Effective Modern C++* | RAII、智能指针、虚析构、Rule of Five、`const` 正确性 |
| Swift | *The Swift Programming Language*, POP (WWDC) | 协议优于继承、值类型、Optional 安全、循环引用、Swift Concurrency |
| Ruby | *Practical Object-Oriented Design*, *Well-Grounded Rubyist* | 单一职责、依赖注入、鸭子类型、元编程、N+1 查询 |
| PHP | *Modern PHP*, PSR 标准 | `strict_types`、PSR 合规、预处理语句、`@` 抑制、框架惯用法 |

Nitpick 支持中文和英文报告输出。

- **自动检测**：Agent 匹配你的语言。用中文提问则输出中文报告。
- **显式指定**：说"用中文审查"或"review in English"。
- 默认回退为英文。

## 安装

### Claude Code

```powershell
# 项目级
Copy-Item -Recurse skills\nitpick .claude\skills\nitpick

# 或全局
Copy-Item -Recurse skills\nitpick "$env:USERPROFILE\.claude\skills\nitpick"
```

### Codex

```powershell
# 项目级
Copy-Item -Recurse skills\nitpick .agents\skills\nitpick

# 或全局
Copy-Item -Recurse skills\nitpick "$env:USERPROFILE\.agents\skills\nitpick"
```

### Gemini CLI

```powershell
# 项目级
Copy-Item -Recurse skills\nitpick .gemini\skills\nitpick

# 或全局
Copy-Item -Recurse skills\nitpick "$env:USERPROFILE\.gemini\skills\nitpick"
```

### OpenCode

```powershell
# 项目级
Copy-Item -Recurse skills\nitpick .opencode\skills\nitpick

# 或全局
Copy-Item -Recurse skills\nitpick "$env:USERPROFILE\.opencode\skills\nitpick"
```

或使用安装脚本：

```powershell
.\install.ps1              # 默认安装到两个平台
.\install.ps1 -Target claude
.\install.ps1 -Target codex
```

## Hooks

Claude Code 的 SessionStart hook 会在会话开始时注入 Nitpick 可用提醒，
确保 agent 在用户要求审查时主动使用该技能。

## 质量保障

技能内置了防止浅层审查的机制：

- **铁律（Iron Law）**：没有新鲜验证证据就不能声称完成。每条发现必须有本会话实际读取的 file:line 证据。
- **反合理化（Anti-Rationalization）**：明确阻止跳过维度、软化批评或省略证据。
- **验证清单（Verification）**：agent 声明审查完成前的 10 项自查。
- **并行审查（Parallel Review）**：支持 subagent 分发时，每个维度由独立 sub-agent 审查（见 `prompts/`）。

## 评测

Nitpick 有两层自动化测试：

| 层级 | 检查内容 | 运行方式 |
|------|----------|----------|
| 结构校验 | 文件存在、交叉引用、hook JSON、prompt 文件 | CI（`validate.ps1`，70 项） |
| 触发评测 | 正例提示命中 Nitpick，负例不命中 | CI（`node scripts/run-evals.js`） |

行为评测场景（真实 LLM 会话验证 agent 合规性）在 `evals/scenarios/` 中，按需执行，不进 CI。

## 使用

对 agent 说：

- "Nitpick this project"
- "审查这个项目"
- "用中文审查这个项目"
- "Review the architecture and code quality"

Agent 将对项目进行画像、逐维度诊断、识别跨维度根因，并将报告写入 `docs/reviews/YYYY-MM-DD-nitpick.md`。

## 报告结构

```
1. 总评分（按项目类型加权）
2. 维度评分表
3. 系统性问题（跨多个维度的根因）
4. 各维度发现（P0-P3，附 file:line 证据）
5. 升级路线图
   - 快速见效（本周）— 小改动，无依赖
   - 结构性改进（本月）— 需要重构，列出前置条件
   - 战略性提升（本季度）— 长期开发效率
```

每条发现包含：问题是什么、为什么重要、具体修复方案、file:line 引用。每项路线图条目包含：做什么、解决什么、预估工作量（S/M/L）、解锁什么。

## 项目结构

```
nitpick/
├── skills/
│   └── nitpick/
│       ├── SKILL.md              # 编排器：工作流、铁律、反合理化
│       ├── dimensions/           # 六个维度检查清单 + 共享评分框架
│       ├── languages/            # 11 种语言专属指南
│       ├── prompts/              # 并行审查 persona prompts（每维度一个）
│       └── templates/            # 报告模板（中英双语）
├── hooks/
│   ├── hooks.json                # Claude Code SessionStart hook 配置
│   └── session-start             # Bootstrap 注入脚本
├── evals/
│   ├── cases/nitpick.json        # 触发评测（CI）
│   └── scenarios/                # 行为评测场景（按需）
├── scripts/
│   └── run-evals.js              # 触发评测运行器
├── commands/
│   └── nitpick.toml              # 平台无关的 slash 命令
│           ├── 01-architecture.md
│           ├── 02-code-quality.md
│           ├── 03-security.md
│           ├── 04-performance.md
│           ├── 05-testing.md
│           └── 06-dx.md
│       └── templates/
│           ├── report-template.md
│           └── report-template.zh.md
├── templates/
│   ├── report-template.md
│   └── report-template.zh.md
├── install.ps1                   # 一键安装
├── validate.ps1                  # 自动化交叉引用验证
└── README.md
```

## 许可证

MIT

