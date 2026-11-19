package gravity

import m "core:math"
import la "core:math/linalg"
import b2 "vendor:box2d"
import rl "vendor:raylib"

Entity :: struct {
	body_id:  b2.BodyId,
	position: b2.Vec2,
	color:    rl.Color,
	size:     f32,
}

WIDTH :: i32(1920)
HEIGHT :: i32(1080)
G :: 6.674e-11

draw_point :: proc(entity: Entity) {
	p := b2.Body_GetWorldPoint(entity.body_id, entity.position)
	rl.DrawCircleV(p, entity.size, entity.color)
}

orbital_velocity :: proc(mass, radius: f32) -> f32 {
	return m.sqrt(G * mass / radius)
}

grav_force :: proc(m1, m2, radius: f32) -> f32 {
	return G * m1 * m2 / (radius * radius)
}

distance :: proc(entity_1, entity_2: Entity) -> f32 {
	return la.distance(entity_1.position, entity_2.position)
}

vector_to :: proc(entity_1, entity_2: Entity) -> b2.Vec2 {
	return b2.Vec2 {
		(entity_2.position.x - entity_1.position.x),
		(entity_2.position.y - entity_1.position.y),
	}
}

main :: proc() {
	//width := i32(1920)
	//height := i32(1080)
	width := WIDTH
	height := HEIGHT
	rl.InitWindow(width, height, "Gravity")

	rl.SetTargetFPS(60)

	length_units_per_meter := f32(128.)
	b2.SetLengthUnitsPerMeter(length_units_per_meter)

	world_def := b2.DefaultWorldDef()

	//world_def.gravity.y = 9.8 * length_units_per_meter
	world_id := b2.CreateWorld(world_def)

	sun := Entity {
		body_id  = b2.CreateBody(world_id, b2.DefaultBodyDef()),
		position = b2.Vec2{f32(WIDTH) / 2., f32(HEIGHT) / 2.},
		color    = rl.YELLOW,
		size     = 64.,
	}

	planet := Entity {
		body_id  = b2.CreateBody(world_id, b2.DefaultBodyDef()),
		position = b2.Vec2{f32(WIDTH) / 2., f32(HEIGHT) / 4.},
		color    = rl.BLUE,
		size     = 10.,
	}

	system: [2]Entity = {sun, planet}

	pause: bool
	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(.P) {
			pause = !pause
		}

		if !pause {
			delta_time := rl.GetFrameTime()
			b2.World_Step(world_id, delta_time, 4)
		}

		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.DARKGRAY)

		for body in system {
			draw_point(body)
		}
	}
}
