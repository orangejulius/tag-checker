#!/usr/bin/ruby
require 'rubygems'
require 'bundler/setup'

require 'taglib'


def process_directory(path)
  music_directory = "/home/spectre256/music/"
  Dir.foreach(path) do |item|
    next if item == '.' or item == '..'
    puts item

    new_filename = item
    file_extension = File.extname(item)
    next unless valid_filetype? file_extension
    new_directory = music_directory
    TagLib::FileRef.open("#{path}#{item}") do |file|
      tag = file.tag
      required_attributes = %w(title album year artist track)
      required_attributes.each do |attr|
        unless tag.send(attr)
          puts "#{item} has no #{attr}, enter new #{attr}"
          tag.send("#{attr}=", gets.chomp)
        end
      end
      # check comment is empty
      tag.comment = nil
      #
      # check integrity of music file
      #
      new_filename = "#{tag.artist} - #{tag.album} - #{tag.track.to_s.rjust(2, '0')} - #{tag.title}#{file_extension}"
      new_directory = "#{music_directory}#{tag.artist}/#{tag.album}"

    end
    # move to music with formatted name
    puts "mkdir_p #{new_directory}"
    FileUtils.mkdir_p(new_directory)
    puts "cp #{path}/#{item} #{new_directory}/#{new_filename}"
    FileUtils.cp("#{path}/#{item}", "#{new_directory}/#{new_filename}")
  end
end

def valid_filetype?(filetype)
  ['.mp3', '.flac'].include? filetype
end

path = ARGV[0]
puts "procesing music in #{path}"

process_directory(path)
