package thor_sdl2

import "core:c"

Scancode :: enum c.int {
	UNKNOWN            = 0,
	A                  = 4,
	B                  = 5,
	C                  = 6,
	D                  = 7,
	E                  = 8,
	F                  = 9,
	G                  = 10,
	H                  = 11,
	I                  = 12,
	J                  = 13,
	K                  = 14,
	L                  = 15,
	M                  = 16,
	N                  = 17,
	O                  = 18,
	P                  = 19,
	Q                  = 20,
	R                  = 21,
	S                  = 22,
	T                  = 23,
	U                  = 24,
	V                  = 25,
	W                  = 26,
	X                  = 27,
	Y                  = 28,
	Z                  = 29,
	NUM1               = 30,
	NUM2               = 31,
	NUM3               = 32,
	NUM4               = 33,
	NUM5               = 34,
	NUM6               = 35,
	NUM7               = 36,
	NUM8               = 37,
	NUM9               = 38,
	NUM0               = 39,
	RETURN             = 40,
	ESCAPE             = 41,
	BACKSPACE          = 42,
	TAB                = 43,
	SPACE              = 44,
	MINUS              = 45,
	EQUALS             = 46,
	LEFTBRACKET        = 47,
	RIGHTBRACKET       = 48,
	BACKSLASH          = 49,
	NONUSHASH          = 50,
	SEMICOLON          = 51,
	APOSTROPHE         = 52,
	GRAVE              = 53,
	COMMA              = 54,
	PERIOD             = 55,
	SLASH              = 56,
	CAPSLOCK           = 57,
	F1                 = 58,
	F2                 = 59,
	F3                 = 60,
	F4                 = 61,
	F5                 = 62,
	F6                 = 63,
	F7                 = 64,
	F8                 = 65,
	F9                 = 66,
	F10                = 67,
	F11                = 68,
	F12                = 69,
	PRINTSCREEN        = 70,
	SCROLLLOCK         = 71,
	PAUSE              = 72,
	INSERT             = 73,
	HOME               = 74,
	PAGEUP             = 75,
	DELETE             = 76,
	END                = 77,
	PAGEDOWN           = 78,
	RIGHT              = 79,
	LEFT               = 80,
	DOWN               = 81,
	UP                 = 82,
	NUMLOCKCLEAR       = 83,
	KP_DIVIDE          = 84,
	KP_MULTIPLY        = 85,
	KP_MINUS           = 86,
	KP_PLUS            = 87,
	KP_ENTER           = 88,
	KP_1               = 89,
	KP_2               = 90,
	KP_3               = 91,
	KP_4               = 92,
	KP_5               = 93,
	KP_6               = 94,
	KP_7               = 95,
	KP_8               = 96,
	KP_9               = 97,
	KP_0               = 98,
	KP_PERIOD          = 99,
	NONUSBACKSLASH     = 100,
	APPLICATION        = 101,
	POWER              = 102,
	KP_EQUALS          = 103,
	F13                = 104,
	F14                = 105,
	F15                = 106,
	F16                = 107,
	F17                = 108,
	F18                = 109,
	F19                = 110,
	F20                = 111,
	F21                = 112,
	F22                = 113,
	F23                = 114,
	F24                = 115,
	EXECUTE            = 116,
	HELP               = 117,
	MENU               = 118,
	SELECT             = 119,
	STOP               = 120,
	AGAIN              = 121,
	UNDO               = 122,
	CUT                = 123,
	COPY               = 124,
	PASTE              = 125,
	FIND               = 126,
	MUTE               = 127,
	VOLUMEUP           = 128,
	VOLUMEDOWN         = 129,
	/* not sure whether there's a reason to enable these */
	/*     LOCKINGCAPSLOCK = 130,  */
	/*     LOCKINGNUMLOCK = 131, */
	/*     LOCKINGSCROLLLOCK = 132, */
	KP_COMMA           = 133,
	KP_EQUALSAS400     = 134,
	INTERNATIONAL1     = 135,
	INTERNATIONAL2     = 136,
	INTERNATIONAL3     = 137,
	INTERNATIONAL4     = 138,
	INTERNATIONAL5     = 139,
	INTERNATIONAL6     = 140,
	INTERNATIONAL7     = 141,
	INTERNATIONAL8     = 142,
	INTERNATIONAL9     = 143,
	LANG1              = 144,
	LANG2              = 145,
	LANG3              = 146,
	LANG4              = 147,
	LANG5              = 148,
	LANG6              = 149,
	LANG7              = 150,
	LANG8              = 151,
	LANG9              = 152,
	ALTERASE           = 153,
	SYSREQ             = 154,
	CANCEL             = 155,
	CLEAR              = 156,
	PRIOR              = 157,
	RETURN2            = 158,
	SEPARATOR          = 159,
	OUT                = 160,
	OPER               = 161,
	CLEARAGAIN         = 162,
	CRSEL              = 163,
	EXSEL              = 164,
	KP_00              = 176,
	KP_000             = 177,
	THOUSANDSSEPARATOR = 178,
	DECIMALSEPARATOR   = 179,
	CURRENCYUNIT       = 180,
	CURRENCYSUBUNIT    = 181,
	KP_LEFTPAREN       = 182,
	KP_RIGHTPAREN      = 183,
	KP_LEFTBRACE       = 184,
	KP_RIGHTBRACE      = 185,
	KP_TAB             = 186,
	KP_BACKSPACE       = 187,
	KP_A               = 188,
	KP_B               = 189,
	KP_C               = 190,
	KP_D               = 191,
	KP_E               = 192,
	KP_F               = 193,
	KP_XOR             = 194,
	KP_POWER           = 195,
	KP_PERCENT         = 196,
	KP_LESS            = 197,
	KP_GREATER         = 198,
	KP_AMPERSAND       = 199,
	KP_DBLAMPERSAND    = 200,
	KP_VERTICALBAR     = 201,
	KP_DBLVERTICALBAR  = 202,
	KP_COLON           = 203,
	KP_HASH            = 204,
	KP_SPACE           = 205,
	KP_AT              = 206,
	KP_EXCLAM          = 207,
	KP_MEMSTORE        = 208,
	KP_MEMRECALL       = 209,
	KP_MEMCLEAR        = 210,
	KP_MEMADD          = 211,
	KP_MEMSUBTRACT     = 212,
	KP_MEMMULTIPLY     = 213,
	KP_MEMDIVIDE       = 214,
	KP_PLUSMINUS       = 215,
	KP_CLEAR           = 216,
	KP_CLEARENTRY      = 217,
	KP_BINARY          = 218,
	KP_OCTAL           = 219,
	KP_DECIMAL         = 220,
	KP_HEXADECIMAL     = 221,
	LCTRL              = 224,
	LSHIFT             = 225,
	LALT               = 226,
	LGUI               = 227,
	RCTRL              = 228,
	RSHIFT             = 229,
	RALT               = 230,
	RGUI               = 231,
	MODE               = 257,
	AUDIONEXT          = 258,
	AUDIOPREV          = 259,
	AUDIOSTOP          = 260,
	AUDIOPLAY          = 261,
	AUDIOMUTE          = 262,
	MEDIASELECT        = 263,
	WWW                = 264,
	MAIL               = 265,
	CALCULATOR         = 266,
	COMPUTER           = 267,
	AC_SEARCH          = 268,
	AC_HOME            = 269,
	AC_BACK            = 270,
	AC_FORWARD         = 271,
	AC_STOP            = 272,
	AC_REFRESH         = 273,
	AC_BOOKMARKS       = 274,
	BRIGHTNESSDOWN     = 275,
	BRIGHTNESSUP       = 276,
	DISPLAYSWITCH      = 277,
	KBDILLUMTOGGLE     = 278,
	KBDILLUMDOWN       = 279,
	KBDILLUMUP         = 280,
	EJECT              = 281,
	SLEEP              = 282,
	APP1               = 283,
	APP2               = 284,
	AUDIOREWIND        = 285,
	AUDIOFASTFORWARD   = 286,
	NUM_SCANCODES      = 512,
}

