#specify-folde.rb
#@author: Thomas Boyle
#@Date: 05/14/13

require 'rubygems'
require 'miro'
require 'chunky_png'


Miro.options[:color_count] = 1
Miro.options[:resolution] = '80x80'


def checker(mf, tlf, x)
        if x =~ /.png$/               

                #Creates necessary folders
                if File.exists?("/home/user/Documents/tl_files/#{mf}/#{tlf}") == false
                        system("mkdir /home/user/Documents/tl_files/#{mf}")
                end
                if File.exists?("/home/user/Documents/tl_files/#{mf}/#{tlf}") == false
                        system("mkdir /home/user/Documents/tl_files/#{mf}/#{tlf}")
                end
                if File.exists?("/home/user/Documents/tl_files/#{mf}/#{tlf}/cropped") == false
                        system("mkdir /home/user/Documents/tl_files/#{mf}/#{tlf}/cropped")
                end


                #Creates a ChunkyPNG image from the current image
                #crops the image to contain just the top right 80x80 pixels, and saves it
                abs_path = %x"find `pwd` -name #{x}"
                #puts "Absolute path: #{abs_path}"
                image = ChunkyPNG::Image.from_file(x)
                cimage =image.crop(1840, 0, 80, 80)
                cimage.save("/home/user/Documents/tl_files/#{mf}/#{tlf}/cropped/#{x}")

                #Creates a new colors object from the cropped image
                colors = Miro::DominantColors.new("/home/user/Documents/tl_files/#{mf}/#{tlf}/cropped/#{x}")

                rgbs = colors.to_rgb
                #If the blue value of the sampled image is between 110 and 155,
                #copy it (while retaining directory structure) over to another folder
                if (rgbs[0][0] > 110 && rgbs[0][0] < 155) && (rgbs[0][1] > 110 && rgbs[0][1] < 155) && (rgbs[0][2] > 110 && rgbs[0][2] < 155)
                         puts "#{x}:  Got here"
                        `sudo cp #{x} /home/user/Documents/tl_files/#{mf}/#{tlf}/`

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

Dir.chdir(ARGV[0])
puts Dir.pwd

Dir.foreach("#{ARGV[0]}") do |x|
        $first == true
        #puts x
        Dir.chdir(ARGV[0])

        #Skips unnecessary files
        if x == "." || x == ".."
                puts "Found #{x}"
                next
        #If x is a directory, does the following
        elsif File.directory?(x)

                #Changes directory, sets main folder to the argument passed in, and sets tl_folder to x
                Dir.chdir(x)
                $main_folder = File.basename(ARGV[0])
                $tl_folder = x

                puts "Main Folder: #{mf}"
                puts "Day: #{tlf}"
                
                #For each item in the directory, run the image checker
                Dir.foreach(Dir.pwd) do |png|
                        checker $main_folder, $tl_folder, png
                end
        else
                if $first == true
                        $first = false
                        puts "Main Folder: #{mf}"
                        puts "Day: #{tlf}"
                end

                #Changes directory, sets main folder to the argument passed in's parent folder, and sets tl_folder to argument passed in
                $main_folder = File.basename(File.expand_path("..",Dir.pwd))
                $tl_folder = File.basename(Dir.getwd)
                
                #For each item in the directory, run the image checker
                checker $main_folder, $tl_folder, x
        end
end
