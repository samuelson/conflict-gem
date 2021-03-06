#!/usr/bin/ruby
#Query rubygems.org using the "gems" gem
#find all dependencies and subdependencies for a given gem
#Takes comma separated pairs of gem,version as arguments
#Will accept multiple arguments
#Versions can use ">=", "<=", "~>" etc syntax

require 'rubygems'
require 'gems'

$dependencies = Hash.new

#Get all of the dependenciew for a given gem
def getDeps(name,version)
  #If it's just a bare version number assume it should be explicit requirement
  if !(version.include? ' ') then
    version = "= " + version
  end

  #Returns an array of hashes one for each possible version for that name
  gem_versions = Gems.dependencies [name]

  #If no explicit version is set or a beta version, find a better version
  if version == ">= 0" or version == "= 0" or version =~ /[[:alpha:]]/ then
    gem_versions.each do |gem_version|
      if gem_version[:number] !~ /[[:alpha:]]/  then
        if (Gem::Version.new(gem_version[:number]) < Gem::Version.new(version.split(' ')[1])) or version.split(' ')[1] == "0" then
          version = ">= " + gem_version[:number]
        end
      end
    end
  end

  #Add the current gem if the hash key has no value
  if $dependencies[name] == nil then
    $dependencies[name] = Array.new [version]
  else #Otherwise append
    $dependencies[name].push(version)
  end
  
  #Loop through hash array looking for right version
  gem_versions.each do |gem_version|

    if gem_version[:number] == version.split(' ')[1]  then
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
        #else
        #  $dependencies[dep_name] = Array.new
        end

        if exists == false then
	  #If it's a comma separated list of deps check one at a time
          if dep_version.include? ',' then
            dep_version.split(',').each do |comma_dep|
              getDeps(dep_name,comma_dep)
            end
	  else #Look for subdependencies
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

    #Narrow down the array of versions to the most restrictive
    versions.each do |version|
      value = version.split(' ')[1]
      case version.split(' ')[0]
      when '<=','<'
        if less_than == nil then
          less_than = value
  	elsif Gem::Version.new(less_than) >= Gem::Version.new(value) then
          less_than = value
        end
      when '~>','='
        if equal_to == nil then
          equal_to = value
        elsif Gem::Version.new(equal_to) <= Gem::Version.new(value) then
          equal_to = value
        end
      when '>=','>'
        if greater_than == nil then
          greater_than = value
        elsif Gem::Version.new(greater_than) <= Gem::Version.new(value) then
          greater_than = value
        end
      end
    end
    
    #Compare the three versions and find the best fit
    if less_than == nil then
      if greater_than == nil then
        return equal_to #If only E is present return E
      elsif equal_to == nil then
	return greater_than
      else #G and E are not nil so compare them
        if Gem::Version.new(equal_to) >= Gem::Version.new(greater_than) then
          return equal_to
        else
	  return greater_than
        end
      end
    elsif greater_than != nil then #G and L both exist
      if equal_to == nil then
	return less_than
      elsif Gem::Version.new(equal_to) <= Gem::Version.new(less_than) then
        return equal_to
      end
    else #All three are present
      if Gem::Version.new(equal_to) <= Gem::Version.new(less_than) and Gem::Version.new(equal_to) >= Gem::Version.new(greater_than) then
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
$dependencies.each do |key, value|
  printf "%-55s %-20s %-5s\n", "bootstrap::gem { '" + key + ":" , "version => '" +  findVersion(value) + "'" ,"}"
end
