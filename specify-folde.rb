#specify-folde.rb
#@author: Thomas Boyle
#@Date: 05/14/13

require 'rubygems'
require 'miro'
require 'chunky_png'

Miro.options[:color_count] = 1
Miro.options[:resolution] = '80x80'

#create new directory with timelapse name
puts File.basename(Dir.getwd)
tl_folder = File.basename(Dir.getwd)
'sudo mkdir /home/user/Documents/tl_files/#{tl_folder}'

#Outputs the name of the daily folder, and begins to go through each png in the folder
puts "Day: #{ARGV[0]}"

Dir.foreach("#{ARGV[0]}") do |x|
        if x =~ /.png$/
                #Creates a ChunkyPNG image from the current image
                #crops the image to contain just the top right 80x80 pixels, and saves it
                image = ChunkyPNG::Image.from_file("#{ARGV[0]}/#{x}")
                cimage =image.crop(1840, 0, 80, 80)
                cimage.save("/home/user/Documents/tl_files/#{tl_folder}/cropped/#{x}")

                #Creates a new colors object from the cropped image
                colors = Miro::DominantColors.new("/home/user/Documents/tl_files/#{tl_folder}/cropped/#{x}")

                rgbs = colors.to_rgb
                #If the blue value of the sampled image is between 110 and 155,
                #copy it (while retaining directory structure) over to another folder
                if (rgbs[0][0] > 110 && rgbs[0][0] < 155) && (rgbs[0][1] > 110 && rgbs[0][1] < 155) && (rgbs[0][2] > 110 && rgbs[0][2] < 155)
                         puts "#{x}:  Got here"
                        `sudo cp --parents #{ARGV[0]}/#{x} /home/user/Documents/tl_files/#{tl_folder}/`

                        rgbs.each do |z|
                                 print "["
                                 array = z
                                 array.each do |a|
                                         print "#{a}, "
                                 end
                                 print "] \n\n"
                         end
                end
        end
end
