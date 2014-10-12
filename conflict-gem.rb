#Query rubygems.org using the "gems" gem
#find all dependencies and subdependencies for a given gem
#Requires two arguments package Name and Version, in that order

require 'rubygems'
require 'gems'

$dependencies = Hash.new

#Get all of the dependenciew for a given gem
def getDeps(name,version)
	#Returns an array of hashes one for each version
	deps = Gems.dependencies [name]
	#Loop through hash array looking for right version
	deps.each do |dep|
		#If it's a > 0 depencency then just use the first one in the array
		if dep[:number] == version or version == 0 then
			dep[:dependencies].each do |sub_dep|

				#If a value exists append to existing key otherwise make a new one
				if $dependencies[sub_dep[0]] != nil then
					$dependencies[sub_dep[0]] = $dependencies[sub_dep[0]].push(sub_dep[1])
				else
					$dependencies[sub_dep[0]] = Array.new [sub_dep[1]]
				end
				#Recurse on the subdependencies
				getDeps(sub_dep[0],sub_dep[1].split(' ')[1])
			end
		end
		
		#Don't print out every possible version
		if version == 0 then 
			break 
		end
	end
end

def parseDeps(deps_list)
	if deps_list.length == 1 then 
		return deps_list[0] 
	end
	#Sort list by version number
	#for each
	#if >= go to next otherwise stop
	#if <= stop
	#otherwise return last record
end

getDeps(ARGV[0],ARGV[1])

if $dependencies == {} then
	p "No dependencies found"
else
	$dependencies.each do |key, value|
		p key
		value.each do |version|
			p version
		end
	end
end

