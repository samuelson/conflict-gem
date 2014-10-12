#Query rubygems.org using the "gems" gem
#find all dependencies and subdependencies for a given gem
#Requires two arguments package Name and Version, in that order
#Doesn't detect circular dependencies

require 'rubygems'
require 'gems'

$dependencies = Hash.new

#Get all of the dependenciew for a given gem
def getDeps(name,version)
	#Returns an array of hashes one for each version
	gem_versions = Gems.dependencies [name]
	if version == "0" then
		version = gem_versions[0][:number]
	end

	#Loop through hash array looking for right version
	gem_versions.each do |gem_version|

		if gem_version[:number] == version  then
			#Loop through the depenencies for a given version
			gem_version[:dependencies].each do |dep|
				dep_name = dep[0]
				dep_version = dep[1]
				exists = false
					
				#If a value exists append to existing key otherwise make a new array
				if $dependencies[dep_name] != nil then
					#Check if that version is already in the hash
					#Only check on versions that haven't been checked yet
					#Should fix endless recursion on circular dependencies
					$dependencies[dep_name].each do |other_version|
						if dep_version == other_version then
							exists = true
						end
					end
				else
					$dependencies[dep_name] = Array.new
				end
				
				if exists == false then
					$dependencies[dep_name].push(dep_version)
					#Recurse on the subdependencies using just the version number
					#If there are two listed, pick the first one
					getDeps(dep_name,dep_version.split(' ')[1].split(',')[0])
				end
			end
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

