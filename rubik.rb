class Proc
	# modify the lambda class.
	def self.compose(f, g)
		# provide a function for composition.
		lambda { |*args| f[g[*args]] }
	end
	def *(g)
		# provide an infix shorthand with reversed order, to...
		# ... make writing of algorithms natural.
		Proc.compose(g, self)
	end
	def inv
		self * self * self
	end
end

class Cube
	attr_accessor :cube, :aliases
	attr_accessor :U, :L, :R, :F, :D, :B
	# we need @_L and @_R to be defined separately from @L and @R because...
	# ... @U and @D will represent first and second of an array, and so...
	# ... when it comes down to the x axis of a face and we need either first...
	# ... or second, we cannot merely reuse @L and @R.
	attr_accessor :_L, :_R

	@_L, @_R = 0, 1
	@U, @D, @L, @R, @F, @B = 0, 1, 2, 3, 4, 5
	
	def makeFace(face)
		# a face is of the form [[LUL, LUR], [LDL, LDR]], where...
		# ... LUL et. al. are expressed as [@L, @U, @_L].
		[[[face, @U, @_L], [face, @U, @_R]], 
		 [[face, @D, @_L], [face, @D, @_R]]]
	end
	
	def initialize
		# set instance variables, including cubie naming, initial cube, ...
		# ... and the various faces to each cubie (not yet put to use).
		@_L, @_R = 0, 1
		@U, @D, @L, @R, @F, @B = 0, 1, 2, 3, 4, 5
		@cube = [makeFace(@U), 
			 makeFace(@D), 
			 makeFace(@L), 
			 makeFace(@R), 
			 makeFace(@F), 
			 makeFace(@B)]
		
		# aliases are not yet put to use but will be used to identify...
		# ... which cubes were permuted, which were oriented.
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
		# take a cubie name (e.g., [@L, @U, @_L]) and find the cubie...
		# ... value at that position.
		@cube[accessor[0]][accessor[1]][accessor[2]]
	end
	
	def setCubie(cubie, value)
		# take a cubie name (e.g., [@L, @U, @_L]) and set the cubie...
		# ... value at that position.
		@cube[cubie[0]][cubie[1]][cubie[2]] = value
	end
	
	def permute(permutation)
		# a cyclical permutation is traditionally expressed as (a, b, c)...
		# ... thus our representation takes on a similar form, [a, b, c],...
		# ... where each letter is a cubie position.

		# to perform a permutation of this form, we cycle through each...
		# ... term, taking the prior cubie and placing it in its new position.
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
		# since we are dealing with cyclical permutations, there is...
		# ... "wrap-around".
		setCubie(permutation.first, previous)
		self
	end	
	
	def to_s
		# render a cube as a table.
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
		# render two cubes side by side in a table.
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

	def formPermutation(permutation)
		# map symbolic cubie name, e.g., [:L, :U, :_L] to a list...
		# ... of indices, e.g., [@L, @U, @_L].
		permutation.map { |cubie|
			cubie.map { |name|
				send name
			}
		}
	end

	def faceTurn(face)
		# form the permutation corresponding to a turn of a given...
		# ... face. this permutation includes a transpose of the...
		# ... turned face and two cyclical permutations on adjacent...
		# ... faces, as well.

		# transpose...
		permute formPermutation([
			[face, :U, :_L], 
			[face, :U, :_R], 
			[face, :D, :_R], 
			[face, :D, :_L]
		])

		# permute adjacent faces
		permutationFar = []
		permutationClose = []
		if face == :U or face == :D
			permutationFar = [
				[:L, face, :_L],
				[:F, face, :_L],
				[:R, face, :_L],
				[:B, face, :_L]
			]
			permutationClose = [
				[:L, face, :_R],
				[:F, face, :_R],
				[:R, face, :_R],
				[:B, face, :_R]
			]
		elsif face == :L or face == :R
			third = face == :L ? :_L : :_R
			permutationFar = [
				[:U, :U, third],
				[:F, :U, third],
				[:D, :U, third],
				[:B, :D, third==:_L ? :_R : :_L],
			]
			permutationClose = [
				[:U, :D, third],
				[:F, :D, third],
				[:D, :D, third],
				[:B, :U, third==:_L ? :_R : :_L]
			]
		elsif face == :F or face == :B
			permutationFar = [
				[:U, face == :F ? :D : :U, face == :F ? :_L : :_L],
				[:R, face == :F ? :U : :U, face == :F ? :_L : :_R],
				[:D, face == :F ? :U : :D, face == :F ? :_L : :_L],
				[:L, face == :F ? :D : :D, face == :F ? :_R : :_L],
			]
			permutationClose = [
				[:U, face == :F ? :D : :U, face == :F ? :_R : :_R],
				[:R, face == :F ? :D : :D, face == :F ? :_L : :_R],
				[:D, face == :F ? :U : :D, face == :F ? :_R : :_R],
				[:L, face == :F ? :U : :U, face == :F ? :_R : :_R]
			]
		end

		permute formPermutation(permutationFar)
		permute formPermutation(permutationClose)

		self
	end
end

# form two cubes, one for manipulation and one for comparison.
cube = Cube.new()
defCube = Cube.new()

# make faceturn lambdas of our cube to be manipulated.
U = lambda { |cube| cube.faceTurn :U }
D = lambda { |cube| cube.faceTurn :D }
L = lambda { |cube| cube.faceTurn :L }
R = lambda { |cube| cube.faceTurn :R }
F = lambda { |cube| cube.faceTurn :F }
B = lambda { |cube| cube.faceTurn :B }

# perform an algorithm:
# 	L U' R' U L' U R U
(L * U.inv * R.inv * U * L.inv * U * R * U)[cube]

# print our results compared to our default cube in a table.
print defCube.join_to_s(cube)
