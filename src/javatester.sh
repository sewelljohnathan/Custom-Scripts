#!/bin/bash
# Compiles and tests a java file against all .out files in the directory, using the available .in files.

# Get cli flags
SHOW_DIFF=false
USE_BIN=false
for arg in "$@"; do
    case $arg in

    -s | --show-diff)
        SHOW_DIFF=true
        shift
        ;;

    -b | --bin)
        USE_BIN=true
        shift
        ;;

    *)
        # Compile the java file
        java_file="$1.java";
        if [[ -f $java_file ]]; then

            # Determine if to compile to ..\bin
            if [[ USE_BIN == true ]]; then
                javac -d ..\\bin $java_file
            else
                javac $java_file
            fi

        else
            echo "Could not find file $java_file"
            exit 1
        fi

        ;;
    esac
done


# Loop through all the files
for file in *; do

    # Check if the file is a .in file
    if [ ${file: -3} == .in ]; then
        output_file=${file::-3}.out
    else
        continue
    fi

    # Make sure the output file exists
    if [[ -f $output_file ]]; then
        echo -n "${file::-3}: "

        # Run the java program
        if [[ USE_BIN == true ]]; then
            java -cp ..\\bin $1 < $file > output.txt
        else
            java $1 < $file > output.txt
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

    # Could not find the output file
    else
        echo "Could not find a corresponding output file $output_file"
        exit 1
    fi

done