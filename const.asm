
BASE_DMA                    = DMAF_SETCLR|DMAF_MASTER|DMAF_COPPER|DMAF_BLITTER|DMAF_RASTER!DMAF_SPRITE

MAX_ACTORS                  = MAP_SIZE

WINDOW_X_START              = $81-16
WINDOW_X_STOP               = $c1
WINDOW_Y_START              = $2c
WINDOW_Y_STOP               = $2c-40

PLAYER_SPRITE_LEFT_OFFSET   = 32
PLAYER_SPRITE_LADDER_OFFSET = 16
PLAYER_SPRITE_WALK_OFFSET   = 4

WINDOW_START                = (WINDOW_Y_START<<8)|WINDOW_X_START
WINDOW_STOP                 = (WINDOW_Y_STOP<<8)|WINDOW_X_STOP
FETCH_START                 = $38-8
FETCH_STOP                  = $d0

SCREEN_WIDTH                = TILE_WIDTH*WALL_PAPER_WIDTH
SCREEN_WIDTH_BYTE           = SCREEN_WIDTH/8
SCREEN_HEIGHT               = TILE_HEIGHT*WALL_PAPER_HEIGHT
SCREEN_DEPTH                = 5
SCREEN_MOD                  = SCREEN_WIDTH_BYTE*(SCREEN_DEPTH-1)
SCREEN_SIZE                 = SCREEN_WIDTH_BYTE*SCREEN_HEIGHT*SCREEN_DEPTH
SCREEN_STRIDE               = SCREEN_DEPTH*SCREEN_WIDTH_BYTE
SCREEN_COLORS               = 32

WALL_PAPER_WIDTH            = 14
WALL_PAPER_HEIGHT           = 9
WALL_PAPER_SIZE             = WALL_PAPER_WIDTH*WALL_PAPER_HEIGHT
GAME_MAP_SIZE               = WALL_PAPER_WIDTH*(WALL_PAPER_HEIGHT+1)

MAP_WIDTH                   = 11
MAP_HEIGHT                  = 8
MAP_SIZE                    = MAP_WIDTH*MAP_HEIGHT

BLOCK_EMPTY                 = 0
BLOCK_LADDER                = 1
BLOCK_ENEMYFALL             = 2
BLOCK_PUSH                  = 3
BLOCK_DIRT                  = 4
BLOCK_SOLID                 = 5
BLOCK_ENEMYFLOAT            = 6
BLOCK_MILLIESTART           = 7
BLOCK_MOLLYSTART            = 8
BLOCK_MILLIELADDER          = 9
BLOCK_MOLLYLADDER           = 10

TILE_WIDTH                  = 24
TILE_HEIGHT                 = 24

TILE_WIDTHF                 = 32
TILE_SIZE                   = (TILE_WIDTHF/8)*SCREEN_DEPTH*TILE_HEIGHT
SHADOW_SIZE                 = (TILE_WIDTHF/8)*TILE_HEIGHT

TILE_SCREEN_WIDTH           = SCREEN_WIDTH/TILE_WIDTH
TILE_SCREEN_HEIGHT          = SCREEN_HEIGHT/TILE_HEIGHT

SPRITE_SIZE                 = 4+(TILE_HEIGHT*4)+4

START_LEVEL                 = 0

TILE_WALLSINGLE             = 0
TILE_WALLLEFT               = 1
TILE_WALLA                  = 2
TILE_WALLB                  = 3
TILE_WALLC                  = 4
TILE_WALLD                  = 5
TILE_WALLE                  = 6
TILE_WALLF                  = 7
TILE_WALLRIGHT              = 8
TILE_PUSH                   = 9
TILE_LADDERA                = 10
TILE_LADDERB                = 11
TILE_LADDERC                = 12
TILE_LADDERD                = 13
TILE_LADDERE                = 14
TILE_LADDERF                = 15
TILE_DIRTA                  = 16
TILE_DIRTB                  = 17
TILE_DIRTC                  = 18
TILE_DIRTD                  = 19
TILE_ENEMYFALLA             = 20
TILE_ENEMYFALLB             = 21
TILE_ENEMYFALLC             = 22
TILE_ENEMYFALLD             = 23
TILE_ENEMYFLOATA            = 24
TILE_ENEMYFLOATB            = 25
TILE_ENEMYFLOATC            = 26
TILE_ENEMYFLOATD            = 27
TILE_BACK                   = 28

SPRITESET_COUNT             = 12*12
SPRITESET_SIZE              = TILE_SIZE*SPRITESET_COUNT
TILESET_SIZE                = TILE_SIZE*TILESET_COUNT
TILESET_COUNT               = (8*3)+5

KEY_F1                      = $50
KEY_F2                      = $51
KEY_F3                      = $52
KEY_F4                      = $53
KEY_F5                      = $54
KEY_F6                      = $55
KEY_F7                      = $56
KEY_F8                      = $57
KEY_F9                      = $58
KEY_F10                     = $59

;    bit 4 = Fire / Space
;    bit 3 = Right
;    bit 2 = Left
;    bit 1 = Down
;    bit 0 = Up

CONTROLB_UP                 = 0
CONTROLB_DOWN               = 1
CONTROLB_LEFT               = 2
CONTROLB_RIGHT              = 3
CONTROLB_FIRE               = 4

CONTROLF_UP                 = 1<<0
CONTROLF_DOWN               = 1<<1
CONTROLF_LEFT               = 1<<2
CONTROLF_RIGHT              = 1<<3
CONTROLF_FIRE               = 1<<4


ACTION_IDLE                 = 0
ACTION_MOVE                 = 1