# Iterate through all files in the ~/zshrc directory
# and source them into the shell profile

FILES_STR=$(find ~/zshrc -name '*.zshrc')
FILES=($(echo $FILES_STR | tr '\n' ' '))
for FILE in $FILES; do
    source $FILE
done