NUM_SCANCODES :: 512


SCANCODE_UNKNOWN :: Scancode.UNKNOWN

SCANCODE_A :: Scancode.A
SCANCODE_B :: Scancode.B
SCANCODE_C :: Scancode.C
SCANCODE_D :: Scancode.D
SCANCODE_E :: Scancode.E
SCANCODE_F :: Scancode.F
SCANCODE_G :: Scancode.G
SCANCODE_H :: Scancode.H
SCANCODE_I :: Scancode.I
SCANCODE_J :: Scancode.J
SCANCODE_K :: Scancode.K
SCANCODE_L :: Scancode.L
SCANCODE_M :: Scancode.M
SCANCODE_N :: Scancode.N
SCANCODE_O :: Scancode.O
SCANCODE_P :: Scancode.P
SCANCODE_Q :: Scancode.Q
SCANCODE_R :: Scancode.R
SCANCODE_S :: Scancode.S
SCANCODE_T :: Scancode.T
SCANCODE_U :: Scancode.U
SCANCODE_V :: Scancode.V
SCANCODE_W :: Scancode.W
SCANCODE_X :: Scancode.X
SCANCODE_Y :: Scancode.Y
SCANCODE_Z :: Scancode.Z

SCANCODE_1 :: Scancode.NUM1
SCANCODE_2 :: Scancode.NUM2
SCANCODE_3 :: Scancode.NUM3
SCANCODE_4 :: Scancode.NUM4
SCANCODE_5 :: Scancode.NUM5
SCANCODE_6 :: Scancode.NUM6
SCANCODE_7 :: Scancode.NUM7
SCANCODE_8 :: Scancode.NUM8
SCANCODE_9 :: Scancode.NUM9
SCANCODE_0 :: Scancode.NUM0

