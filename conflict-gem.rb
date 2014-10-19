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
  if !(version.include? ' ') then
    version = "= " + version
    $dependencies[name] = Array.new [version]
  end

  #Add the current gem if the hash key has no value
  if $dependencies[name] == nil then
    $dependencies[name] = Array.new [version]
  end

  #Returns an array of hashes one for each possible version for that name
  gem_versions = Gems.dependencies [name]

  #If the version is 0, find the lowest possible version number and use that
  if version == ">= 0" || (version.include? 'beta' || 'pre') then
    gem_versions.each do |gem_version|
      if gem_version[:number] < version || version == "0" then
	if !(gem_version[:number].include? 'beta' || 'pre') then
          version = gem_version[:number]
	  puts "Gem " + name + " version " + gem_version[:number] + " " + version
        end
      end
    end
    $dependencies[name].push(">= " + version)
  end

  #Loop through hash array looking for right version
  gem_versions.each do |gem_version|

    if (version.include? '=' || '~') && gem_version[:number] == version.split(' ')[1]  then
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
	  #If it's a comma separated list of deps check one at a time
          if dep_version.include? ',' then
            dep_version.split(',').each do |comma_dep|
	      p dep_name + ' version ' + comma_dep
              $dependencies[dep_name].push(comma_dep)
              getDeps(dep_name,comma_dep)
            end
	  else
            #Add the dependency to the hash
            $dependencies[dep_name].push(dep_version)
            #Recurse on the subdependencies using just the version number
            getDeps(dep_name,dep_version)
	  end  
        end
      end
    end
  end
end

def findVersion(versions)
  if versions.length == 1 then
    return versions[0].split(' ')[1]
  else
    #Loop through the versions and set three variables
    #The smallest 'Less then' the largest 'Greater than' and the largest 'Equal to'
    less_than = nil
    equal_to = nil
    greater_than = nil

    versions.each do |version|
      value = version.split(' ')[1]
      case version.split(' ')[0]
      when '<=','<'
        if less_than == nil then
          less_than = value
  	elsif less_than >= value then
          less_than = value
        end
      when '~>','='
        if equal_to == nil then
          equal_to = value
        elsif equal_to <= value then
          equal_to = value
        end
      when '>=','>'
        if greater_than == nil then
          greater_than = value
        elsif greater_than <= value then
          greater_than = value
        end
      end
    end
    
    if less_than == nil then
      if greater_than == nil then
        return equal_to #If only E is present return E
      elsif equal_to == nil then
	return greater_than
      else #G and E are not nil so compare them
        if equal_to >= greater_than then
          return equal_to
        else
	  return greater_than
        end
      end
    elsif greater_than != nil then #G and L both exist
      if equal_to == nil then
	return less_than
      elsif equal_to <= less_than then
        return equal_to
      end
    else #All three are present
      if equal_to <= less_than && equal_to >= greater_than then
        return equal_to #Conflict-free match
      end
    end
    return "Conflict Found" 
  end
end

ARGV.each do |dep|
	getDeps(dep.split(',')[0],dep.split(',')[1])
end

#Print out in a way that can be easily pasted into the puppet manifest
#Need to add a way to deal with >= 0 only 
$dependencies.each do |key, value|
#  puts "bootstrap::gem { '" + key + ":                     version => '" +  findVersion(value) + "' }"
  puts key + value.to_s + " best match ->" + findVersion(value)
end



