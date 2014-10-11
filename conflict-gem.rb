
require 'rubygems'
require 'gems'

$dependencies = Hash.new

#Get all of the dependenciew for a given gem
def getDeps(name,version)
	#Returns an array of hashes one for each version
	deps = Gems.dependencies [name]
	
	p "Hitting rubygems.org api for " + name + " version " + version

	#Loop through hash array looking for right version
	deps.each do |dep|
		#If it's a > 0 depencency then just use the first one in the array
		if dep[:number] == version or version == 0 then
			dep[:dependencies].each do |sub_dep|
				#Recurse on the subdependencies
				getDeps(sub_dep[0],sub_dep[1].split(' ')[1])
				#If a value exists append to existing key otherwise make a new one
				if $dependencies[sub_dep[0]] != nil then
					$dependencies[sub_dep[0]] = $dependencies[sub_dep[0]] + "," + sub_dep[1]
				else
					$dependencies[sub_dep[0]] = sub_dep[1]
				end
			end
		end
		
		#Don't print out every possible version
		if version == 0 then 
			break 
		end
	end
end

getDeps(ARGV[0],ARGV[1])

if $dependencies == {} then
	p "No dependencies found"
else
	$dependencies.each do |key, value|
		p key + "  " + value
	end
end