SCANCODE_RETURN :: Scancode.RETURN
SCANCODE_ESCAPE :: Scancode.ESCAPE
SCANCODE_BACKSPACE :: Scancode.BACKSPACE
SCANCODE_TAB :: Scancode.TAB
SCANCODE_SPACE :: Scancode.SPACE

SCANCODE_MINUS :: Scancode.MINUS
SCANCODE_EQUALS :: Scancode.EQUALS
SCANCODE_LEFTBRACKET :: Scancode.LEFTBRACKET
SCANCODE_RIGHTBRACKET :: Scancode.RIGHTBRACKET
SCANCODE_BACKSLASH :: Scancode.BACKSLASH
SCANCODE_NONUSHASH :: Scancode.NONUSHASH
SCANCODE_SEMICOLON :: Scancode.SEMICOLON
SCANCODE_APOSTROPHE :: Scancode.APOSTROPHE
SCANCODE_GRAVE :: Scancode.GRAVE
SCANCODE_COMMA :: Scancode.COMMA
SCANCODE_PERIOD :: Scancode.PERIOD
SCANCODE_SLASH :: Scancode.SLASH

SCANCODE_CAPSLOCK :: Scancode.CAPSLOCK

SCANCODE_F1 :: Scancode.F1
SCANCODE_F2 :: Scancode.F2
SCANCODE_F3 :: Scancode.F3
SCANCODE_F4 :: Scancode.F4
SCANCODE_F5 :: Scancode.F5
SCANCODE_F6 :: Scancode.F6
SCANCODE_F7 :: Scancode.F7
SCANCODE_F8 :: Scancode.F8
SCANCODE_F9 :: Scancode.F9
SCANCODE_F10 :: Scancode.F10
SCANCODE_F11 :: Scancode.F11
SCANCODE_F12 :: Scancode.F12

SCANCODE_PRINTSCREEN :: Scancode.PRINTSCREEN
SCANCODE_SCROLLLOCK :: Scancode.SCROLLLOCK
SCANCODE_PAUSE :: Scancode.PAUSE
SCANCODE_INSERT :: Scancode.INSERT
SCANCODE_HOME :: Scancode.HOME
SCANCODE_PAGEUP :: Scancode.PAGEUP
SCANCODE_DELETE :: Scancode.DELETE
SCANCODE_END :: Scancode.END
SCANCODE_PAGEDOWN :: Scancode.PAGEDOWN
SCANCODE_RIGHT :: Scancode.RIGHT
SCANCODE_LEFT :: Scancode.LEFT
SCANCODE_DOWN :: Scancode.DOWN
SCANCODE_UP :: Scancode.UP

