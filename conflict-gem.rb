#Get list of packages and versions and put into a 2d array
#for each value in array
	#for each result in gem deps -r $name -v $verison
		#Add to a hash with name as key and version as value


#Print out entire hash table including duplicate values

require 'rubygems'
require 'gems'


#Get all of the dependenciew for a given gem
def getDeps(name,version)
	deps = Gems.dependencies [name]

	deps.each do |dep|
		#If it's a > 0 depencency then just use the first one in the array
		if version == 0 then 
			version = dep[0][:number]
		end
		if dep[:number] == version then
			dep[:dependencies].each do |sub_dep|
				getDeps(sub_dep[0],sub_dep[1].split(' ')[1])
				p sub_dep
			end
		end
	end
end

gem_name = 'r10k'
gem_version = '1.3.4'

getDeps(gem_name,gem_version)
