# 玻璃质感 UI 美化 v2

## Goal

为 Harmonic 音乐播放器所有封面图、头像组件、带阴影的 UI 组件及各类卡片/弹窗统一实现玻璃质感（Glassmorphism）风格，提升视觉层次感和现代感。

## Background

v1 封面对背景模糊效果不佳（纯色页面无内容可模糊）、玻璃色太白、异形封面被裁成正方形、搜索页未居中、侧边栏/弹窗/设置页未覆盖。

## Requirements

1. **`coverImage` 自模糊重构** — 封面图使用自身内容作为模糊背景（Stack.backgroundImage + backgroundBlurStyle），磨砂效果可见
2. **恢复异形封面** — 恢复 `@State aspect` + `onComplete` + 动态宽高，玻璃形状随封面比例变化
3. **`glass_bg` 透明度降低** — Light: `#1AFFFFFF` (10%), Dark: `#08FFFFFF` (3%)，让更多模糊背景透出
4. **Mini 播放栏立体感增强** — 阴影加 Y 偏移 + 顶部玻璃高光线 + blur 升级到 ULTRA_THICK
5. **搜索页专辑/艺术家卡片玻璃化 + 居中** — 卡片玻璃样式，文字居中
6. **侧边栏导航容器玻璃化** — 包裹导航按钮的两个背景 Column 替换为 glass
7. **设置页卡片玻璃化** — 4 张设置卡片替换为 glass 样式
8. **弹窗玻璃化** — 7 个对话框内容包裹 glass 背景
9. **弹窗内按钮统一玻璃样式**
10. **全屏播放器背景** — 不做改动

## Design Decisions (ADR-lite)

### 玻璃效果方案
- **Decision**: 自模糊玻璃卡片（封面图自身模糊作为背景 + 极淡玻璃色覆盖 + 清晰图片在前）
- **Rationale**: 在纯色页面背景下，靠 `backgroundBlurStyle` 模糊页面没有效果；模糊封面图自己才有可见磨砂
- **Consequences**: 每个封面图外层 Stack 使用 backgroundImage + backgroundBlurStyle + backgroundBrightness

### 玻璃色调（v2 调整）
- **Light mode**: `#1AFFFFFF` (10% 白)，让 90% 模糊背景透出
- **Dark mode**: `#08FFFFFF` (3% 白)

### Mini 播放栏立体感
- 阴影加 `offsetY: -6` 向上投射 → 播放栏浮在页面上
- 顶部 1px `#59FFFFFF` (35% 白) 玻璃高光线 → 边缘反光
- `COMPONENT_THICK` → `COMPONENT_ULTRA_THICK` → 更强模糊

## Acceptance Criteria

- [ ] `coverImage` 封面图显示在自模糊玻璃卡片上，磨砂效果清晰可见
- [ ] 异形封面（竖版/横版）的玻璃卡片跟随封面比例
- [ ] `artistImage` 头像显示在玻璃圆形容器上
- [ ] Mini 播放栏有明显立体感（阴影上投 + 顶部高光线）
- [ ] 侧边栏导航容器有玻璃效果
- [ ] 设置页 4 张卡片有玻璃效果
- [ ] 弹窗有玻璃效果
- [ ] 搜索页专辑/艺术家卡片有玻璃效果 + 居中
- [ ] 亮/暗主题均正确显示玻璃效果
- [ ] 构建通过，无 lint/type-check 错误
- [ ] 无回归（封面图、头像加载正常）

## Out of Scope

- 全屏播放器背景 blur 参数调整
- 纯 UI 文案和图标改动
- 功能逻辑改动

## Technical Approach

### 核心模式

**coverImage 自模糊模式**:
```typescript
@State aspect: number = 1

Stack()
  .backgroundImage(this.url)
  .backgroundImageSize(ImageSize.COVER)
  .backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
  .backgroundBrightness({ rate: 0.35 })
  .width(this.aspect >= 1 ? '100%' : 'auto')
  .height(this.aspect < 1 ? '100%' : 'auto')
  .layoutWeight(1)
  .aspectRatio(this.aspect)
{
  Column()
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.glass_bg'))
    .borderRadius(this.radius)

  Image(this.url)
    .objectFit(ImageFit.Contain)
    .width('100%')
    .height('100%')
    .onComplete((e) => {
      if (e?.width && e?.height) { this.aspect = e.width / e.height }
    })
    .borderRadius(this.radius)
}
.borderRadius(this.radius)
.border({ ... })
.shadow({ ... })
```

**Mini 播放栏立体模式**:
```typescript
.shadow({
  radius: 12,
  offsetY: -6,
  color: $r('app.color.glass_shadow')
})
.backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)

// 内容区最顶端：
Column()
  .width('100%')
  .height(1)
  .backgroundColor('#59FFFFFF')  // 35% 白高光线
```

**通用玻璃卡片**（弹窗/设置页/侧边栏容器/搜索卡片）:
```typescript
.backgroundBlurStyle(BlurStyle.COMPONENT_ULTRA_THICK)
.backgroundColor($r('app.color.glass_bg'))
.border({ color: $r('app.color.glass_border'), width: 1, radius: borderRadius })
.shadow({ radius: 6, color: $r('app.color.glass_shadow') })
```

## Affected Files

| File | Change |
|------|--------|
| `entry/src/main/resources/base/element/color.json` | glass_bg: #4DFFFFFF → #1AFFFFFF |
| `entry/src/main/resources/dark/element/color.json` | glass_bg: #14FFFFFF → #08FFFFFF |
| `entry/src/main/ets/utils/Component.ets` | coverImage 自模糊 + aspect 恢复; artistImage 微调 |
| `entry/src/main/ets/pages/Index.ets` | mini 播放栏阴影偏移+高光线+blur升级; 侧边栏容器玻璃化 |
| `entry/src/main/ets/pages/Search.ets` | 专辑/艺术家卡片玻璃化 + 文字居中 |
| `entry/src/main/ets/pages/Setting.ets` | 4 设置卡片 + 按钮玻璃化 |
| `entry/src/main/ets/pages/dialogs/Info.ets` | 对话框玻璃化 |
| `entry/src/main/ets/pages/dialogs/Report.ets` | 同上 |
| `entry/src/main/ets/pages/dialogs/SelectPlaylist.ets` | 同上 |
| `entry/src/main/ets/pages/dialogs/CreatePlaylist.ets` | 同上 |
| `entry/src/main/ets/pages/dialogs/EditPlaylist.ets` | 同上 |
| `entry/src/main/ets/pages/dialogs/AddServer.ets` | 同上 |
| `entry/src/main/ets/pages/dialogs/EditServer.ets` | 同上 |
| `entry/src/main/ets/pages/Play.ets` | 已有改动，检查一致性 |
| `entry/src/main/ets/pages/Playlists.ets` | 已有改动，检查一致性 |
| `entry/src/main/ets/pages/Songs.ets` | 已有改动，检查一致性 |
| `entry/src/main/ets/pages/Albums.ets` | 已有改动，检查一致性 |
| `entry/src/main/ets/pages/Artists.ets` | 已有改动，检查一致性 |