SCANCODE_NUMLOCKCLEAR :: Scancode.NUMLOCKCLEAR
SCANCODE_KP_DIVIDE :: Scancode.KP_DIVIDE
SCANCODE_KP_MULTIPLY :: Scancode.KP_MULTIPLY
SCANCODE_KP_MINUS :: Scancode.KP_MINUS
SCANCODE_KP_PLUS :: Scancode.KP_PLUS
SCANCODE_KP_ENTER :: Scancode.KP_ENTER
SCANCODE_KP_1 :: Scancode.KP_1
SCANCODE_KP_2 :: Scancode.KP_2
SCANCODE_KP_3 :: Scancode.KP_3
SCANCODE_KP_4 :: Scancode.KP_4
SCANCODE_KP_5 :: Scancode.KP_5
SCANCODE_KP_6 :: Scancode.KP_6
SCANCODE_KP_7 :: Scancode.KP_7
SCANCODE_KP_8 :: Scancode.KP_8
SCANCODE_KP_9 :: Scancode.KP_9
SCANCODE_KP_0 :: Scancode.KP_0
SCANCODE_KP_PERIOD :: Scancode.KP_PERIOD

SCANCODE_NONUSBACKSLASH :: Scancode.NONUSBACKSLASH
SCANCODE_APPLICATION :: Scancode.APPLICATION
SCANCODE_POWER :: Scancode.POWER
SCANCODE_KP_EQUALS :: Scancode.KP_EQUALS
SCANCODE_F13 :: Scancode.F13
SCANCODE_F14 :: Scancode.F14
SCANCODE_F15 :: Scancode.F15
SCANCODE_F16 :: Scancode.F16
SCANCODE_F17 :: Scancode.F17
SCANCODE_F18 :: Scancode.F18
SCANCODE_F19 :: Scancode.F19
SCANCODE_F20 :: Scancode.F20
SCANCODE_F21 :: Scancode.F21
SCANCODE_F22 :: Scancode.F22
SCANCODE_F23 :: Scancode.F23
SCANCODE_F24 :: Scancode.F24
SCANCODE_EXECUTE :: Scancode.EXECUTE
SCANCODE_HELP :: Scancode.HELP
SCANCODE_MENU :: Scancode.MENU
SCANCODE_SELECT :: Scancode.SELECT
SCANCODE_STOP :: Scancode.STOP
SCANCODE_AGAIN :: Scancode.AGAIN
SCANCODE_UNDO :: Scancode.UNDO
SCANCODE_CUT :: Scancode.CUT
SCANCODE_COPY :: Scancode.COPY
SCANCODE_PASTE :: Scancode.PASTE
SCANCODE_FIND :: Scancode.FIND
SCANCODE_MUTE :: Scancode.MUTE
SCANCODE_VOLUMEUP :: Scancode.VOLUMEUP
SCANCODE_VOLUMEDOWN :: Scancode.VOLUMEDOWN
SCANCODE_KP_COMMA :: Scancode.KP_COMMA
SCANCODE_KP_EQUALSAS400 :: Scancode.KP_EQUALSAS400

