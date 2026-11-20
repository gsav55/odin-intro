package gravity

import "core:fmt"
import m "core:math"
import la "core:math/linalg"
import b2 "vendor:box2d"
import rl "vendor:raylib"

Entity :: struct {
	body_id: b2.BodyId,
	extent:  b2.Vec2,
	color:   rl.Color,
	size:    f32,
}

WIDTH :: i32(1920)
HEIGHT :: i32(1080)
G :: 6.674e-11

draw_point :: proc(entity: Entity) {
	p := b2.Body_GetPosition(entity.body_id)
	rl.DrawCircleV(p, entity.size, entity.color)

}

orbital_velocity :: proc(mass_attractor, radius: f32) -> f32 {
	return m.sqrt(G * mass_attractor / radius)
}

grav_force :: proc(m1, m2, radius: f32) -> f32 {
	return G * m1 * m2 / (radius * radius)
}

// May need to use b2.Body_getPosition if entity.position doesn't update with physics.
distance :: proc(entity_1, entity_2: Entity) -> f32 {
	return la.distance(
		b2.Body_GetPosition(entity_1.body_id),
		b2.Body_GetPosition(entity_2.body_id),
	)
}

// May need to use b2.Body_getPosition if entity.position doesn't update with physics.
vector_to :: proc(from, to: Entity) -> b2.Vec2 {
	to_pos := b2.Body_GetPosition(to.body_id)
	from_pos := b2.Body_GetPosition(from.body_id)
	return b2.Vec2{(to_pos.x - from_pos.x), (to_pos.y - from_pos.y)}
}

main :: proc() {
	//width := i32(1920)
	//height := i32(1080)
	width := WIDTH
	height := HEIGHT
	rl.InitWindow(width, height, "Gravity")
	defer rl.CloseWindow()

	rl.SetTargetFPS(60)

	length_units_per_meter := f32(128.)
	b2.SetLengthUnitsPerMeter(length_units_per_meter)

	world_def := b2.DefaultWorldDef()

	//world_def.gravity.y = 9.8 * length_units_per_meter
	world_id := b2.CreateWorld(world_def)

	sun_def := b2.DefaultBodyDef()
	sun_def.position = {f32(WIDTH / 2.), f32(HEIGHT / 2.)}

	sun := Entity {
		body_id = b2.CreateBody(world_id, sun_def),
		extent  = b2.Vec2{32., 32.},
		color   = rl.YELLOW,
		size    = 64.,
	}

	planet_def := b2.DefaultBodyDef()
	planet_def.type = .dynamicBody
	planet_def.position = {f32(WIDTH / 2), f32(HEIGHT / 4)}
	planet_def.linearVelocity = {500., 0.}
	planet_def.linearDamping = 0


	planet := Entity {
		body_id = b2.CreateBody(world_id, planet_def),
		extent  = b2.Vec2{5., 5.},
		color   = rl.BLUE,
		size    = 10.,
	}

	shape_def := b2.DefaultShapeDef()
	_ = b2.CreatePolygonShape(planet.body_id, shape_def, b2.MakeBox(planet.size, planet.size))

	system: [2]Entity = {sun, planet}

	pause: bool = true
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

		font_size := i32(36)
		message := fmt.ctprintf("%f", b2.Body_GetPosition(planet.body_id))
		text_width := rl.MeasureText(message, font_size)
		rl.DrawText(message, (WIDTH - text_width) / 2, 50, font_size, rl.LIGHTGRAY)

		for body in system {
			draw_point(body)
		}
	}
}
