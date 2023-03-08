module main

import gg
import gx
import math
import math.vec
import time
import matrix

const speed = 3

const distance = 2

const point_color = gx.green
const pen_config_line = gg.PenConfig{color: point_color, thickness: 1}
const text_config = gx.TextCfg{color: point_color}
const fps_config = gg.FPSConfig{text_config: gx.TextCfg{
		color: gx.green
		size: 20
		align: .center
		vertical_align: .middle
	}}

struct Game {
mut:
	gg      &gg.Context = unsafe { nil }
	height  int
	width   int
	draw_fn voidptr
	angle   f32

	points     []vec.Vec3[f32]
	rotation_x matrix.Matrix
	rotation_y matrix.Matrix
	rotation_z matrix.Matrix
	projection matrix.Matrix
}

fn main() {
	mut game := &Game{
		gg: 0
		height: 400
		width: 600
		draw_fn: 0
		points: [vec.Vec3[f32]{
			x: 50
			y: 50
			z: 50
		}, vec.Vec3[f32]{
			x: 150
			y: 50
			z: 50
		}, vec.Vec3[f32]{
			x: 150
			y: 150
			z: 50
		}, vec.Vec3[f32]{
			x: 50
			y: 150
			z: 50
		}, vec.Vec3[f32]{
			x: 50
			y: 50
			z: 150
		}, vec.Vec3[f32]{
			x: 150
			y: 50
			z: 150
		}, vec.Vec3[f32]{
			x: 150
			y: 150
			z: 150
		}, vec.Vec3[f32]{
			x: 50
			y: 150
			z: 150
		}]
	}

	game.gg = gg.new_context(
		bg_color: gx.black
		user_data: game
		width: game.width
		height: game.height
		window_title: '3D Renderer'
		frame_fn: frame
	)
	game.gg.fps = fps_config

	game.projection = matrix.new_matrix_with_data(2, 3, [
		f32(1), 0, 0, 0, 1, 0
	]) or {panic(err)}

	spawn game.run()
	game.gg.run()
}

[live]
fn frame(mut game Game) {
	game.gg.begin()

	offset := (game.height / 2) - 25

	$if debug {
		for point in game.points {
			game.gg.draw_circle_filled(point.x + 30, point.y + 30, 5, gx.white)
		}
	}

	game.gg.show_fps()

	//game.gg.draw_text(5, 5, "Cube Renderer -", text_config)

	game.rotation_y = matrix.new_matrix_with_data(3, 3, [
		f32(math.cos(game.angle)),
		0,
		f32(math.sin(game.angle)),
		0,
		1,
		0,
		f32(-math.sin(game.angle)),
		0,
		f32(math.cos(game.angle)),
	]) or { panic(err) }

	game.rotation_x = matrix.new_matrix_with_data(3, 3, [
		f32(1),
		0,
		0,
		0,
		f32(math.cos(game.angle)),
		f32(-math.sin(game.angle)),
		0,
		f32(math.sin(game.angle)),
		f32(math.cos(game.angle)),
	]) or { panic(err) }

	game.rotation_z = matrix.new_matrix_with_data(3, 3, [
		f32(math.cos(game.angle)),
		f32(-math.sin(game.angle)),
		0,
		f32(math.sin(game.angle)),
		f32(math.cos(game.angle)),
		0,
		0,
		0,
		1,
	]) or { panic(err) }

	mut projected_points := []matrix.Matrix{}

	for point in game.points {
		mat_vec := vec_to_matrix(point)
		rotated_y := game.rotation_y * mat_vec
		rotated_x := game.rotation_x * rotated_y
		rotated_z := game.rotation_z * rotated_x

		/*
		z := 1 / (distance - rotated_z.index(0, 2))

		game.projection = matrix.new_matrix_with_data(2, 3, [
			f32(z),
			0,
			0,
			0,
			f32(z),
			0,
		]) or {panic(err)}

		*/

		projected := game.projection * rotated_z

		//println("projected: ${projected}")
		projected_points << projected
		$if debug {
			println("projected_points: ${projected_points}, len: ${projected_points.len}")
		}

		game.gg.draw_circle_filled(projected.index(0, 0) + offset,
			projected.index(0, 1) + offset, 5, point_color)
	}

	/*
	*	Connect
	*/

	
	for i := 0; i < 4; i++ {
		connect(game.gg, i, (i + 1) % 4, projected_points, offset)
    	connect(game.gg, i + 4, ((i + 1) % 4) + 4, projected_points, offset)
    	connect(game.gg, i, i + 4, projected_points, offset)
	}

	game.gg.end()
}

fn connect(ctx gg.Context, i int, j int, points []matrix.Matrix, offset int) {
	a := points[i]
	b := points[j]

	ctx.draw_line_with_config(a.index(0,0) + offset, a.index(0,1) + offset, b.index(0,0) + offset, b.index(1,0) + offset, pen_config_line)
}

[live]
fn (mut game Game) run() {
	for {
		game.angle += 0.01 * speed
		time.sleep(16 * time.millisecond) // 60fps
	}
}

fn vec_to_matrix(v vec.Vec3[f32]) matrix.Matrix {
	mut m := matrix.new_matrix(3, 1) or { panic(err) }
	m.set_index(0, 0, v.x)
	m.set_index(1, 0, v.y)
	m.set_index(2, 0, v.z)

	return m
}

fn mat_to_vector(m matrix.Matrix) vec.Vec3[f32] {

	if m.data.len != 3 {
		return vec.Vec3[f32]{
			x: m.index(0, 0)
			y: m.index(1, 0)
			z: 0
		}
	}

	return vec.Vec3[f32]{
		x: m.index(0, 0)
		y: m.index(1, 0)
		z: m.index(2, 0)
	}
}