SCANCODE_INTERNATIONAL1 :: Scancode.INTERNATIONAL1
SCANCODE_INTERNATIONAL2 :: Scancode.INTERNATIONAL2
SCANCODE_INTERNATIONAL3 :: Scancode.INTERNATIONAL3
SCANCODE_INTERNATIONAL4 :: Scancode.INTERNATIONAL4
SCANCODE_INTERNATIONAL5 :: Scancode.INTERNATIONAL5
SCANCODE_INTERNATIONAL6 :: Scancode.INTERNATIONAL6
SCANCODE_INTERNATIONAL7 :: Scancode.INTERNATIONAL7
SCANCODE_INTERNATIONAL8 :: Scancode.INTERNATIONAL8
SCANCODE_INTERNATIONAL9 :: Scancode.INTERNATIONAL9
SCANCODE_LANG1 :: Scancode.LANG1
SCANCODE_LANG2 :: Scancode.LANG2
SCANCODE_LANG3 :: Scancode.LANG3
SCANCODE_LANG4 :: Scancode.LANG4
SCANCODE_LANG5 :: Scancode.LANG5
SCANCODE_LANG6 :: Scancode.LANG6
SCANCODE_LANG7 :: Scancode.LANG7
SCANCODE_LANG8 :: Scancode.LANG8
SCANCODE_LANG9 :: Scancode.LANG9

SCANCODE_ALTERASE :: Scancode.ALTERASE
SCANCODE_SYSREQ :: Scancode.SYSREQ
SCANCODE_CANCEL :: Scancode.CANCEL
SCANCODE_CLEAR :: Scancode.CLEAR
SCANCODE_PRIOR :: Scancode.PRIOR
SCANCODE_RETURN2 :: Scancode.RETURN2
SCANCODE_SEPARATOR :: Scancode.SEPARATOR
SCANCODE_OUT :: Scancode.OUT
SCANCODE_OPER :: Scancode.OPER
SCANCODE_CLEARAGAIN :: Scancode.CLEARAGAIN
SCANCODE_CRSEL :: Scancode.CRSEL
SCANCODE_EXSEL :: Scancode.EXSEL

SCANCODE_KP_00 :: Scancode.KP_00
SCANCODE_KP_000 :: Scancode.KP_000
SCANCODE_THOUSANDSSEPARATOR :: Scancode.THOUSANDSSEPARATOR
SCANCODE_DECIMALSEPARATOR :: Scancode.DECIMALSEPARATOR
SCANCODE_CURRENCYUNIT :: Scancode.CURRENCYUNIT
SCANCODE_CURRENCYSUBUNIT :: Scancode.CURRENCYSUBUNIT
SCANCODE_KP_LEFTPAREN :: Scancode.KP_LEFTPAREN
SCANCODE_KP_RIGHTPAREN :: Scancode.KP_RIGHTPAREN
SCANCODE_KP_LEFTBRACE :: Scancode.KP_LEFTBRACE
SCANCODE_KP_RIGHTBRACE :: Scancode.KP_RIGHTBRACE
SCANCODE_KP_TAB :: Scancode.KP_TAB
SCANCODE_KP_BACKSPACE :: Scancode.KP_BACKSPACE
SCANCODE_KP_A :: Scancode.KP_A
SCANCODE_KP_B :: Scancode.KP_B
SCANCODE_KP_C :: Scancode.KP_C
SCANCODE_KP_D :: Scancode.KP_D
SCANCODE_KP_E :: Scancode.KP_E
SCANCODE_KP_F :: Scancode.KP_F
SCANCODE_KP_XOR :: Scancode.KP_XOR
SCANCODE_KP_POWER :: Scancode.KP_POWER
SCANCODE_KP_PERCENT :: Scancode.KP_PERCENT
SCANCODE_KP_LESS :: Scancode.KP_LESS
SCANCODE_KP_GREATER :: Scancode.KP_GREATER
SCANCODE_KP_AMPERSAND :: Scancode.KP_AMPERSAND
SCANCODE_KP_DBLAMPERSAND :: Scancode.KP_DBLAMPERSAND
SCANCODE_KP_VERTICALBAR :: Scancode.KP_VERTICALBAR
SCANCODE_KP_DBLVERTICALBAR :: Scancode.KP_DBLVERTICALBAR
SCANCODE_KP_COLON :: Scancode.KP_COLON
SCANCODE_KP_HASH :: Scancode.KP_HASH
SCANCODE_KP_SPACE :: Scancode.KP_SPACE
SCANCODE_KP_AT :: Scancode.KP_AT
SCANCODE_KP_EXCLAM :: Scancode.KP_EXCLAM
SCANCODE_KP_MEMSTORE :: Scancode.KP_MEMSTORE
SCANCODE_KP_MEMRECALL :: Scancode.KP_MEMRECALL
SCANCODE_KP_MEMCLEAR :: Scancode.KP_MEMCLEAR
SCANCODE_KP_MEMADD :: Scancode.KP_MEMADD
SCANCODE_KP_MEMSUBTRACT :: Scancode.KP_MEMSUBTRACT
SCANCODE_KP_MEMMULTIPLY :: Scancode.KP_MEMMULTIPLY
SCANCODE_KP_MEMDIVIDE :: Scancode.KP_MEMDIVIDE
SCANCODE_KP_PLUSMINUS :: Scancode.KP_PLUSMINUS
SCANCODE_KP_CLEAR :: Scancode.KP_CLEAR
SCANCODE_KP_CLEARENTRY :: Scancode.KP_CLEARENTRY
SCANCODE_KP_BINARY :: Scancode.KP_BINARY
SCANCODE_KP_OCTAL :: Scancode.KP_OCTAL
SCANCODE_KP_DECIMAL :: Scancode.KP_DECIMAL
SCANCODE_KP_HEXADECIMAL :: Scancode.KP_HEXADECIMAL

