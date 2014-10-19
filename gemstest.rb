#!/usr/bin/ruby

require 'rubygems'
require 'gems'


  #Returns an array of hashes one for each possible version for that name
  gem_versions = Gems.dependencies ['rspec-its']

    gem_versions.each do |gem_version|
      if gem_version[:number].include? 'beta' then
	      p gem_version[:name] + " version " + gem_version[:number] + " skipping beta"
      else
	      p gem_version[:name] + " version " + gem_version[:number]
      end
    end

