
Chapters:
    ; chapter 1 - bats
    dc.b      20,0
    ; chapter 2
    dc.b      5,1
    ; chapter 3
    dc.b      5,2
    ; chapter 4
    dc.b      15,1
    ; chapter 5
    dc.b      15,2
    ; chapter 6
    dc.b      10,3
    ; chapter 7
    dc.b      10,4
    ; chapter 8
    dc.b      10,3
    ; chapter 9
    dc.b      10,4

LevelAssetSet:
    ; chapter 1 - bats
    dcb.b     20,0
    ; chapter 2
    dcb.b     5,1
    ; chapter 3
    dcb.b     5,2
    ; chapter 4
    dcb.b     15,1
    ; chapter 5
    dcb.b     15,2
    ; chapter 6
    dcb.b     10,3
    ; chapter 7
    dcb.b     10,4
    ; chapter 8
    dcb.b     10,3
    ; chapter 9
    dcb.b     10,4
    even

TileAssets:
    dc.l      Tiles0_Packed
    dc.l      Tiles1_Packed
    dc.l      Tiles2_Packed
    dc.l      Tiles3_Packed
    dc.l      Tiles4_Packed

Tiles0_Packed:
    incbin    "assets/tiles/Tiles_0.pak"
Tiles1_Packed:
    incbin    "assets/tiles/Tiles_1.pak"
Tiles2_Packed:
    incbin    "assets/tiles/Tiles_2.pak"
Tiles3_Packed:
    incbin    "assets/tiles/Tiles_3.pak"
Tiles4_Packed:
    incbin    "assets/tiles/Tiles_4.pak"

    even
