# 按钮玻璃色增强 + 三级玻璃色值

## Changes

### Color resources
- Add `glass_bg_btn`: Light `#59FFFFFF` (35%), Dark `#26FFFFFF` (15%)
- Update `glass_bg_active`: Light `#8AFFFFFF`(54%)→`#A6FFFFFF`(65%), Dark `#5CFFFFFF`(36%)→`#66FFFFFF`(40%)

### Replace `glass_bg` with `glass_bg_btn` on all interactive elements
All buttons/FABs/cards/dialog containers that use `$r('app.color.glass_bg')` → `$r('app.color.glass_bg_btn')`
Keep `glass_bg` only on: sidebar panel, mini bar panels, context menu, coverImage/artistImage

### Affected files (15+)
color.json (base + dark), Albums.ets, Artists.ets, Songs.ets, Search.ets (5x), Play.ets (2x), Playlists.ets, Setting.ets (5x), AddServer.ets (2x), CreatePlaylist.ets (2x), EditPlaylist.ets (2x), EditServer.ets (2x), Info.ets, Report.ets (2x), SelectPlaylist.ets (2x)
