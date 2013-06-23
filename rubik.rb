class Cube
	attr_accessor :cube, :aliases
	attr_accessor :_L, :_R
	attr_accessor :U, :L, :R, :F, :D, :B
	@_L, @_R = 0, 1
	@U, @D, @L, @R, @F, @B = 0, 1, 2, 3, 4, 5
	
	def makeFace(face)
		[[[face, @U, @_L], [face, @U, @_R]], 
		 [[face, @D, @_L], [face, @D, @_R]]]
	end
	
	def initialize
		@_L, @_R = 0, 1
		@U, @D, @L, @R, @F, @B = 0, 1, 2, 3, 4, 5
		@cube = [makeFace(@U), 
				 makeFace(@D), 
				 makeFace(@L), 
				 makeFace(@R), 
				 makeFace(@F), 
				 makeFace(@B)]
		
		@aliases = [
			[[:U, :U, :_L],[:L, :U, :_L],[:B, :U, :_R]],
			[[:U, :U, :_R],[:R, :U, :_R],[:B, :U, :_L]],
			[[:U, :D, :_L],[:L, :U, :_R],[:F, :U, :_L]],
			[[:U, :D, :_R],[:R, :U, :_L],[:F, :U, :_R]],
			[[:D, :U, :_L],[:F, :D, :_L],[:L, :D, :_R]],
			[[:D, :U, :_R],[:F, :D, :_R],[:R, :D, :_L]],
			[[:D, :D, :_L],[:L, :D, :_L],[:B, :D, :_R]],
			[[:D, :D, :_R],[:R, :D, :_R],[:B, :D, :_L]]
		].map { |group|
			group.map { |names|
				names.map { |name|
					send name
				}
			}
		}
	end
	
	def getCubie(accessor)
		@cube[accessor[0]][accessor[1]][accessor[2]]
	end
	
	def setCubie(accessor, value)
		@aliases.select { |cubies|
			cubies.include? accessor
		}.first.each { |cubie|
			@cube[cubie[0]][cubie[1]][cubie[2]] = value
		}
	end
	
	def permute(permutation)
		previous = []				
		permutation.each { |point|
			cubieAtPoint = getCubie point
			if previous.length > 0					
				setCubie point, previous
				previous = cubieAtPoint
			else
				previous =  cubieAtPoint
			end
		}
		setCubie(permutation.first, previous)
		return self
	end
	
	def invert(permutation)
		permute(permutation).permute(permutation).permute(permutation)
	end
	
	def cubie(face, y, x)
		[send(face), send(y), send(x)]
	end
	
	def to_s
		names = ["U", "D", "L", "R", "F", "B"]
		_names = ["L", "R"]
		"\n+---------+\n" + @cube.map { |face|
			'|' + face.map { |row|
				row.map { |cubie|
					names[cubie[0]] + names[cubie[1]] + _names[cubie[2]]
				}.join ' | '
			}.join("|\n|") + '|'
		}.join("\n+----+----+\n") + "\n+---------+\n"
	end
	
	def join_to_s(other)
		names = ["U", "D", "L", "R", "F", "B"]
		_names = ["L", "R"]
		
		headerLine = "\n+-----------++-----------+\n"
		separatorLine = "\n+-----+-----++-----+-----+\n"
		
		faceIndex = -1
		headerLine + @cube.map { |face|
			rowIndex = -1
			faceIndex += 1
			'| ' + face.map { |row|
				rowIndex += 1
				row.map { |cubie|
					names[cubie[0]] + names[cubie[1]] + _names[cubie[2]]
				}.join(' | ') + ' || ' + other.cube[faceIndex][rowIndex].map { |cubie|
					names[cubie[0]] + names[cubie[1]] + _names[cubie[2]]
				}.join(' | ')
			}.join(" | \n| ") + ' |'			
		}.join(separatorLine) + headerLine
	end
	
	def faceTurn(face)
		[
			[face, :U, :_L], 
			[face, :U, :_R], 
			[face, :D, :_R], 
			[face, :D, :_L]
		].map { |cubie|
			cubie.map { |name|
				send name
			}
		}
	end
end

cube = Cube.new()
defCube = Cube.new()

U = cube.faceTurn :U
D = cube.faceTurn :D
L = cube.faceTurn :L
R = cube.faceTurn :R
F = cube.faceTurn :F
B = cube.faceTurn :B

cube.permute L
cube.invert U
cube.invert R
cube.permute U

print defCube.join_to_s(cube)
