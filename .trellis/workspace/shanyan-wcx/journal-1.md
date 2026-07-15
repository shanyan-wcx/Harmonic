# Journal - shanyan-wcx (Part 1)

> AI development session journal
> Started: 2026-06-06

---



## Session 1: 玻璃质感 UI 美化

**Date**: 2026-06-07
**Task**: 玻璃质感 UI 美化
**Branch**: `main`

### Summary

实现了全局玻璃质感 UI 美化：coverImage/artistImage 自模糊 + 方向阴影 + 异形封面；mini 播放栏立体感（偏移阴影 + 顶部高光线）；整个侧边栏面板玻璃化；设置页 4 卡片玻璃化；7 个弹窗玻璃化；搜索页专辑/艺术家卡片玻璃化+居中。共修改 21 个文件，三次迭代（v1→v2→v3），ArkTS 检查零错误。

### Main Changes

(Add details)

### Git Commits

| Hash | Message |
|------|---------|
| `0f070c1` | (see git log) |
| `372bf9c` | (see git log) |

### Testing

- [OK] (Add test results)

### Status

[OK] **Completed**

### Next Steps

- None - task complete


## Session 2: 玻璃质感 v4 润色

**Date**: 2026-06-07
**Task**: 玻璃质感 v4 润色
**Branch**: `main`

### Summary

Mini bar 高亮线 35%→15% 白；封面/头像阴影去掉 offsetX、radius 10→8；侧边栏高亮线从顶部移到右侧；侧边栏选中项用更明显的 glass_bg_active (Light 30%/Dark 10%)；3 个弹窗旧阴影色值替换为 glass_shadow；侧边栏 overlay 阴影 100px→24px。ArkTS 检查零错误。

### Main Changes

(Add details)

### Git Commits

| Hash | Message |
|------|---------|
| `0dfcd0d` | (see git log) |
| `3abd684` | (see git log) |

### Testing

- [OK] (Add test results)

### Status

[OK] **Completed**

### Next Steps

- None - task complete


## Session 3: UI 玻璃质感最终润色

**Date**: 2026-06-07
**Task**: UI 玻璃质感最终润色
**Branch**: `main`

### Summary

Light/Dark 按钮卡片对比度修复（引入蓝灰色相差异）；弹窗TextInput/Select背景色统一为默认系统色+textInput色值更新；EditServer Select menuBackgroundColor修复。

### Main Changes

(Add details)

### Git Commits

| Hash | Message |
|------|---------|
| `1132fab` | (see git log) |
| `25bfbfe` | (see git log) |
| `51aede8` | (see git log) |

### Testing

- [OK] (Add test results)

### Status

[OK] **Completed**

### Next Steps

- None - task complete


## Session 4: UI 重设计：HdsNavigation + 沉浸光感（已回滚）

**Date**: 2026-06-21
**Task**: UI 重设计：HdsNavigation + 沉浸光感（已回滚）
**Branch**: `main`

### Summary

完整 UI 重设计集成后因布局多设备适配问题和配色需调整全部回滚。涉及：HdsNavigation + GRADIENT_BLUR 标题栏、SymbolGlyph 胶囊侧边栏、浮动 MiniPlayer、geometryTransition 封面过渡、系统语义颜色、毛玻璃弹窗。

### Main Changes

(Add details)

### Git Commits

| Hash | Message |
|------|---------|
| `9b2209c` | (see git log) |

### Testing

- [OK] (Add test results)

### Status

[OK] **Completed**

### Next Steps

- None - task complete


## Session 5: 修复 API 23 播放进度同步 bug

**Date**: 2026-07-15
**Task**: 修复 API 23 播放进度同步 bug
**Branch**: `main`

### Summary

修复 API 23 升级后的播放进度问题：1) AVSession 进度条与应用不一致 → timeUpdate 中加 setPlaybackState(syncOnly=true)。2) 切歌进度闪现下一首歌末尾 → 删除 isTransitioning、精简状态机仿 Harmshelf。3) 启动恢复播放 IO Error → 全长流 url = ... 代替 setMediaSource + timeOffset，seek 移到 'playing' 中延迟执行。4) 恢复播放进度归零 → pendingRestore 标记 + 'prepared' 条件复位。5) sourceOffsetTime 合并到 startPlayTime，跨 6 个文件的 Provide/Consume 链更新。

### Main Changes

(Add details)

### Git Commits

| Hash | Message |
|------|---------|
| `523ec01` | (see git log) |
| `b838782` | (see git log) |

### Testing

- [OK] (Add test results)

### Status

[OK] **Completed**

### Next Steps

- None - task complete


## Session 6: 修复 seek 期间 timeUpdate 位置跳跃 + 收尾

**Date**: 2026-07-15
**Task**: 修复 seek 期间 timeUpdate 位置跳跃 + 收尾
**Branch**: `main`

### Summary

修复恢复播放暂停后点播放时进度条闪到结尾的 bug：timeUpdate 中 seekTarget 期间不加 time/1000，因为 time 初始值可能很大。所有 bug 修复完毕。

### Main Changes

(Add details)

### Git Commits

| Hash | Message |
|------|---------|
| `523ec01` | (see git log) |
| `b838782` | (see git log) |
| `13b30ea` | (see git log) |

### Testing

- [OK] (Add test results)

### Status

[OK] **Completed**

### Next Steps

- None - task complete