SCANCODE_LCTRL :: Scancode.LCTRL
SCANCODE_LSHIFT :: Scancode.LSHIFT
SCANCODE_LALT :: Scancode.LALT
SCANCODE_LGUI :: Scancode.LGUI
SCANCODE_RCTRL :: Scancode.RCTRL
SCANCODE_RSHIFT :: Scancode.RSHIFT
SCANCODE_RALT :: Scancode.RALT
SCANCODE_RGUI :: Scancode.RGUI

SCANCODE_MODE :: Scancode.MODE

SCANCODE_AUDIONEXT :: Scancode.AUDIONEXT
SCANCODE_AUDIOPREV :: Scancode.AUDIOPREV
SCANCODE_AUDIOSTOP :: Scancode.AUDIOSTOP
SCANCODE_AUDIOPLAY :: Scancode.AUDIOPLAY
SCANCODE_AUDIOMUTE :: Scancode.AUDIOMUTE
SCANCODE_MEDIASELECT :: Scancode.MEDIASELECT
SCANCODE_WWW :: Scancode.WWW
SCANCODE_MAIL :: Scancode.MAIL
SCANCODE_CALCULATOR :: Scancode.CALCULATOR
SCANCODE_COMPUTER :: Scancode.COMPUTER
SCANCODE_AC_SEARCH :: Scancode.AC_SEARCH
SCANCODE_AC_HOME :: Scancode.AC_HOME
SCANCODE_AC_BACK :: Scancode.AC_BACK
SCANCODE_AC_FORWARD :: Scancode.AC_FORWARD
SCANCODE_AC_STOP :: Scancode.AC_STOP
SCANCODE_AC_REFRESH :: Scancode.AC_REFRESH
SCANCODE_AC_BOOKMARKS :: Scancode.AC_BOOKMARKS


SCANCODE_BRIGHTNESSDOWN :: Scancode.BRIGHTNESSDOWN
SCANCODE_BRIGHTNESSUP :: Scancode.BRIGHTNESSUP
SCANCODE_DISPLAYSWITCH :: Scancode.DISPLAYSWITCH
SCANCODE_KBDILLUMTOGGLE :: Scancode.KBDILLUMTOGGLE
SCANCODE_KBDILLUMDOWN :: Scancode.KBDILLUMDOWN
SCANCODE_KBDILLUMUP :: Scancode.KBDILLUMUP
SCANCODE_EJECT :: Scancode.EJECT
SCANCODE_SLEEP :: Scancode.SLEEP

SCANCODE_APP1 :: Scancode.APP1
SCANCODE_APP2 :: Scancode.APP2

SCANCODE_AUDIOREWIND :: Scancode.AUDIOREWIND
SCANCODE_AUDIOFASTFORWARD :: Scancode.AUDIOFASTFORWARD
