# 玻璃质感 v4 润色

## Changes

1. **coverImage/artistImage**: shadow { radius: 10, offsetX: 2, offsetY: 4 } → { radius: 8, offsetY: 4 } (remove offsetX, reduce radius)
2. **Mini bar highlight line**: #59FFFFFF → #26FFFFFF (35% → 15% white)
3. **Sidebar outer Column**: add top highlight line #26FFFFFF 1px
4. **Sidebar overlay shadow**: shadowRadius 100 → 24
5. **Dialogs**: replace 6 remaining sys.color.ohos_id_shadow_default_lg_dark with app.color.glass_shadow
   - EditPlaylist.ets (x2)
   - EditServer.ets (x2)
   - Report.ets (x2)
