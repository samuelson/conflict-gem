#!/usr/bin/ruby
#Query rubygems.org using the "gems" gem
#find all dependencies and subdependencies for a given gem
#Takes comma separated pairs of gem,version as arguments
#Will accept multiple arguments

require 'rubygems'
require 'gems'

$dependencies = Hash.new

#Get all of the dependenciew for a given gem
def getDeps(name,version)

  #Add the current gem if the hash key has no value
  if $dependencies[name] == nil then
    $dependencies[name] = Array.new ["= " + version]
  end

  #Returns an array of hashes one for each possible version for that name
  gem_versions = Gems.dependencies [name]

  #If the version is 0, find the lowest possible version number and use that
  if version == "0" then
    version = gem_versions[0][:number]
    gem_versions.each do |gem_version|
      if gem_version[:number] < version then
        version = gem_version[:number]
      end
    end
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
          #Add the dependency to the hash
          $dependencies[dep_name].push(dep_version)
          #Recurse on the subdependencies using just the version number
          getDeps(dep_name,dep_version.split(',')[0].split(' ')[1])
	  #p name + " " + version + " requires " + dep_name + " " + dep_version
        end
      end
    end
  end
end

ARGV.each do |dep|
	getDeps(dep.split(',')[0],dep.split(',')[1])
end

#Print out in a way that can be easily pasted into the puppet manifest
$dependencies.each do |key, value|
  #If there is only one version, print it in the final fromat
  if value.length == 1 then
    puts "bootstrap::gem { '" + key + ":                     version => '" +  value[0].split(' ')[1] + "' }"
  else
    value.each do |version|
      puts "bootstrap::gem { '" + key + ":                     version => '" +  version + "' }"
    end
  end
end

