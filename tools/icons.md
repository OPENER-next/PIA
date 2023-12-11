# Map Icons

Map icons must be converted into an icon sprite. For simplicity they are then uploaded to the map style provider ([see maptiler documentation](https://documentation.maptiler.com/hc/en-us/articles/360020805997-Custom-map-icons-sprites-)).

## Temaki icons example
```bash
# get temaki icons
git clone --depth 1 https://github.com/rapideditor/temaki.git
# batch resize icons to 20x20
for old in ./icons/*; do
  rsvg-convert "$old" -w 20 -h 20 -f svg -o "$old"
done
# convert icons to a sprite sheet
# spritezero requires an older nodejs version
spritezero ./out ./icons
spritezero ./out@2x ./icons --retina
```
