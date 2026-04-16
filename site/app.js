const translations = {
  en: {
    meta: {
      title: "GetXDrop | GetX Migration Starts Here",
      description:
        "GetXDrop is a CLI-first migration workbench for legacy GetX Flutter apps.",
    },
    lang: { label: "Language" },
    brand: { sub: "Open-source migration workbench" },
    nav: {
      why: "Why",
      features: "Features",
      artifacts: "Artifacts",
      roadmap: "Roadmap",
    },
    hero: {
      badge: "v0.1 alpha candidate",
      title: "When GetX becomes uncertain,<br />migration planning cannot wait.",
      body:
        "GetXDrop audits legacy GetX Flutter apps and turns them into a migration map: route inventory, network inventory, controller complexity, and explainable findings.",
      primaryCta: "Read the README",
      secondaryCta: "See quickstart",
      stats: {
        commands: "public commands",
        slices: "planning slices shipped",
        ci: "analyze + test baseline",
      },
    },
    terminal: {
      kicker: "CLI preview",
      note: "Real output, not mock migration theater",
    },
    proof: {
      kicker: "What v0.1 already surfaces",
      title: "Planning output built for a first public release.",
      item1: "Route declarations, bindings, middleware, and argument access in one place.",
      item2: "GetConnect clients mapped before transport rewrites begin.",
      item3: "Controller risk scored by size, DI, lifecycle, nav, and API coupling.",
    },
    why: {
      kicker: "Why this exists",
      title: "Not a rewrite wizard. A migration pressure valve.",
      body:
        "In the first 48 hours, teams do not need false confidence. They need a fast way to see what is coupled, what is risky, and what should move first.",
      card1: {
        title: "Route coupling",
        body:
          "Pages, bindings, middleware, and `Get.arguments` become visible together instead of hiding across files.",
      },
      card2: {
        title: "Hidden network behavior",
        body:
          "`GetConnect` request modifiers, authenticators, and decoders are surfaced before network migration starts.",
      },
      card3: {
        title: "Controller sprawl",
        body:
          "Complexity scoring shows where state, DI, lifecycle, navigation, and API work are mixed into one controller.",
      },
    },
    features: {
      kicker: "Available now",
      title: "Shipping the report first, so teams can trust the next step.",
      body:
        "GetXDrop is deliberately conservative. The current release focuses on analysis, planning, and explainability before rewrite automation.",
      audit: {
        tag: "Audit",
        title: "Machine-readable inventory",
        body:
          "Generate stable JSON artifacts for CI, local review, and migration planning workflows.",
      },
      routing: {
        tag: "Routing",
        title: "Route inventory",
        body:
          "Track declarations, invocations, middleware, bindings, and argument access in one view.",
      },
      network: {
        tag: "Network",
        title: "GetConnect surface map",
        body:
          "Pull out request modifiers, authenticators, decoders, and public client methods before transport migration.",
      },
      controllers: {
        tag: "Controllers",
        title: "Complexity scoring",
        body:
          "Score controller risk by size, dependencies, lifecycle, navigation, API calls, and global lookups.",
      },
      explain: {
        tag: "Explainability",
        title: "Finding drill-down",
        body:
          "Every finding can answer why it is risky, what to do next, and which migration step it supports.",
      },
      trust: {
        tag: "Trust",
        title: "Fixture + CI",
        body:
          "Sample app regression and workspace CI keep the release from drifting silently.",
      },
    },
    artifacts: {
      kicker: "Artifacts",
      title: "Three outputs, one migration conversation.",
      body:
        "The tool writes one raw inventory, one structured planning report, and one human-readable report.",
      inventory:
        "Raw audit result with findings and parse failures for CI and machine workflows.",
      reportJson:
        "Structured planning output with route, network, controller, and finding drill-down sections.",
      reportMd:
        "Human-readable report for triage, handoff, release-day visibility, and team discussion.",
      previewTitle: "Structured planning output",
    },
    quickstart: {
      kicker: "Quickstart",
      title: "Use the sample app to see the full loop in minutes.",
      step1: { title: "Pin the toolchain" },
      step2: { title: "Run the CLI" },
      step3: { title: "Read the migration shape" },
    },
    roadmap: {
      kicker: "Roadmap",
      title: "Public release first. Smarter automation later.",
      body:
        "The near-term goal is a trustworthy open-source release, not a louder promise.",
      now: {
        label: "Now",
        item1: "`doctor`, `audit`, `report`",
        item2: "route / network / controller planning slices",
        item3: "explainable finding drill-down",
      },
      next: {
        label: "Next",
        item1: "`getxdrop.yaml` project config support",
        item2: "schema versioning and validation",
        item3: "sharper CI and PR-friendly summaries",
      },
      later: {
        label: "Later",
        item1: "`scaffold` assistant",
        item2: "`apply-safe` dry-run candidates",
        item3: "richer explain, diff, and stats workflows",
      },
    },
    cta: {
      kicker: "Open-source release track",
      title: "Start with the report. Earn trust before automation.",
      body:
        "GetXDrop is being shaped as a fast-response open-source tool for teams that need migration clarity without theater.",
      primary: "Read the changelog",
      secondary: "Open roadmap",
    },
  },
  ko: {
    meta: {
      title: "GetXDrop | GetX 마이그레이션은 여기서 시작됩니다",
      description:
        "GetXDrop는 레거시 GetX Flutter 앱을 위한 CLI 중심 마이그레이션 워크벤치입니다.",
    },
    lang: { label: "언어" },
    brand: { sub: "오픈소스 마이그레이션 워크벤치" },
    nav: {
      why: "왜 필요한가",
      features: "기능",
      artifacts: "산출물",
      roadmap: "로드맵",
    },
    hero: {
      badge: "v0.1 알파 후보",
      title: "GetX가 흔들릴 때,<br />마이그레이션 계획은 기다려주지 않습니다.",
      body:
        "GetXDrop는 레거시 GetX Flutter 앱을 분석해 route inventory, network inventory, controller complexity, explainable findings로 정리해 주는 마이그레이션 플래닝 도구입니다.",
      primaryCta: "README 보기",
      secondaryCta: "빠른 시작 보기",
      stats: {
        commands: "공개 명령어",
        slices: "제공 중인 planning slice",
        ci: "analyze + test 기준선",
      },
    },
    terminal: {
      kicker: "CLI 미리보기",
      note: "과장된 데모가 아닌 실제 출력",
    },
    proof: {
      kicker: "v0.1에서 바로 확인할 수 있는 것",
      title: "첫 공개 릴리즈에 필요한 planning output이 이미 준비되어 있습니다.",
      item1: "route declaration, binding, middleware, argument access를 한곳에서 확인할 수 있습니다.",
      item2: "transport rewrite에 들어가기 전에 `GetConnect` 클라이언트 구성을 먼저 드러냅니다.",
      item3: "controller 위험도를 크기, DI, lifecycle, navigation, API 결합도 기준으로 점수화합니다.",
    },
    why: {
      kicker: "왜 이 프로젝트인가",
      title: "자동 rewrite 마법이 아니라, 마이그레이션 압력을 낮추는 도구입니다.",
      body:
        "처음 48시간에 팀이 필요한 것은 과장된 자신감이 아닙니다. 무엇이 결합되어 있고, 무엇이 위험하며, 무엇부터 옮겨야 하는지 빠르게 파악할 수 있어야 합니다.",
      card1: {
        title: "Route coupling",
        body:
          "page, binding, middleware, `Get.arguments`를 여러 파일에서 헤매지 않고 한 시야에서 파악할 수 있습니다.",
      },
      card2: {
        title: "숨겨진 네트워크 동작",
        body:
          "network migration을 시작하기 전에 `GetConnect`의 request modifier, authenticator, decoder를 먼저 드러냅니다.",
      },
      card3: {
        title: "Controller 비대화",
        body:
          "state, DI, lifecycle, navigation, API 작업이 하나의 controller에 얼마나 얽혀 있는지 보여줍니다.",
      },
    },
    features: {
      kicker: "현재 제공 기능",
      title: "다음 단계를 믿을 수 있도록, 먼저 report를 제공합니다.",
      body:
        "GetXDrop는 의도적으로 보수적으로 설계되었습니다. 현재 릴리즈는 자동 rewrite보다 분석, planning, explainability에 집중합니다.",
      audit: {
        tag: "Audit",
        title: "Machine-readable inventory",
        body:
          "CI, 로컬 검토, migration planning workflow에 바로 연결할 수 있는 안정적인 JSON 산출물을 생성합니다.",
      },
      routing: {
        tag: "Routing",
        title: "Route inventory",
        body:
          "declaration, invocation, middleware, binding, argument access를 한 화면에서 정리합니다.",
      },
      network: {
        tag: "Network",
        title: "GetConnect surface map",
        body:
          "transport migration 전에 request modifier, authenticator, decoder, public method를 먼저 파악할 수 있습니다.",
      },
      controllers: {
        tag: "Controllers",
        title: "Complexity scoring",
        body:
          "controller 위험도를 크기, dependency, lifecycle, navigation, API call, global lookup 기준으로 점수화합니다.",
      },
      explain: {
        tag: "Explainability",
        title: "Finding drill-down",
        body:
          "각 finding마다 왜 위험한지, 다음에 무엇을 해야 하는지, 어떤 migration step과 연결되는지를 설명합니다.",
      },
      trust: {
        tag: "Trust",
        title: "Fixture + CI",
        body:
          "sample app regression과 workspace CI로 초기 릴리즈의 신뢰도를 꾸준히 지켜냅니다.",
      },
    },
    artifacts: {
      kicker: "산출물",
      title: "세 가지 출력으로, 하나의 마이그레이션 대화를 시작합니다.",
      body:
        "도구는 raw inventory, structured planning report, 사람이 읽기 좋은 report를 각각 생성합니다.",
      inventory:
        "CI와 자동화 워크플로를 위한 raw audit 결과입니다. findings와 parse failures를 함께 담습니다.",
      reportJson:
        "route, network, controller, finding drill-down 섹션을 담는 structured planning output입니다.",
      reportMd:
        "triage, handoff, 공개일 가시성, 팀 논의를 위한 사람이 읽기 좋은 report입니다.",
      previewTitle: "Structured planning output",
    },
    quickstart: {
      kicker: "빠른 시작",
      title: "sample app으로 몇 분 안에 전체 흐름을 확인할 수 있습니다.",
      step1: { title: "툴체인 고정" },
      step2: { title: "CLI 실행" },
      step3: { title: "마이그레이션 결과 확인" },
    },
    roadmap: {
      kicker: "로드맵",
      title: "먼저 공개 릴리즈를 만들고, 그다음 더 똑똑한 자동화로 갑니다.",
      body:
        "가까운 목표는 더 큰 약속이 아니라, 실제로 믿고 써볼 수 있는 오픈소스 릴리즈를 만드는 것입니다.",
      now: {
        label: "현재",
        item1: "`doctor`, `audit`, `report`",
        item2: "route / network / controller planning slice",
        item3: "explainable finding drill-down",
      },
      next: {
        label: "다음",
        item1: "`getxdrop.yaml` 프로젝트 설정 지원",
        item2: "schema versioning 및 validation",
        item3: "더 정교한 CI와 PR 친화적 요약",
      },
      later: {
        label: "이후",
        item1: "`scaffold` assistant",
        item2: "`apply-safe` dry-run candidate",
        item3: "더 풍부한 explain / diff / stats workflow",
      },
    },
    cta: {
      kicker: "오픈소스 릴리즈 트랙",
      title: "먼저 report로 시작하고, 자동화는 충분한 신뢰를 얻은 뒤에 갑니다.",
      body:
        "GetXDrop는 과장된 연출보다 migration clarity가 필요한 팀을 위한 fast-response 오픈소스 도구로 다듬어지고 있습니다.",
      primary: "변경 이력 보기",
      secondary: "로드맵 열기",
    },
  },
  ja: {
    meta: {
      title: "GetXDrop | GetX 移行はここから始まる",
      description:
        "GetXDrop は、レガシーな GetX Flutter アプリのための CLI ファーストな移行ワークベンチです。",
    },
    lang: { label: "言語" },
    brand: { sub: "オープンソースの移行ワークベンチ" },
    nav: {
      why: "Why",
      features: "機能",
      artifacts: "成果物",
      roadmap: "ロードマップ",
    },
    hero: {
      badge: "v0.1 alpha candidate",
      title: "GetX が不確実になったとき、<br />移行計画は待ってくれません。",
      body:
        "GetXDrop はレガシーな GetX Flutter アプリを監査し、route inventory、network inventory、controller complexity、explainable findings として移行の全体像を整理します。",
      primaryCta: "README を読む",
      secondaryCta: "クイックスタートを見る",
      stats: {
        commands: "公開コマンド",
        slices: "提供中の planning slice",
        ci: "analyze + test の基準線",
      },
    },
    terminal: {
      kicker: "CLI プレビュー",
      note: "見せかけではなく実際の出力",
    },
    proof: {
      kicker: "v0.1 で、すでに見えるもの",
      title: "最初の公開リリースに必要な planning output は、すでに揃っています。",
      item1: "route declaration、binding、middleware、argument access を 1 か所で確認できます。",
      item2: "`GetConnect` のクライアント構成を、transport rewrite の前に洗い出せます。",
      item3: "controller のリスクを、規模、DI、lifecycle、navigation、API 結合度でスコア化します。",
    },
    why: {
      kicker: "なぜこのプロジェクトが必要か",
      title: "書き換えの魔法ではなく、移行の圧力を逃がすためのツールです。",
      body:
        "最初の 48 時間に必要なのは、根拠のない安心感ではありません。何が結合していて、何が危険で、何から手を付けるべきかを、すばやく把握することです。",
      card1: {
        title: "Route coupling",
        body:
          "page、binding、middleware、`Get.arguments` を、複数ファイルに埋もれさせず一つの視点で確認できます。",
      },
      card2: {
        title: "隠れた network behavior",
        body:
          "`GetConnect` の request modifier、authenticator、decoder を、network migration の前に可視化します。",
      },
      card3: {
        title: "Controller の肥大化",
        body:
          "state、DI、lifecycle、navigation、API work が、一つの controller にどれだけ集中しているかを示します。",
      },
    },
    features: {
      kicker: "現在利用可能",
      title: "次の一歩を信頼できるように、まず report を届けます。",
      body:
        "GetXDrop は意図的に保守的です。現在のリリースは、自動 rewrite よりも analysis、planning、explainability に重点を置いています。",
      audit: {
        tag: "Audit",
        title: "Machine-readable inventory",
        body:
          "CI、ローカルレビュー、migration planning workflow にそのまま組み込める、安定した JSON artifact を生成します。",
      },
      routing: {
        tag: "Routing",
        title: "Route inventory",
        body:
          "declaration、invocation、middleware、binding、argument access を、一つの view で追跡できます。",
      },
      network: {
        tag: "Network",
        title: "GetConnect surface map",
        body:
          "transport migration の前に、request modifier、authenticator、decoder、public method を整理します。",
      },
      controllers: {
        tag: "Controllers",
        title: "Complexity scoring",
        body:
          "controller risk を、規模、dependency、lifecycle、navigation、API call、global lookup でスコア化します。",
      },
      explain: {
        tag: "Explainability",
        title: "Finding drill-down",
        body:
          "各 finding について、なぜ危険なのか、次に何をすべきか、どの migration step を支えるのかを説明します。",
      },
      trust: {
        tag: "Trust",
        title: "Fixture + CI",
        body:
          "sample app regression と workspace CI によって、初期リリースの信頼性を保ちます。",
      },
    },
    artifacts: {
      kicker: "成果物",
      title: "3 つの出力で、1 つの migration conversation を支えます。",
      body:
        "このツールは、raw inventory、structured planning report、human-readable report の 3 つを生成します。",
      inventory:
        "CI と自動化 workflow 向けの raw audit result です。findings と parse failures を含みます。",
      reportJson:
        "route、network、controller、finding drill-down section を持つ structured planning output です。",
      reportMd:
        "triage、handoff、release day の可視化、チーム内の共有に向いた human-readable report です。",
      previewTitle: "Structured planning output",
    },
    quickstart: {
      kicker: "Quickstart",
      title: "sample app を使えば、数分で全体の流れを確認できます。",
      step1: { title: "toolchain を固定する" },
      step2: { title: "CLI を実行する" },
      step3: { title: "migration result を読む" },
    },
    roadmap: {
      kicker: "ロードマップ",
      title: "まずは公開リリース。その先に、より賢い automation を。",
      body:
        "直近の目標は、大きな約束を掲げることではなく、信頼して試せるオープンソースの公開です。",
      now: {
        label: "現在",
        item1: "`doctor`, `audit`, `report`",
        item2: "route / network / controller planning slice",
        item3: "explainable finding drill-down",
      },
      next: {
        label: "次に",
        item1: "`getxdrop.yaml` のプロジェクト設定対応",
        item2: "schema versioning と validation",
        item3: "より洗練された CI と PR 向けサマリー",
      },
      later: {
        label: "今後",
        item1: "`scaffold` assistant",
        item2: "`apply-safe` dry-run candidate",
        item3: "より豊かな explain / diff / stats workflow",
      },
    },
    cta: {
      kicker: "オープンソース公開トラック",
      title: "まずは report から。automation の前に、信頼を積み上げる。",
      body:
        "GetXDrop は、過剰な演出ではなく migration clarity を必要とするチームのための fast-response open-source tool として磨かれています。",
      primary: "変更履歴を見る",
      secondary: "ロードマップを開く",
    },
  },
  zh: {
    meta: {
      title: "GetXDrop | 从这里开始迁移 GetX",
      description:
        "GetXDrop 是一款面向遗留 GetX Flutter 应用、以 CLI 为中心的迁移工作台。",
    },
    lang: { label: "语言" },
    brand: { sub: "开源迁移工作台" },
    nav: {
      why: "为什么",
      features: "功能",
      artifacts: "产物",
      roadmap: "路线图",
    },
    hero: {
      badge: "v0.1 alpha candidate",
      title: "当 GetX 变得不再确定，<br />迁移规划就不能继续等待。",
      body:
        "GetXDrop 会审计遗留的 GetX Flutter 应用，并将结果整理为 route inventory、network inventory、controller complexity 和 explainable findings，帮助团队更快看清迁移全貌。",
      primaryCta: "查看 README",
      secondaryCta: "查看快速开始",
      stats: {
        commands: "公开命令",
        slices: "已交付的 planning slice",
        ci: "analyze + test 基线",
      },
    },
    terminal: {
      kicker: "CLI 预览",
      note: "真实输出，而不是迁移表演",
    },
    proof: {
      kicker: "v0.1 已经能够呈现的内容",
      title: "首次公开发布需要的 planning output，已经具备。",
      item1: "在同一个视图里看到 route declaration、binding、middleware 和 argument access。",
      item2: "在开始 transport rewrite 之前，先梳理清楚 `GetConnect` 客户端表面结构。",
      item3: "按规模、DI、lifecycle、navigation 和 API coupling 为 controller 风险打分。",
    },
    why: {
      kicker: "为什么要做这个项目",
      title: "它不是 rewrite 魔法，而是帮助团队缓解迁移压力的工具。",
      body:
        "在最初的 48 小时里，团队最不需要的是虚假的安全感。真正需要的是快速看清哪些地方耦合严重、哪些风险最高、应该先从哪里动手。",
      card1: {
        title: "Route coupling",
        body:
          "page、binding、middleware 和 `Get.arguments` 不再分散隐藏，而是被放到同一个视角下统一查看。",
      },
      card2: {
        title: "隐藏的网络行为",
        body:
          "在开始 network migration 之前，先把 `GetConnect` 的 request modifier、authenticator、decoder 梳理出来。",
      },
      card3: {
        title: "Controller 膨胀",
        body:
          "complexity scoring 会帮助你看见 state、DI、lifecycle、navigation 和 API work 是如何挤在同一个 controller 里的。",
      },
    },
    features: {
      kicker: "当前可用",
      title: "先交付值得信任的 report，再谈下一步自动化。",
      body:
        "GetXDrop 有意保持克制。当前版本优先聚焦 analysis、planning 和 explainability，而不是急着做 rewrite automation。",
      audit: {
        tag: "Audit",
        title: "Machine-readable inventory",
        body:
          "生成稳定的 JSON artifact，可直接接入 CI、本地审查和 migration planning workflow。",
      },
      routing: {
        tag: "Routing",
        title: "Route inventory",
        body:
          "把 declaration、invocation、middleware、binding 和 argument access 放在一个视图中统一追踪。",
      },
      network: {
        tag: "Network",
        title: "GetConnect surface map",
        body:
          "在 transport migration 之前，先提取 request modifier、authenticator、decoder 和 public method。",
      },
      controllers: {
        tag: "Controllers",
        title: "Complexity scoring",
        body:
          "按规模、dependency、lifecycle、navigation、API call 和 global lookup 为 controller 风险评分。",
      },
      explain: {
        tag: "Explainability",
        title: "Finding drill-down",
        body:
          "每个 finding 都会说明它为什么有风险、下一步该做什么，以及它支撑的是哪一步迁移。",
      },
      trust: {
        tag: "Trust",
        title: "Fixture + CI",
        body:
          "通过 sample app regression 和 workspace CI，持续守住早期版本的可信度。",
      },
    },
    artifacts: {
      kicker: "产物",
      title: "三个输出，支撑一场更清晰的迁移对话。",
      body:
        "工具会生成 raw inventory、structured planning report，以及面向团队沟通的人类可读 report。",
      inventory:
        "面向 CI 与自动化流程的 raw audit result，包含 findings 和 parse failures。",
      reportJson:
        "包含 route、network、controller 与 finding drill-down section 的 structured planning output。",
      reportMd:
        "适合 triage、handoff、发布日可视化和团队讨论的人类可读 report。",
      previewTitle: "Structured planning output",
    },
    quickstart: {
      kicker: "快速开始",
      title: "通过 sample app，几分钟内就能看完整个流程。",
      step1: { title: "固定 toolchain" },
      step2: { title: "运行 CLI" },
      step3: { title: "查看迁移结果" },
    },
    roadmap: {
      kicker: "路线图",
      title: "先完成公开发布，再逐步走向更聪明的 automation。",
      body:
        "近期目标不是喊出更大的口号，而是交付一个真正值得信任的开源版本。",
      now: {
        label: "当前",
        item1: "`doctor`, `audit`, `report`",
        item2: "route / network / controller planning slice",
        item3: "explainable finding drill-down",
      },
      next: {
        label: "下一步",
        item1: "`getxdrop.yaml` 项目配置支持",
        item2: "schema versioning 与 validation",
        item3: "更完整的 CI 与更适合 PR 的摘要输出",
      },
      later: {
        label: "后续",
        item1: "`scaffold` assistant",
        item2: "`apply-safe` dry-run candidate",
        item3: "更丰富的 explain / diff / stats workflow",
      },
    },
    cta: {
      kicker: "开源发布路线",
      title: "先从 report 开始，在 automation 之前赢得信任。",
      body:
        "GetXDrop 正在被打磨成一款快速响应的开源工具，服务于那些真正需要 migration clarity 而不是热闹演示的团队。",
      primary: "查看更新日志",
      secondary: "打开路线图",
    },
  },
  es: {
    meta: {
      title: "GetXDrop | La migración de GetX empieza aquí",
      description:
        "GetXDrop es un espacio de migración open source, centrado en CLI, para aplicaciones Flutter heredadas con GetX.",
    },
    lang: { label: "Idioma" },
    brand: { sub: "Migration workbench open source" },
    nav: {
      why: "Por qué",
      features: "Funciones",
      artifacts: "Artefactos",
      roadmap: "Roadmap",
    },
    hero: {
      badge: "v0.1 alpha candidate",
      title: "Cuando GetX deja de ser predecible,<br />la planificación de migración no puede esperar.",
      body:
        "GetXDrop audita apps Flutter heredadas con GetX y las convierte en un mapa de migración: route inventory, network inventory, controller complexity y explainable findings.",
      primaryCta: "Leer el README",
      secondaryCta: "Ver quickstart",
      stats: {
        commands: "comandos públicos",
        slices: "planning slices disponibles",
        ci: "baseline de analyze + test",
      },
    },
    terminal: {
      kicker: "Vista previa del CLI",
      note: "Salida real, no teatro de migración",
    },
    proof: {
      kicker: "Lo que v0.1 ya pone sobre la mesa",
      title: "El planning output necesario para una primera release pública ya está aquí.",
      item1: "Route declarations, bindings, middleware y argument access, reunidos en un solo lugar.",
      item2: "Los clientes de `GetConnect` quedan mapeados antes de empezar los transport rewrites.",
      item3: "El riesgo de cada controller se puntúa por tamaño, DI, lifecycle, navegación y acoplamiento con la API.",
    },
    why: {
      kicker: "Por qué existe",
      title: "No es magia de rewrite. Es una válvula de alivio para la migración.",
      body:
        "En las primeras 48 horas, un equipo no necesita confianza vacía. Necesita ver con rapidez qué está acoplado, qué es riesgoso y qué debería moverse primero.",
      card1: {
        title: "Route coupling",
        body:
          "Pages, bindings, middleware y `Get.arguments` dejan de estar dispersos entre archivos y pasan a verse juntos.",
      },
      card2: {
        title: "Comportamiento de red oculto",
        body:
          "Los request modifiers, authenticators y decoders de `GetConnect` aparecen antes de que empiece la migración de red.",
      },
      card3: {
        title: "Crecimiento de controllers",
        body:
          "La complexity scoring muestra dónde state, DI, lifecycle, navegación y trabajo de API terminan mezclados en un solo controller.",
      },
    },
    features: {
      kicker: "Disponible hoy",
      title: "Primero entregamos el report, para que el siguiente paso tenga respaldo.",
      body:
        "GetXDrop es deliberadamente conservador. Esta release se enfoca en analysis, planning y explainability antes de prometer rewrite automation.",
      audit: {
        tag: "Audit",
        title: "Machine-readable inventory",
        body:
          "Genera artefactos JSON estables para CI, revisión local y workflows de migration planning.",
      },
      routing: {
        tag: "Routing",
        title: "Route inventory",
        body:
          "Sigue declarations, invocations, middleware, bindings y argument access en una sola vista.",
      },
      network: {
        tag: "Network",
        title: "GetConnect surface map",
        body:
          "Extrae request modifiers, authenticators, decoders y public methods antes de migrar la capa de transporte.",
      },
      controllers: {
        tag: "Controllers",
        title: "Complexity scoring",
        body:
          "Puntúa el riesgo del controller por tamaño, dependencies, lifecycle, navegación, API calls y global lookups.",
      },
      explain: {
        tag: "Explainability",
        title: "Finding drill-down",
        body:
          "Cada finding explica por qué es riesgoso, cuál es el siguiente paso y qué fase de migración ayuda a resolver.",
      },
      trust: {
        tag: "Trust",
        title: "Fixture + CI",
        body:
          "La regresión del sample app y el CI del workspace ayudan a mantener la calidad de la release desde el inicio.",
      },
    },
    artifacts: {
      kicker: "Artefactos",
      title: "Tres salidas para una sola conversación de migración.",
      body:
        "La herramienta genera un raw inventory, un structured planning report y un report legible para el equipo.",
      inventory:
        "Resultado bruto del audit con findings y parse failures para CI y flujos automatizados.",
      reportJson:
        "Structured planning output con secciones de route, network, controller y finding drill-down.",
      reportMd:
        "Report legible para triage, handoff, visibilidad el día del release y conversación de equipo.",
      previewTitle: "Structured planning output",
    },
    quickstart: {
      kicker: "Quickstart",
      title: "Usa el sample app para recorrer el flujo completo en minutos.",
      step1: { title: "Fijar el toolchain" },
      step2: { title: "Ejecutar el CLI" },
      step3: { title: "Leer el resultado de migración" },
    },
    roadmap: {
      kicker: "Roadmap",
      title: "Primero la release pública. La automatización más inteligente llega después.",
      body:
        "La meta cercana no es prometer más fuerte, sino publicar una release open source en la que la gente pueda confiar.",
      now: {
        label: "Ahora",
        item1: "`doctor`, `audit`, `report`",
        item2: "route / network / controller planning slice",
        item3: "explainable finding drill-down",
      },
      next: {
        label: "Siguiente",
        item1: "soporte de configuración de proyecto con `getxdrop.yaml`",
        item2: "schema versioning y validation",
        item3: "CI más fino y resúmenes más claros para PR",
      },
      later: {
        label: "Más adelante",
        item1: "`scaffold` assistant",
        item2: "`apply-safe` dry-run candidate",
        item3: "workflows más ricos de explain / diff / stats",
      },
    },
    cta: {
      kicker: "Ruta de release open source",
      title: "Empieza por el report. Gana confianza antes de la automatización.",
      body:
        "GetXDrop se está moldeando como una herramienta open source de respuesta rápida para equipos que necesitan claridad de migración sin teatro.",
      primary: "Leer el changelog",
      secondary: "Abrir roadmap",
    },
  },
  "pt-BR": {
    meta: {
      title: "GetXDrop | A migração de GetX começa aqui",
      description:
        "GetXDrop é uma migration workbench open source, centrada em CLI, para apps Flutter legados com GetX.",
    },
    lang: { label: "Idioma" },
    brand: { sub: "Migration workbench open source" },
    nav: {
      why: "Por quê",
      features: "Recursos",
      artifacts: "Artefatos",
      roadmap: "Roadmap",
    },
    hero: {
      badge: "v0.1 alpha candidate",
      title: "Quando GetX deixa de ser previsível,<br />o planejamento da migração não pode esperar.",
      body:
        "GetXDrop audita apps Flutter legados com GetX e os transforma em um mapa de migração: route inventory, network inventory, controller complexity e explainable findings.",
      primaryCta: "Ler o README",
      secondaryCta: "Ver quickstart",
      stats: {
        commands: "comandos públicos",
        slices: "planning slices disponíveis",
        ci: "baseline de analyze + test",
      },
    },
    terminal: {
      kicker: "Prévia do CLI",
      note: "Saída real, sem teatro de migração",
    },
    proof: {
      kicker: "O que o v0.1 já coloca em evidência",
      title: "O planning output necessário para uma primeira release pública já está disponível.",
      item1: "Route declarations, bindings, middleware e argument access em um só lugar.",
      item2: "Os clientes de `GetConnect` são mapeados antes de começar o rewrite de transporte.",
      item3: "O risco de cada controller é pontuado por tamanho, DI, lifecycle, navegação e acoplamento com a API.",
    },
    why: {
      kicker: "Por que isso existe",
      title: "Não é um truque de rewrite. É uma válvula de alívio para a migração.",
      body:
        "Nas primeiras 48 horas, um time não precisa de confiança vazia. Precisa enxergar rapidamente o que está acoplado, o que é arriscado e o que deve mudar primeiro.",
      card1: {
        title: "Route coupling",
        body:
          "Pages, bindings, middleware e `Get.arguments` deixam de ficar espalhados e passam a aparecer juntos.",
      },
      card2: {
        title: "Comportamento de rede escondido",
        body:
          "Request modifiers, authenticators e decoders de `GetConnect` aparecem antes de a migração de rede começar.",
      },
      card3: {
        title: "Crescimento de controllers",
        body:
          "A complexity scoring mostra onde state, DI, lifecycle, navegação e trabalho de API acabam misturados em um único controller.",
      },
    },
    features: {
      kicker: "Disponível agora",
      title: "Primeiro entregamos o report, para que o próximo passo tenha base real.",
      body:
        "GetXDrop é deliberadamente conservador. Esta release foca em analysis, planning e explainability antes de prometer rewrite automation.",
      audit: {
        tag: "Audit",
        title: "Machine-readable inventory",
        body:
          "Gera artefatos JSON estáveis para CI, revisão local e workflows de migration planning.",
      },
      routing: {
        tag: "Routing",
        title: "Route inventory",
        body:
          "Acompanha declarations, invocations, middleware, bindings e argument access em uma única visão.",
      },
      network: {
        tag: "Network",
        title: "GetConnect surface map",
        body:
          "Extrai request modifiers, authenticators, decoders e public methods antes da migração da camada de transporte.",
      },
      controllers: {
        tag: "Controllers",
        title: "Complexity scoring",
        body:
          "Pontua o risco do controller por tamanho, dependencies, lifecycle, navegação, API calls e global lookups.",
      },
      explain: {
        tag: "Explainability",
        title: "Finding drill-down",
        body:
          "Cada finding explica por que é arriscado, qual é o próximo passo e que etapa da migração ele ajuda a resolver.",
      },
      trust: {
        tag: "Trust",
        title: "Fixture + CI",
        body:
          "A regressão do sample app e o CI do workspace ajudam a preservar a qualidade da release desde o início.",
      },
    },
    artifacts: {
      kicker: "Artefatos",
      title: "Três saídas para uma única conversa de migração.",
      body:
        "A ferramenta gera um raw inventory, um structured planning report e um report legível para o time.",
      inventory:
        "Resultado bruto do audit com findings e parse failures para CI e fluxos automatizados.",
      reportJson:
        "Structured planning output com seções de route, network, controller e finding drill-down.",
      reportMd:
        "Report legível para triage, handoff, visibilidade no dia do release e conversa de equipe.",
      previewTitle: "Structured planning output",
    },
    quickstart: {
      kicker: "Quickstart",
      title: "Use o sample app para percorrer o fluxo completo em poucos minutos.",
      step1: { title: "Fixar o toolchain" },
      step2: { title: "Executar o CLI" },
      step3: { title: "Ler o resultado da migração" },
    },
    roadmap: {
      kicker: "Roadmap",
      title: "Primeiro a release pública. A automação mais inteligente vem depois.",
      body:
        "A meta de curto prazo não é prometer mais alto, e sim publicar uma release open source em que as pessoas possam confiar.",
      now: {
        label: "Agora",
        item1: "`doctor`, `audit`, `report`",
        item2: "route / network / controller planning slice",
        item3: "explainable finding drill-down",
      },
      next: {
        label: "Próximo",
        item1: "suporte à configuração de projeto com `getxdrop.yaml`",
        item2: "schema versioning e validation",
        item3: "CI mais refinado e resumos melhores para PR",
      },
      later: {
        label: "Depois",
        item1: "`scaffold` assistant",
        item2: "`apply-safe` dry-run candidate",
        item3: "workflows mais ricos de explain / diff / stats",
      },
    },
    cta: {
      kicker: "Trilha de release open source",
      title: "Comece pelo report. Ganhe confiança antes da automação.",
      body:
        "GetXDrop está sendo moldado como uma ferramenta open source de resposta rápida para times que precisam de clareza de migração sem teatro.",
      primary: "Ler o changelog",
      secondary: "Abrir roadmap",
    },
  },
};

