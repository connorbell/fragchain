import os
import math
import subprocess

def getLength(filename):
    result = subprocess.Popen(["ffprobe", filename],
                              stdout = subprocess.PIPE, stderr = subprocess.STDOUT)
    string = [x for x in result.stdout.readlines() if "Duration" in x][0]
    s = string.split(" ")[3]
    s = s.split(":")[-1]
    s = s.replace(',','')
    s = s[1:]
    return float(s)

def getopts(argv):
    opts = {}  # Empty dictionary to store key-value pairs.
    while argv:  # While there are arguments left to parse...
        if argv[0][0] == '-':  # Found a "-name value" pair.
            opts[argv[0]] = argv[1]  # Add key and value to the dictionary.
        argv = argv[1:]  # Reduce the argument list by copying it starting from index 1.
    return opts

def main(inputFilename, outputFilename):
    
    os.system("mkdir " + outputFilename)
    os.system("move " + inputFilename + "*.png " + outputFilename)
    os.chdir(outputFilename)

    print "Creating mp4"
    outputMp4Filename = outputFilename + ".mp4"
    os.system("ffmpeg -r 60 -f image2 -s 1920x1080 -i \"" + inputFilename + "_%03d.png\" -vcodec libx264 -crf 25 -pix_fmt yuv420p " + outputMp4Filename)
    print "done!"
    
    outputMp4Filename = outputFilename + ".mp4"
    outputMp4Filename2 = outputFilename + "_looped.mp4"

    print "Looping vid to make longer than 3 seconds"
    vidLength = getLength(outputMp4Filename)
    print str(vidLength)
    lines = math.ceil(5.5 / vidLength);

    if lines > 1:
        i = 0
        text = ""
        while i < lines:
            text += "file '" + outputMp4Filename+"'\n"
            i+=1
                
        with open('list.txt', 'w') as the_file:
            the_file.write(text)
        
        os.system("ffmpeg -f concat -i list.txt -c copy " + outputMp4Filename2)
    else:
        print "looping not needed"
    
    print "done!"

    os.system("cd .." )

if __name__== "__main__":
    from sys import argv
    myargs = getopts(argv)
    main(myargs["-input"], myargs["-output"])
