module matrix

pub struct Matrix {
pub mut:
	rows int
	cols int
	data []f32
}

pub fn (m Matrix) index(i int, j int) f32 {
	return m.data[i * m.cols + j]
}

pub fn (mut m Matrix) set_index(i int, j int, val f32) {
	m.data[i * m.cols + j] = val
}

pub fn new_matrix(rows int, cols int) !Matrix {
	if rows <= 0 || cols <= 0 {
		return error('matrix rows and cols cannot be <= 0')
	}

	return Matrix{
		rows: rows
		cols: cols
		data: []f32{len: rows * cols, init: 0}
	}
}

pub fn new_matrix_with_data(rows int, cols int, data []f32) !Matrix {
	if rows <= 0 || cols <= 0 {
		return error('matrix rows and cols cannot be <= 0')
	}

	return Matrix{
		rows: rows
		cols: cols
		data: data
	}
}

/*
fn identity_matrix(n int) Matrix {
    m := new_matrix(n, n)
    for i := 0; i < n; i++ {
        m.set_index(i, i, 1)
    }
    return m
}
*/

pub fn zero_matrix(rows int, cols int) !Matrix {
	return new_matrix(rows, cols)
}

pub fn (a Matrix) mul(b Matrix) Matrix {
	$if debug {
		println('a: ${a}, b: ${b}')
		println('a.rows: ${a.rows}, a.cols: ${a.cols}')
		println('b.rows: ${b.rows}, b.cols: ${b.cols}')
	}

	if a.cols != b.rows {
		panic('Invalid matrix dimensions')
	}
	mut c := new_matrix(a.rows, b.cols) or { panic(err) }
	for i := 0; i < a.rows; i++ {
		for j := 0; j < b.cols; j++ {
			mut sum := f32(0.0)
			for k := 0; k < a.cols; k++ {
				sum += a.index(i, k) * b.index(k, j)
			}
			c.set_index(i, j, sum)
		}
	}
	return c
}

pub fn (a Matrix) * (b Matrix) Matrix {
	return a.mul(b)
}