const supportedLanguages = ["en", "ko", "ja", "zh", "es", "pt-BR"];
const languageMap = {
  ko: "ko",
  ja: "ja",
  zh: "zh",
  es: "es",
  pt: "pt-BR",
  "pt-br": "pt-BR",
};

function getValue(obj, path) {
  return path.split(".").reduce((current, key) => current?.[key], obj);
}

function resolveLanguage(candidate) {
  if (!candidate) {
    return "en";
  }

  if (supportedLanguages.includes(candidate)) {
    return candidate;
  }

  const normalized = candidate.toLowerCase();
  const exactMatch = languageMap[normalized];
  if (exactMatch) {
    return exactMatch;
  }

  const prefixMatch = Object.entries(languageMap).find(([prefix]) =>
    normalized.startsWith(prefix),
  );

  return prefixMatch?.[1] ?? "en";
}

function applyLanguage(lang) {
  const resolvedLanguage = resolveLanguage(lang);
  const copy = translations[resolvedLanguage] ?? translations.en;

  document.documentElement.lang =
    resolvedLanguage === "zh" ? "zh-Hans" : resolvedLanguage;
  document.title = copy.meta.title;

  [
    'meta[name="description"]',
    'meta[property="og:description"]',
    'meta[name="twitter:description"]',
  ].forEach((selector) => {
    const element = document.querySelector(selector);
    if (element) {
      element.setAttribute("content", copy.meta.description);
    }
  });

  [
    'meta[property="og:title"]',
    'meta[name="twitter:title"]',
  ].forEach((selector) => {
    const element = document.querySelector(selector);
    if (element) {
      element.setAttribute("content", copy.meta.title);
    }
  });

  document.querySelectorAll("[data-i18n]").forEach((element) => {
    const key = element.getAttribute("data-i18n");
    const value = getValue(copy, key);
    if (typeof value === "string") {
      element.textContent = value;
    }
  });

  document.querySelectorAll("[data-i18n-html]").forEach((element) => {
    const key = element.getAttribute("data-i18n-html");
    const value = getValue(copy, key);
    if (typeof value === "string") {
      element.innerHTML = value;
    }
  });

  const langSelect = document.getElementById("lang-select");
  if (langSelect) {
    langSelect.value = resolvedLanguage;
  }

  window.localStorage.setItem("getxdrop-site-lang", resolvedLanguage);
}

const savedLanguage = window.localStorage.getItem("getxdrop-site-lang");
const browserLanguage = navigator.language || navigator.languages?.[0] || "en";
const defaultLanguage = resolveLanguage(savedLanguage || browserLanguage);

const langSelect = document.getElementById("lang-select");
if (langSelect) {
  langSelect.addEventListener("change", (event) => {
    applyLanguage(event.target.value);
  });
}

applyLanguage(defaultLanguage);
