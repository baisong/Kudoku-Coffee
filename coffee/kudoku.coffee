###
The MIT License

   Copyright (c) 2011 by Attractive Chaos <attractor@live.co.uk>

   Permission is hereby granted, free of charge, to any person obtaining
   a copy of this software and associated documentation files (the
   "Software"), to deal in the Software without restriction, including
   without limitation the rights to use, copy, modify, merge, publish,
   distribute, sublicense, and/or sell copies of the Software, and to
   permit persons to whom the Software is furnished to do so, subject to
   the following conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
   BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
   ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
   CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
###

function sd_genmat() {
	var i, j, r, c, c2, C = [], R = []
	for (i = r = 0; i < 9; ++i)
		for (j = 0; j < 9; ++j)
			for (k = 0; k < 9; ++k)
				C[r++] = [ 9 * i + j, (Math.floor(i/3)*3 + Math.floor(j/3)) * 9 + k + 81, 9 * i + k + 162, 9 * j + k + 243 ]
	for (c = 0; c < 324; ++c) R[c] = []
	for (r = 0; r < 729; ++r)
		for (c2 = 0; c2 < 4; ++c2)
			R[C[r][c2]].push(r)
	return [R, C];
}

function sd_update(R, C, sr, sc, r, v) {
	var min = 10, min_c = 0;
	for (var c2 = 0; c2 < 4; ++c2) sc[C[r][c2]] += v<<7;
	for (var c2 = 0; c2 < 4; ++c2) {
		var r2, rr, cc2, c = C[r][c2];
		if (v > 0) {
			for (r2 = 0; r2 < 9; ++r2) {
				if (sr[rr = R[c][r2]]++ != 0) continue;
				for (cc2 = 0; cc2 < 4; ++cc2) {
					var cc = C[rr][cc2];
					if (--sc[cc] < min)
						min = sc[cc], min_c = cc;
				}
			}
		} else { // revert
			for (r2 = 0; r2 < 9; ++r2) {
				if (--sr[rr = R[c][r2]] != 0) continue;
				var p = C[rr]
				++sc[p[0]]; ++sc[p[1]]; ++sc[p[2]]; ++sc[p[3]];
			}
		}
	}
	return min<<16 | min_c; // return the col that has been modified and with the minimal available choices
}

function sd_solve(R, C, _s, max_ret) {
	var i, j, r, c, r2, min, cand, dir, hints = 0;
	var sr = [], sc = [], cr = [], cc = [], out = [], ret = [];
	if (max_ret == null) max_ret = 2;
	for (r = 0; r < 729; ++r) sr[r] = 0;
	for (c = 0; c < 324; ++c) sc[c] = 9;
	for (i = 0; i < 81; ++i) {
		var a = _s.charAt(i) >= '1' && _s.charAt(i) <= '9'? _s.charCodeAt(i) - 49 : -1;
		if (a >= 0) sd_update(R, C, sr, sc, i * 9 + a, 1);
		if (a >= 0) ++hints;
		cr[i] = cc[i] = -1, out[i] = a + 1;
	}
	for (i = 0, dir = 1, cand = 10<<16|0;;) {
		while (i >= 0 && i < 81 - hints) {
			if (dir == 1) {
				min = cand>>16, cc[i] = cand&0xffff
				if (min > 1) {
					for (c = 0; c < 324; ++c) {
						if (sc[c] < min) {
							min = sc[c], cc[i] = c;
							if (min <= 1) break;
						}
					}
				}
				if (min == 0 || min == 10) cr[i--] = dir = -1;
			}
			c = cc[i];
			if (dir == -1 && cr[i] >= 0) sd_update(R, C, sr, sc, R[c][cr[i]], -1);
			for (r2 = cr[i] + 1; r2 < 9; ++r2)
				if (sr[R[c][r2]] == 0) break;
			if (r2 < 9) {
				cand = sd_update(R, C, sr, sc, R[c][r2], 1);
				cr[i++] = r2; dir = 1;
			} else cr[i--] = dir = -1;
		}
		if (i < 0) break;
		var y = []
		for (j = 0; j < 81; ++j) y[j] = out[j]
		for (j = 0; j < i; ++j) r = R[cc[j]][cr[j]], y[Math.floor(r/9)] = r%9 + 1;
		ret.push(y)
		if (ret.length >= max_ret) return ret;
		--i; dir = -1;
	}
	return ret;
}
