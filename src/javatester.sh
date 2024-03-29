#!/bin/bash
# This is a script I made for automating the process of testing java programming assignments.


# Print the help screen
function print_help {
    printf "Usage: ${0##*/} <OPTIONS> [filename]\n\n"
    printf " Compiles and tests a java program using all available .in and cooresponding .out files.\n\n"
    printf "Options:\n\n"

    printf " %-20s" "-t, --time"
    printf "Time the program execution.\n\n"

    printf " %-20s" "-d, --diff"  
    printf "Displays the difference, if any, between the .out file and program output.\n\n"

    printf " %-20s\n\n" "-fs SUFFIX, --filename-suffix SUFFIX"
    printf " %-20s" ""
    printf "Only use input/output file names that end with SUFFIX.\n"
    printf " %-20s" ""
    printf "Useful for when you do not want to test all files in the directory.\n\n"

    printf " %-20s" "-b, --bin"
    printf "Compile java file to ../bin.\n\n"

    printf " %-20s" "-h, --help"
    printf "Show this message.\n\n"
}

# If no input is given, just print the help screen
if [[ $# == 0 ]]; then
    print_help
    exit 0
fi

# Get cli flags
SHOW_DIFF=false
USE_BIN=false
TIMEIT=false
SUFFIX=""
for arg in $@; do
    case $arg in

    -t | --time)
        TIMEIT=true
        shift
        ;;

    -d | --diff)
        SHOW_DIFF=true

        shift
        ;;
    
    --fs | --filename-suffix)
        shift
        SUFFIX=$1
        shift
        ;;

    -b | --bin)
        USE_BIN=true

        shift
        ;;

    -h | --help)
        print_help

        exit 0
        ;;

    esac
done

# Get the filename and extension
java_file=$1;
extension=${java_file##*.}

# Append the file extension if it is not added.
if [[ $extension != "java" ]]; then
    java_file="${java_file}.java"
fi

# Compile the java file
if [[ -f $java_file ]]; then

    # Determine if to compile to ../bin
    if [[ $USE_BIN == true ]]; then
        javac -d "../bin" $java_file
    else
        javac $java_file
    fi

else
    echo "Could not find file $java_file"
    exit 1
fi

# Now that we are sure java_file has the .java extension, extract the filename
java_name=${java_file%%.*}

# Match the list of files that end with the suffix and are .in files
files=*${SUFFIX}.in

# Convert to an array to see if any files have been found
file_array=($files)
if [[ ${#file_array[@]} == 1 ]]; then
    echo "Could not find any files ending in ${SUFFIX}.in"
    exit 1
fi

# Loop through the files
for file in $files; do

    # Get the cooresponding .out file
    output_file=${file%%.*}.out

    # Make sure the output file exists
    if [[ -f $output_file ]]; then
        echo -n "${file::-((3 + ${#SUFFIX}))}: "

        # Get the start time
        if [[ $TIMEIT == true ]]; then
            start_time=$(date +%s%N)
        fi

        # Run the java program
        if [[ $USE_BIN == true ]]; then
            java -cp "../bin" $java_name < $file > output.txt
        else
            java $java_name < $file > output.txt
        fi

        # Get the end time
        if [[ $TIMEIT == true ]]; then
            end_time=$(date +%s%N)
        fi

        # Find the difference
        if [[ $SHOW_DIFF == true ]]; then  
            diff -w -B $output_file output.txt
            correct=$?

            # Only print the success, since errors will be seen
            if [[ $correct == 0 ]]; then
                echo "───==≡≡ΣΣ((( つºل͜º)つ"
            fi

        else
            diff -w -B $output_file output.txt &> /dev/null
            correct=$?

            # Print the boolean correctness
            if [[ $correct == 0 ]]; then
                echo "───==≡≡ΣΣ((( つºل͜º)つ"
            else
                echo ":'("
            fi
        fi

        # Print the time
        if [[ $TIMEIT == true ]]; then
            seconds=$((($end_time - $start_time) / 1000000000))
            milliseconds=$(((($end_time - $start_time) / 1000000) - ($seconds * 1000)))
            echo " Time: ${seconds}.${milliseconds}s"
        fi

    # Could not find the output file
    else
        echo "Could not find a corresponding output file $output_file"
        exit 1
    fi

done
