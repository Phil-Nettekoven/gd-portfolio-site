extends Node

const MAX_SPEED:float  = 100
const SPRINT_MAX_SPEED:float = MAX_SPEED*2
const SPRINT_MOD:float = 2.0
const ACCELERATION:float = 50
const SPRINT_ACCELERATION:float = ACCELERATION*1.25
const DECELERATION:float = 100
const SPRINT_DECELERATION:float = DECELERATION*0.5

const JUMP_VELOCITY:float = 20
const JUMP_MOD:float = 1.25
const JUMP_COOLDOWN:float = 0.05
const GRAVITY_MOD:float = 2.0

const MUSIC_MAX_SPEED:float = MAX_SPEED/4 #The player's speed at which the BGM will play at pitch = 1.0